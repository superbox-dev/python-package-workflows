#!/usr/bin/env bash

set -e

sudo apt update
sudo apt install -y curlftpfs

if [ "${IS_DEV_VERSION}" == "true" ]; then
  repo="testing${REPO_SUFFIX}"
else
  repo="main${REPO_SUFFIX}"
fi

function mount_ftp() {
  sudo mkdir -pv "/mnt/${FTP_HOSTNAME}"
  sudo curlftpfs \
    -v \
    -o "ssl,no_verify_peer,user=${FTP_USER}:${FTP_PASSWORD},allow_other,rw,gid=$(id -g),uid=$(id -u)" \
    "ftp://${FTP_HOSTNAME}:${FTP_PORT}" "/mnt/${FTP_HOSTNAME}"
}

function transfer_to_ftp {
  mkdir -pv "/mnt/${FTP_HOSTNAME}/${FTP_PUBLISH_PATH}/${repo}"
  rm -fv "/mnt/${FTP_HOSTNAME}/${FTP_PUBLISH_PATH}/${repo}/$(basename opkg-package/*.ipk | cut -d "_" -f 1)_"*
  cp -pv opkg-package/*.ipk "/mnt/${FTP_HOSTNAME}/${FTP_PUBLISH_PATH}/${repo}"
}

function create_package_index {
  packages="/mnt/${FTP_HOSTNAME}/${FTP_PUBLISH_PATH}/${repo}"
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
