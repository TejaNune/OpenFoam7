# OpenFOAM-7

# please run the script as a standard/non-root user
# all dependencies to be built from source, except boost due to compilation issues

# define env variables (ensure write access to ${FOAM_PATH})
export FOAM_PATH=/home/apps/OpenFOAM
export CC=gcc
export CXX=g++
export CFLAGS="-Ofast -mtune=native" # -funroll-loops
export CXXFLAGS="-Ofast -mtune=native" # -funroll-loops

# change to OFOAM_PATH
mkdir -p ${FOAM_PATH}
cd ${FOAM_PATH}

# install common dependencies
su -c "yum -y install flex flex-devel git openmpi openmpi-devel" root
su -c"wget https://mirrors.sohu.com/centos/7/os/x86_64/Packages/cmake-2.8.12.2-2.el7.x86_64.rpm"
su -c "yum -y install cmake-2.8.12.2-2.el7.x86_64.rpm" root
rm -rf cmake-2.8.12.2-2.el7.x86_64.rpm  

# fetch sources
git clone https://github.com/OpenFOAM/OpenFOAM-7.git
git clone https://github.com/OpenFOAM/ThirdParty-7.git

# update enavironment - load modules
module avail
module load mpi/openmpi-x86_64

# update environment - enable OpenFOAM variables
export FOAMY_HEX_MESH=1
sed -i '39s/cgal-system/CGAL-4.10/' ${FOAM_PATH}/OpenFOAM-7/etc/config.sh/CGAL
source ${FOAM_PATH}/OpenFOAM-7/etc/bashrc

# build cmake > 3.3 (from Source, yum installs cmake 2.x)
cd ${FOAM_PATH}
su -c "yum -y install openssl-devel" root
wget https://github.com/Kitware/CMake/releases/download/v3.16.4/cmake-3.16.4.tar.gz
tar -xvf cmake-3.16.4.tar.gz
cd cmake-3.16.4
mkdir -p build; cd build
../configure --prefix=/opt/tools/gcc-4.8.5/cmake/3.16.4
make -j
su -c "make install" root
cd ${FOAM_PATH}
rm -rf cmake-3.16.4 cmake-3.16.4.tar.gz
export PATH=/opt/tools/gcc-4.8.5/cmake/3.16.4/bin:${PATH}

# install boost (YUM) (source build runs into build failures, use yum)
cd ${FOAM_PATH}/ThirdParty-7
su -c "yum -y install boost-devel mpfr-devel gmp-devel" root
# wget https://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2/download
# mv download boost_1_55_0.tar.bz2
# tar -xjf boost_1_55_0.tar.bz2

# build CGAL (from Source)
cd ${FOAM_PATH}/ThirdParty-7
wget https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.10/CGAL-4.10.tar.xz
tar -xf CGAL-4.10.tar.xz
./makeCGAL CGAL-4.10

# build scotch, ptscotch & metis (Source)
cd ${FOAM_DIR}/ThirdParty-7
# su -c "yum -y install ptscotch-openmpi ptscotch-openmpi-devel ptscotch-openmpi-devel-parmetis scotch scotch-devel scotch-doc" root
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz
tar -xzf metis-5.1.0.tar.gz
./Allwmake

# build ParaView (from Source) || Not requried to install Paraview in cluster but if needed uncomment and use
# su -c "yum -y install qt5-qtbase-devel qt5-qtx11extras-devel qt5-qttools-devel" root
# su -c "ln -sf /usr/bin/qmake-qt5 /usr/bin/qmake" root
# ./makeParaView

# compile OpenFOAM
cd ${FOAM_PATH}/OpenFOAM-7
./Allwmake -j