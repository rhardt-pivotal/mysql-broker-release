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
    wget $2
  fi
  popd
}

createDirectory src/ruby
downloadFiles src/ruby https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz
downloadFiles src/ruby https://rubygems.org/rubygems/rubygems-3.0.6.tgz
downloadFiles src/ruby http://pyyaml.org/download/libyaml/yaml-0.2.2.tar.gz

createDirectory src/pxc
downloadFiles src/pxc https://www.percona.com/downloads/Percona-XtraDB-Cluster-LATEST/Percona-XtraDB-Cluster-5.7.26-31.37/binary/tarball/Percona-XtraDB-Cluster-5.7.26-rel29-31.37.1.Linux.x86_64.ssl102.tar.gz

createDirectory src/mysqlclient
downloadFiles src/mysqlclient https://github.com/MariaDB/mariadb-connector-c/archive/v3.1.4.tar.gz

createDirectory src/golang-1.13-linux
downloadFiles src/golang-1.13-linux https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz

git clone https://github.com/rhardt-pivotal/cf-mysql-broker src/cf-mysql-broker

pushd ./src
tar cvfz cf-mysql-broker.tgz cf-mysql-broker
tar cvfz cf-mysql-common.tgz cf-mysql-common
tar cvfz mysqlclient.tgz mysqlclient
tar cvfz pxc.tgz pxc
tar cvfz quota-enforcer.tgz quota-enforcer
tar cvfz ruby.tgz ruby
tar cvfz golang-1.13-linux.tgz golang-1.13-linux
popd

bosh add-blob src/cf-mysql-broker.tgz cf-mysql-broker
bosh add-blob src/cf-mysql-common.tgz cf-mysql-common
bosh add-blob src/mysqlclient.tgz mysqlclient
bosh add-blob src/pxc.tgz pxc
bosh add-blob src/quota-enforcer.tgz quota-enforcer
bosh add-blob src/ruby.tgz ruby
bosh add-blob src/golang-1.13-linux.tgz golang-1.13-linux

echo "blobstore:" >> config/final.yml
echo "  provider: local" >> config/final.yml
echo "  options:" >> config/final.yml
echo "    blobstore_path: $PWD/blobs" >> config/final.yml

bosh create-release --final --force --tarball=mysql-broker-release.tgz
