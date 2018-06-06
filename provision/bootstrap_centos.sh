#!/bin/bash

# Remove packagekit that's causing yum to lockup.
yum -y remove PackageKit
echo "> Bootstrap_centos.sh removed packagekit"

yum makecache fast

# Install epel
yum install -y wget git
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

# Work around for epel bug https://bugs.centos.org/view.php?id=13669&nbn=1
rpm -ivh --replacepkgs https://kojipkgs.fedoraproject.org/packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm

# Install psychotic repo and keychain
rpm --import http://wiki.psychotic.ninja/RPM-GPG-KEY-psychotic
rpm -ivh http://packages.psychotic.ninja/6/base/i386/RPMS/psychotic-release-1.0.0-1.el6.psychotic.noarch.rpm
yum -y --enablerepo=psychotic install keychain