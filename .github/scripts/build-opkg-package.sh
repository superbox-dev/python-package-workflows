#!/usr/bin/env bash

set -e

function create_control_file {
  mkdir -pv opkg-package/control

  (
    echo "Package: ${{ inputs.package-name }}"
    echo "Version: ${{ inputs.package-version }}"
    echo "Architecture: aarch64"
    echo "Maintainer: ${{ inputs.package-maintainer }}"
    echo "Source: ${{ inputs.package-source-url }}"
    echo "Description: ${{ inputs.package-description }}"
    echo "License: ${{ inputs.package-license }}"
  ) > opkg-package/control/control

  if [[ -f opkg/control/control ]]; then
    cat opkg/control/control >> opkg-package/control/control
  fi

  if [[ -f opkg/control/postinst ]]; then
    cp -v opkg/control/postinst opkg-package/control/
  fi

  if [[ -f opkg/control/prerm ]]; then
    cp -v opkg/control/prerm opkg-package/control/
  fi

  cat opkg-package/control/control

  echo "2.0" > opkg-package/debian-binary
}

function add_data_from_repository {
  mkdir -pv opkg-package/data/
  [ -d "data/opkg/data" ] && cp -rv data/opkg/data/* opkg-package/data/
}

function add_binary_data {
  mkdir -pv opkg-package/data/usr/local/bin/
  for f in binary-files/*.tar.gz; do tar xzfv "${f}" -C binary-files; done
  rm -fv binary-files/*.tar.gz
  cp -v binary-files/* opkg-package/data/usr/local/bin/
}

function create_conffiles_file {
  find data/opkg/data/etc -type f | sed 's/data\/opkg\/data\///g' > opkg-package/control/conffiles
  find data/opkg/data/usr/local/etc -type f | sed 's/data\/opkg\/data\///g' > opkg-package/control/conffiles
}

function build_opkg_package {
  pushd opkg-package/control
  tar --numeric-owner --group=0 --owner=0 -czf ../control.tar.gz .
  popd

  pushd opkg-package/data
  tar --numeric-owner --group=0 --owner=0 -czf ../data.tar.gz .
  popd

  pushd opkg-package
  ar rv "${{ inputs.package-name }}_${{ inputs.package-version }}_aarch64.ipk" control.tar.gz data.tar.gz debian-binary
  popd
}

create_control_file
add_data_from_repository
add_binary_data
create_conffiles_file
build_opkg_package
