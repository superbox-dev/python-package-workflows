#!/usr/bin/env bash

set -e

sudo apt update
sudo apt install -y curlftpfs

is_dev_version="${{ inputs.is-dev-version }}"
ftp_user="${{ inputs.ftp-username }}"
ftp_password="${{ secrets.FTP_PASSWORD }}"
ftp_hostname="${{ inputs.ftp-hostname }}"
ftp_port="${{ inputs.ftp-port }}"
ftp_publish_path="${{ inputs.ftp-publish-path }}"

if [ "${is_dev_version}" == "true" ]; then
  repo_suffix="testing"
else
  repo_suffix="main"
fi

function mount_ftp() {
  sudo mkdir -pv "/mnt/${{ inputs.ftp-hostname }}"
  sudo curlftpfs \
    -v \
    -o "ssl,no_verify_peer,user=${ftp_user}:${ftp_password},allow_other,rw,gid=$(id -g),uid=$(id -u)" \
    "ftp://${ftp_hostname}:${ftp_port} /mnt/${ftp_hostname}"
}

function transfer_to_ftp {
  mkdir -pv "/mnt/${ftp_hostname}/${ftp_publish_path}/${repo_suffix}"
  rm -fv "/mnt/${ftp_hostname}/${ftp_publish_path}/${repo_suffix}/$(basename opkg-package/*.ipk | cut -d "_" -f 1)_"*
  cp -pv opkg-package/*.ipk "/mnt/${ftp_hostname}/${ftp_publish_path}/${repo_suffix}"
}

function create_package_index {
  packages="/mnt/${ftp_hostname}/${ftp_publish_path}/${repo_suffix}"
  tmp="${GITHUB_WORKSPACE}/tmp"

  mkdir -pv "${tmp}"
  cp -v "${packages}/"*.ipk "${tmp}"

  for pkg in "${tmp}/"*.ipk; do \
    sudo ar x "${pkg}" --output "${tmp}"; \
    for control in ${tmp}/control.tar.gz; do \
      tar xzf "${control}" -C "${tmp}"; \
      {
        echo -e "Size: $(stat -c %s "${pkg}")"
        echo -e "SHA256sum: $(sha256sum "${pkg}" | grep -o "^[^ ]*")"
        echo -e "Filename: $(basename "${pkg}")\n"
      } >> "${tmp}/control"; \
      cat "${tmp}/control" >> "${tmp}/Packages"; \
    done; \
  done

  gzip -vk "${tmp}/Packages"
  mv -v "${tmp}/Packages"* "${packages}"
}

mount_ftp
transfer_to_ftp
create_package_index
