#!/usr/bin/env bash

set -e

function create_control_file {
  mkdir -pv opkg-package/control

  (
    echo "Package: ${PACKAGE_NAME}"
    echo "Version: ${PACKAGE_VERSION}"
    echo "Architecture: aarch64"
    echo "Maintainer: ${PACKAGE_MAINTAINER}"
    echo "Source: ${PACKAGE_SOURCE_URL}"
    echo "Description: ${PACKAGE_DESCRIPTION}"
    echo "License: ${PACKAGE_LICENSE}"
  ) > opkg-package/control/control

  if [[ -f data/opkg/control/control ]]; then
    cat data/opkg/control/control >> opkg-package/control/control
  fi

  if [[ -f data/opkg/control/postinst ]]; then
    cp -v data/opkg/control/postinst opkg-package/control/
  fi

  if [[ -f data/opkg/control/prerm ]]; then
    cp -v data/opkg/control/prerm opkg-package/control/
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
  ar rv "${PACKAGE_NAME}_${PACKAGE_VERSION}_aarch64.ipk" control.tar.gz data.tar.gz debian-binary
  popd
}

create_control_file
add_data_from_repository
add_binary_data
create_conffiles_file
build_opkg_package
