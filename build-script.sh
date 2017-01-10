#!/bin/bash

export RUNTIME_PACKAGES="wget libxml2 libxslt1.1 curl zip openssl libgd-dev libfcgi0ldbl  	\
libgdal1h libgeos-3.4.2 libgeos-c1 libgfortran3 gfortran-multilib libquadmath0 libblas-dev liblapack-dev \
libmozjs185-1.0 libproj0 libgeotiff2 libcairo2 libjpeg62 libtiff5 libpng3 libxslt1.1 \
python2.7 python-tk libwxbase3.0-0 libwxgtk3.0-0 wx-common apache2"

apt-get update -y \
      && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES

export BUILD_PACKAGES="autoconf automake autotools-dev bison build-essential flex \
gfortran ibwxbase3.0-dev libcairo2-dev libfcgi-dev libfreetype6-dev libgd-gd2-perl \
libgd2-xpm-dev libgdal-dev libgeotiff-dev libmozjs185-dev libnetcdf-dev libproj-dev \
libtiff5-dev libtool libwxgtk3.0-dev libxml2-dev libxslt1-dev python-dev python-pip \
software-properties-common subversion unzip wx3.0-headers wx3.0-i18n"

apt-get install -y --no-install-recommends $BUILD_PACKAGES

# for mapserver
export CMAKE_C_FLAGS=-fPIC
export CMAKE_CXX_FLAGS=-fPIC

# useful declarations
export BUILD_ROOT=/opt/build
export ZOO_BUILD_DIR=/opt/build/zoo-project
export CGI_DIR=/usr/lib/cgi-bin
export CGI_DATA_DIR=$CGI_DIR/data
export CGI_TMP_DIR=$CGI_DATA_DIR/tmp
export CGI_CACHE_DIR=$CGI_DATA_DIR/cache
export WWW_DIR=/var/www/html

# should build already there from base
# mkdir -p $BUILD_ROOT \
#   && mkdir -p $CGI_DIR \
#   && mkdir -p $CGI_DATA_DIR \
#   && mkdir -p $CGI_TMP_DIR \
#   && mkdir -p $CGI_CACHE_DIR \
#   && ln -s /usr/lib/x86_64-linux-gnu /usr/lib64

# for gdal python
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal

pip install python-dateutil numpy || exit 1
pip install matplotlib netcdf4 || exit 1
pip install flopy gdal==1.10.0 || exit 1
pip install scipy || exit 1
pip install OWSlib Pyshp || exit 1

# https://github.com/allixender/modflow2005-trusty64/archive/master.zip
# modflow2005-trusty64-master.zip
wget -nv -O $BUILD_ROOT/modflow2005-trusty64-master.zip https://github.com/allixender/modflow2005-trusty64/archive/master.zip \
  && cd $BUILD_ROOT/ && unzip modflow2005-trusty64-master.zip \
  && cd $BUILD_ROOT/modflow2005-trusty64-master \
  && cd src && make all && cp mf2005 $CGI_DIR || exit 1

# https://github.com/allixender/swatmodel-trusty64/archive/master.zip
# swatmodel-trusty64-master.zip
wget -nv -O $BUILD_ROOT/swatmodel-trusty64-master.zip https://github.com/allixender/swatmodel-trusty64/archive/master.zip \
  && cd $BUILD_ROOT/ && unzip swatmodel-trusty64-master.zip \
  && cd $BUILD_ROOT/swatmodel-trusty64-master \
  && make all && cp dist/swat_rel64 dist/swat_rel32 dist/swat_debug64 dist/swat_debug32 $CGI_DIR || exit 1

# https://github.com/allixender/pest13-trusty64/archive/master.zip
# pest13-trusty64-master.zip

# guestimated output tools
export PEST_TOOLS="pest predvar1 predvar1a predvar1b predvar1c predvar2 predvar3 predvar4 \
predvar5 predunc1 predunc4 predunc5 predunc6 predunc7 infstat infstat1 \
wtsenout pnulpar muljcosen identpar supcalc simcase ssstat parvar1 \
ppest eigproc inschek jacwrit jco2jco jcotrans jcochek par2par \
paramfix parrep pestchek jcosub pestgen picalc ppause pslave \
pstop pstopst punpause svdaprep tempchek wtfactor ppd2asc ppd2par \
parcalc obscalc dercomb1 genlin jco2mat jcoaddz jcocomb jcoorder \
jcopcat jrow2mat jrow2vec obsrep paramerr pclc2mat pcov2mat pest2vec \
pestlin prederr prederr1 prederr2 pwtadj1 regerr resproc reswrit \
scalepar vec2pest veclog prederr3 pwtadj2 jcodiff regpred addreg1 \
randpar mulpartab comfilnme paramid postjactest genlinpred subreg1 phistats \
lhs2pest pest2lhs parreduce assesspar cov2cor covcond mat2srf matadd \
matcolex matdiag matdiff matinvp matjoinc matjoind matjoinr matorder \
matprod matquad matrow matsmul matspec matsvd matsym mattrans \
matxtxi matxtxix mat2jco cmaes_p sceua_p jactest rdmulres obs2obs \
supobspar supobsprep supobspar1 sensan senschek beopest"

wget -nv -O $BUILD_ROOT/pest13-trusty64-master.zip https://github.com/allixender/pest13-trusty64/archive/master.zip \
  && cd $BUILD_ROOT/ && unzip pest13-trusty64-master.zip \
  && cd $BUILD_ROOT/pest13-trusty64-master/src \
  && make cppp && make d_test && make -f pest.mak all && make -f ppest.mak all \
  && make -f pestutl1.mak all && make -f pestutl2.mak all && make -f pestutl3.mak all \
  && make -f pestutl4.mak all && make -f pestutl5.mak all && make -f pestutl6.mak all \
  && make -f sensan.mak all && make -f beopest.mak all \
  && for tool in $PEST_TOOLS; do cp $tool $CGI_DIR; done || exit 1

# however, auto additonal packages won't get removed
# maybe auto remove is a bit too hard
# RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
# ENV AUTO_ADDED_PACKAGES $(apt-mark showauto)
# RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

# do we need to consider /usr/lib/saga ?
# 611M    /opt/build/saga-2.1.4 ouch
rm -rf $BUILD_ROOT/modflow2005-trusty64-master
rm -rf $BUILD_ROOT/swatmodel-trusty64-master
rm -rf $BUILD_ROOT/pest13-trusty64-master
rm -rf $BUILD_ROOT/modflow2005-trusty64-master.zip
rm -rf $BUILD_ROOT/swatmodel-trusty64-master.zip
rm -rf $BUILD_ROOT/pest13-trusty64-master.zip
