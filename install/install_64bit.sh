#!/bin/sh

#・CentOS 6.8 64bit
#http://www.jifu-labo.net/2016/08/ffmpeg_build-2/

yum -y update
yum -y install autoconf automake bzip2 cmake freetype-devel gcc gcc-c++ git wget libtool make mercurial nasm pkgconfig zlib-devel
  
cpu_core=1
enable_h264=1
enable_h265=1
enable_vp8=1
enable_aac=1
enable_mp3=1
enable_ogg=1
enable_opus=1

enable_add_path=1
  
src_dir="/opt/ffmpeg_sources"
prefix_dir="/opt/ffmpeg_build"

addPATH=$PATH:$prefix_dir/bin

export PATH=$prefix_dir/bin:$PATH
export PKG_CONFIG_PATH="$prefix_dir/lib/pkgconfig"
enable_option=""
  

# chenge to 32bit form 64bit data.
url_yasm="http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz"
url_x264="https://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20160815-2245-stable.tar.bz2"
url_x265="http://ftp.videolan.org/pub/videolan/x265/x265_2.0.tar.gz"
url_aac="http://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.4.tar.gz"
url_opus="http://downloads.xiph.org/releases/opus/opus-1.1.3.tar.gz"
url_libvpx="https://github.com/webmproject/libvpx/archive/v1.6.0.tar.gz"
url_ffmpeg="http://ffmpeg.org/releases/ffmpeg-3.1.2.tar.bz2"
 
url_autoconf="http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz"
url_lame="http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz"
url_ogg="http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz"
url_theora="http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
url_vorbis="http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz"
# chenge to 32bit form 64bit data.
  
print_error()
{
    echo "error: $1"
}
  
run_wget()
{
    url="$1"
    file=${url##*/}
    dir=${file%.tar.*}
  
    if [ ! -e $file ]; then
        #ファイルが存在しない場合
        wget $url
        if [ $? -ne 0 ]; then
            print_error "wget $file" && exit 1
        fi
    fi
  
    case $file in
        #解凍
        *.gz)  tar xvzf $file ;;
        *.bz2) tar xvjf $file ;;
    esac
  
    case $url in
    *libvpx*) dir=libvpx-${dir#v}
    esac
 
    cd $dir
}
  
uid=`id | sed 's/uid=\([0-9]\+\)(.\+/\1/'`
   
if [ $uid -ne 0 ];then
    print_error "not root user"
    exit 1
fi
  
mkdir -p $src_dir
mkdir -p $prefix_dir
  
aconf_ver=`LANG=C autoconf -V | head -n 1 | sed -e "s/autoconf (GNU Autoconf) \([0-9]*\)\.\([0-9]*\)/\1\2/"`
if [ $aconf_ver -lt 269 ]; then
    echo "---------- build autoconf ----------"
    run_wget $url_autoconf
    ./configure --prefix="$prefix_dir" --bindir="$prefix_dir/bin"
    make
    make install
    make distclean
fi
  
  
echo "---------- build Yasm ----------"
cd $src_dir
run_wget $url_yasm
autoreconf -fiv
./configure --prefix="$prefix_dir" --bindir="$prefix_dir/bin"
make -j${cpu_core}
if [ $? -ne 0 ]; then
    print_error "make yasm" && exit 1
fi
make install
make distclean
  
  
if [ $enable_h264 -eq 1 ]; then
    echo "---------- build libx264  ----------"
    cd $src_dir
    run_wget $url_x264
    ./configure --prefix="$prefix_dir" --bindir="$prefix_dir/bin" --enable-static
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libx264" && exit 1
    fi
    make install
    make distclean
    enable_option="${enable_option} --enable-libx264"
fi
  
  
if [ $enable_h265 -eq 1 ]; then
    echo "---------- build libx265  ----------"
    cd $src_dir
    run_wget $url_x265
    cd build/linux
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$prefix_dir" -DENABLE_SHARED:bool=off ../../source
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libx265" && exit 1
    fi
    make install
    make clean
    enable_option="${enable_option} --enable-libx265"
fi
  
  
if [ $enable_aac -eq 1 ]; then
    echo "---------- build libfdk_aac ----------"
    cd $src_dir
    run_wget $url_aac
    autoreconf -fiv
    ./configure --prefix="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libfdk_aac" && exit 1
    fi
    make install
    make distclean
    enable_option="${enable_option} --enable-libfdk-aac"
fi
  
  
if [ $enable_mp3 -eq 1 ]; then
    echo "---------- build libmp3lame ----------"
    cd $src_dir
    run_wget $url_lame
    ./configure --prefix="$prefix_dir" --bindir="$prefix_dir/bin" --disable-shared --enable-nasm
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libmp3lame" && exit 1
    fi
    make install
    make distclean
    enable_option="${enable_option} --enable-libmp3lame"
fi
  
  
if [ $enable_opus -eq 1 ]; then
    echo "---------- build libopus ----------"
    cd $src_dir
    run_wget $url_opus
    ./autogen.sh
    ./configure --prefix="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libopus" && exit 1
    fi
    make install
    make distclean
    enable_option="${enable_option} --enable-libopus"
fi
  
  
if [ $enable_ogg -eq 1 ]; then
    echo "---------- build libogg  ----------"
    cd $src_dir
    run_wget $url_ogg
    ./configure --prefix="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libogg" && exit 1
    fi
    make install
    make distclean
  
    echo "---------- build libvorbis ----------"
    cd $src_dir
    run_wget $url_vorbis
    LDFLAGS="-L$prefix_dir/lib" CPPFLAGS="-I$prefix_dir/include" ./configure --prefix="$prefix_dir" --with-ogg="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libvorbis" && exit 1
    fi
    make install
    make distclean
    enable_option="${enable_option} --enable-libvorbis"
   
    echo "---------- build libtheora ----------"
    cd $src_dir
    run_wget $url_theora
    ./configure --prefix="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
    print_error "make libtheora" && exit 1
    fi
    make install
    make clean
    enable_option="${enable_option} --enable-libtheora"
fi
  
  
if [ $enable_vp8 -eq 1 ]; then
    echo "---------- build libvpx ----------"
    cd $src_dir
    run_wget $url_libvpx
    ./configure --prefix="$prefix_dir" --disable-examples
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libvpx" && exit 1
    fi
    make install
    make clean
    enable_option="${enable_option} --enable-libvpx"
fi
  
  
if [ $enable_ass -eq 1 ]; then
    echo "---------- build libass ----------"
    cd $src_dir
    run_wget $url_libass
    autoreconf -fiv
    ./configure --prefix="$prefix_dir" --disable-shared
    make -j${cpu_core}
    if [ $? -ne 0 ]; then
        print_error "make libass" && exit 1
    fi
    make install
    make clean
    enable_option="${enable_option} --enable-libass"
fi
  
  
echo "---------- build FFmpeg ----------"
cd $src_dir
run_wget $url_ffmpeg
   
./configure \
  --prefix="$prefix_dir" --extra-cflags="-I$prefix_dir/include" \
  --extra-ldflags="-L$prefix_dir/lib" \
  --bindir="$prefix_dir/bin" \
  --pkg-config-flags="--static" \
  --enable-gpl \
  --enable-nonfree \
  --enable-libfreetype \
  $enable_option
make -j${cpu_core}
if [ $? -ne 0 ]; then
    print_error "make ffmpeg" && exit 1
fi
make install
make distclean
hash -r


if [ $enable_add_path -eq 1 ]; then
	echo $addPATH >> /etc/profile
fi
