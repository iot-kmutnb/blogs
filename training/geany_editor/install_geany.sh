#!/usr/bin/env bash

# set the version of Geany
GEANY_VERSION=1.38

if [ -x $(command -v geany) ]; then
  echo "uninstall geany..."
  sudo apt remove -y --purge geany geany-common geany-plugins
fi

if ! [ -x $(command -v wget) ]; then
  echo "install wget"
  sudo apt install -y wget
fi

# install necessary packages to build Geany from sourcecode
sudo apt install -y build-essential automake autoconf \
  pkg-config intltool libgtk-3-dev libvte-2.91-dev \
  gdb cppcheck 

#-------------------------------------------------------
# set the URL
URL=https://download.geany.org
# set the filename of the GEANY archive file
ARCHIVE_FILE=geany-${GEANY_VERSION}.tar.gz
# download the archive file of Geany source code (.tar.gz)
result=$(wget -c ${URL}/${ARCHIVE_FILE} -O ${ARCHIVE_FILE})
if [ $? -ne 0 ] || ! [ -f ${ARCHIVE_FILE} ]; then
   echo "Cannot download ${ARCHIVE_FILE} or file doesn't exist!"
   exit -1
fi
# extract the compressed archive file
tar xvfz ${ARCHIVE_FILE}
# change the working directory
cd geany-${GEANY_VERSION}/
# configure and build the source code
result=$(./configure && make -j 4)
if [ $? -ne 0 ]; then
   "Geany: configure or make failed"
   exit -1
fi
# install the binary file of Geany
sudo make install
# remove the sourcecode directory
rm -fr geany-${GEANY_VERSION}

#-------------------------------------------------------
# set the filename of the GEANY-plugins archive file
ARCHIVE_FILE=geany-plugins-${GEANY_VERSION}.tar.gz
# set the URL
URL=https://plugins.geany.org/geany-plugins
# download the source code .tar.gz file
result=$(wget ${URL}/${ARCHIVE_FILE} -O ${ARCHIVE_FILE})
if [ $? -ne 0 ] || ! [ -f ${ARCHIVE_FILE} ]; then
   echo "Cannot download ${ARCHIVE_FILE} or file doesn't exist!"
   exit -1
fi
# extract the compressed archive file
tar xvfz ${ARCHIVE_FILE}
# change the working directory
cd ./geany-plugins-${GEANY_VERSION}
# configure and build the source code
result=$(./configure --enable-debugger && make -j 4)
if [ $? -ne 0 ]; then
   "Geany-plugins: configure or make failed"
   exit -1
fi
# install the shared lib files for Geany plugins
sudo make install
# reload the configuration files under /etc/ld.so.conf.d/
sudo ldconfig -v
# remove the sourcecode directory
rm -fr ./geany-plugins-${GEANY_VERSION}
#-------------------------------------------------------
echo "Done..."
```
