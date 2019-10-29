#!/bin/bash

createDirectory() {
  if [ ! -d $1 ]; then
    mkdir -p $1
  fi
}

downloadFiles() {
  pushd $1
  FILE=$(echo $2 | awk -F/ '{print $NF}')
  if [ ! -f $FILE ]; then
    wget --content-disposition $2
  fi
  popd
}

createDirectory tmp/pxc
downloadFiles tmp/pxc https://www.percona.com/downloads/Percona-XtraDB-Cluster-LATEST/Percona-XtraDB-Cluster-5.7.26-31.37/binary/tarball/Percona-XtraDB-Cluster-5.7.26-rel29-31.37.1.Linux.x86_64.ssl102.tar.gz

createDirectory tmp/mysqlclient
downloadFiles tmp/mysqlclient https://github.com/MariaDB/mariadb-connector-c/archive/v3.1.4.tar.gz



pushd ./tmp
tar cvfz mysqlclient.tgz mysqlclient
tar cvfz pxc.tgz pxc
popd

bosh add-blob tmp/mysqlclient.tgz mysqlclient
bosh add-blob tmp/pxc.tgz pxc



echo "blobstore:" >> config/final.yml
echo "  provider: local" >> config/final.yml
echo "  options:" >> config/final.yml
echo "    blobstore_path: $PWD/blobs" >> config/final.yml

bosh create-release --final --force --tarball=mysql-broker-release.tgz
