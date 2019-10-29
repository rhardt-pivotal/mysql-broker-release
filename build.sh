#!/bin/bash

createDirectory() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

downloadFiles() {
  pushd $1

  if [ -z "$3" ]
  then
    FILE=$(echo $2 | awk -F/ '{print $NF}')
  else
    FILE=$3
  fi

  if [ ! -f $FILE ]; then
    wget --content-disposition $2
  fi
  popd
}

#createDirectory tmp/pxc
#downloadFiles tmp/pxc https://www.percona.com/downloads/Percona-XtraDB-Cluster-LATEST/Percona-XtraDB-Cluster-5.7.26-31.37/binary/tarball/Percona-XtraDB-Cluster-5.7.26-rel29-31.37.1.Linux.x86_64.ssl102.tar.gz

createDirectory tmp/mysqlclient
downloadFiles tmp/mysqlclient https://github.com/MariaDB/mariadb-connector-c/archive/v3.1.4.tar.gz mariadb-connector-c-3.1.4.tar.gz



pushd ./tmp
tar cvfz mysqlclient.tgz mysqlclient
# tar cvfz pxc.tgz pxc
popd

bosh add-blob tmp/mysqlclient.tgz mysqlclient.tgz
# bosh add-blob tmp/pxc.tgz pxc


git clone https://github.com/bosh-packages/golang-release tmp/golang-release
bosh vendor-package golang-1.13-linux  tmp/golang-release

git clone https://github.com/bosh-packages/ruby-release tmp/ruby-release
bosh vendor-package ruby-2.6.5-r0.26.0 tmp/ruby-release



echo "blobstore:" >> config/final.yml
echo "  provider: local" >> config/final.yml
echo "  options:" >> config/final.yml
echo "    blobstore_path: $PWD/blobs" >> config/final.yml

bosh create-release --force 
