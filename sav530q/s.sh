
ProjectPath=`pwd`
# ProjectPath=/home/gray/temp/20200804

echo "this script is for sav530q"
echo "ProjectPath:$ProjectPath"
echo "============================================="

MAKE="make -j16"
toMakeClean="0"

InstallPackages(){
    sudo apt-get update
    sudo apt-get install -y python \
    git \
    make-guile \
    gcc \
    libncurses5-dev \
    libncursesw5-dev
}

SetEnvVars(){

    ProjectPath=$(pwd)
    ./env_auto7.sh
    export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:$PATH
    declare -x ARCH="arm"
    declare -x CROSS_COMPILE="arm-linux-gnueabihf-"
}

Build_UBoot(){
    cd $ProjectPath/boot/
    make infinity6e_spinand_defconfig
    if [ "$toMakeClean" == "1" ] ; then
        make clean
    fi
    $MAKE
    ls -l u-boot_spinand.xz.img.bin
    cp u-boot_spinand.xz.img.bin ../project/board/i6e/boot/spinand/uboot/
}
Build_Kernel(){
    cd $ProjectPath/kernel/
    make infinity6e_ssc013a_s01a_spinand_defconfig
    if [ "$toMakeClean" == "1" ] ; then
        make clean
    fi
    $MAKE
    ls -l arch/arm/boot/uImage.xz 
    cp arch/arm/boot/uImage.xz ../project/release/ipc/i6e/013A/glibc/9.1.0/bin/kernel/spinand/
}
Build_Lib(){
    cd $ProjectPath/sdk/verify/mi_demo/alderaan
    if [ "$toMakeClean" == "1" ] ; then
        make clean
    fi
    $MAKE
}
Build_Moapp(){
    cd $ProjectPath/sdk/verify/mi_demo/alderaan/moapp
    $MAKE
}

Build_Vendor(){
    cd $ProjectPath/vendor
    $MAKE
    make install
}
Build_WiFi(){
    cd $ProjectPath/wifi_drv_release/wlan_driver/gen4m
    ./build_for_i6e_sdio.sh

    mkdir $ProjectPath/../mt7663
    cp -f $ProjectPath/wifi_drv_release/wlan_driver/gen4m/wlan_mt7663_sdio.ko $ProjectPath/../mt7663
    cp -f $ProjectPath/kernel/drivers/base/firmware_class.ko $ProjectPath/../mt7663
    sudo chmod 777 -R $ProjectPath/../mt7663/*.*
}
Build_Project(){
    cd $ProjectPath/project/
    ./setup_config.sh configs/ipc/i6e/spinand.glibc-9.1.0-squashfs.013a.256.bga
    make image
}
Build_SensorDriver(){
    cd $ProjectPath/sdk/driver/SensorDriver/
    $MAKE
    cp drv/src/PS5520_MIPI.ko ../../../project/release/ipc/i6e/common/glibc/9.1.0/modules/4.9.84/
}
Build_Libs_Moapp(){
    cd $ProjectPath/sdk/verify/mi_demo/alderaan

    if [ "$toMakeClean" == "1" ] ; then
        make clean
    fi
    $MAKE

    cd moapp
    $MAKE
}
Build_Vendor(){
    cd $ProjectPath/vendor
    $MAKE
    make install
}

MakeImage(){
    cd $ProjectPath/project/
    ./setup_config.sh configs/ipc/i6e/spinand.glibc-9.1.0-squashfs.013a.256.bga
    make image -j4
}
MakeImage2(){
    cd $ProjectPath/project/
    make image -j4
}

CopyImage(){
    # DateTime=$(date +"%Y%m%d_%H%M%S")
    DateTime=$(date +"%Y%m%d_%H%M")
    echo "DateTime:$DateTime"
    cd $ProjectPath
    cd ..
    mkdir "images_$DateTime"
    rsync -rtvp $ProjectPath/project/image/output/images/* "images_$DateTime"
}

if [ "$1" == "env" ] ; then

    echo "sh $ProjectPath/env_auto7.sh"
    echo "export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:\$PATH"
    echo "declare -x ARCH=\"arm\""
    echo "declare -x CROSS_COMPILE=\"arm-linux-gnueabihf-\""
    
fi

# working directory 
if [ "$1" == "wd" ] ; then
	echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP" 
    xfce4-terminal --geometry=160x40 \
    --tab -T "temp" --working-directory="$ProjectPath/.." \
    --tab -T "Project root" --working-directory=$ProjectPath \
    --tab -T "Project vendor" --working-directory=$ProjectPath/vendor \
    --tab -T "ADK 4.0" --working-directory="$ProjectPath/vendor/Apple/ADK/4.0" \
    --tab -T "libs" --working-directory="/home/gray/temp/libs/hostapd-2.7/hostapd" \
    --tab -T "Git" --working-directory="$ProjectPath/../git"
fi

if [ "$1" == "git" ] ; then
	if [ "$2" == "clone" ] ; then
        git clone ssh://git@10.1.13.207:30001/vendor/sigmastar/sav530q/20200804.git
    fi
fi

if [ "$1" == "i" ] ; then
    InstallPackages
elif [ "$1" == "ci" ] ; then
    CopyImage
fi

if [ "$1" == "b" ] ; then
    # build
    sudo ln -fs bash /bin/sh
    sh $ProjectPath/env_auto7.sh
    export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:$PATH
    declare -x ARCH="arm"
    declare -x CROSS_COMPILE="arm-linux-gnueabihf-"

    if [ -z "$2" ] ; then
        # $2 empty
        echo "param 2 empty, use param below >>>>>>>>>>"
        echo "\"b\"     for build UBoot"
        echo "\"k\"     for build Kernel"
        echo "\"mi\"    for make image"
        echo "\"l\"     for build Library"
        echo "\"m\"     for build Moapp"
        echo "\"wifi\"  for build wifi .ko"
        echo "\"all\"   for build whole"

    elif [ "$2" == "b" ] ; then
        Build_UBoot
    elif [ "$2" == "k" ] ; then
        Build_Kernel
    elif [ "$2" == "mi" ] ; then
        MakeImage
    elif [ "$2" == "l" ] ; then
        Build_Lib
    elif [ "$2" == "m" ] ; then
        Build_Moapp
    elif [ "$2" == "wifi" ] ; then
        Build_WiFi
    elif [ "$2" == "all_old" ] ; then

        # Build All
        Build_UBoot
        Build_Kernel
        MakeImage
        Build_Lib
        Build_Moapp
        Build_Vendor
        MakeImage2
        CopyImage

    elif [ "$2" == "all_old2" ] ; then

        # Build All
        Build_UBoot
        Build_Project
        Build_SensorDriver
        Build_Libs_Moapp
        Build_Vendor
        MakeImage
        CopyImage
    elif [ "$2" == "all" ] ; then

        # Build All
        Build_UBoot
        MakeImage
        Build_SensorDriver
        Build_Vendor
        Build_Libs_Moapp
        MakeImage
        CopyImage
    fi
fi

if [ "$1" == "wifi" ] ; then

    if [ "$2" == "code" ] ; then
        # Wi-Fi related files
        # code $ProjectPath/kernel/arch/arm/boot/dts/infinity6e.dtsi
        # code $ProjectPath/kernel/arch/arm/boot/dts/infinity6e-ssc013a-s01a.dts
        code $ProjectPath/kernel/arch/arm/configs/infinity6e_ssc013a_s01a_spinand_defconfig
        # code $ProjectPath/kernel/.config

        code $ProjectPath/project/image/configs/i6e/rootfs.mk
        code $ProjectPath/vendor/primax/project/patches/rootfs.mk.append

        # code $ProjectPath/vendor/primax/rootfs/prebuild/customer/etc/init.d/S70wifi.sh

    elif [ "$2" == "files" ] ; then
        # save files
        mkdir wifi_change_files
        cp -f $ProjectPath/kernel/arch/arm/boot/dts/infinity6e.dtsi wifi_change_files
        cp -f $ProjectPath/kernel/arch/arm/boot/dts/infinity6e-ssc013a-s01a.dts wifi_change_files
        cp -f $ProjectPath/kernel/arch/arm/configs/infinity6e_ssc013a_s01a_spinand_defconfig wifi_change_files
        cp -f $ProjectPath/project/image/configs/i6e/rootfs.mk wifi_change_files
        cp -f $ProjectPath/vendor/primax/rootfs/prebuild/customer/etc/init.d/S70wifi.sh wifi_change_files

    fi
fi

if [ "$1" == "adk" ] ; then
    if [ "$2" == "cp" ] ; then
        if [ "$3" == "libs" ] ; then
            echo "copy adk libs >>>>>>>>>>"
            cd $ProjectPath/vendor/Apple/prebuild_libs

            sh $ProjectPath/env_auto7.sh
            export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:$PATH
            declare -x ARCH="arm"
            declare -x CROSS_COMPILE="arm-linux-gnueabihf-"

            cp -f $ProjectPath/third-party/libNE10/lib/libNE10.so.10 .
            arm-linux-gnueabihf-strip --strip-unneeded libNE10.so.10

            cp -f $ProjectPath/third-party/libusb/lib/libusb-1.0.so.0 .
            arm-linux-gnueabihf-strip --strip-unneeded libusb-1.0.so.0

            cp -f $ProjectPath/third-party/udev/lib/libudev.so.0 .
            arm-linux-gnueabihf-strip --strip-unneeded libudev.so.0

            cp -f $ProjectPath/third-party/libusb-compat/lib/libusb-0.1.so.4 .
            arm-linux-gnueabihf-strip --strip-unneeded libusb-0.1.so.4

            cp -f /home/gray/temp/libs/alsa/output/lib/libasound.so.2 .
            arm-linux-gnueabihf-strip --strip-unneeded libasound.so.2

            cp -f $ProjectPath/third-party/mDNSResponder/lib/libdns_sd.so .
            arm-linux-gnueabihf-strip --strip-unneeded libdns_sd.so

            cp -f $ProjectPath/third-party/sqlite/lib/libsqlite3.so.0 .
            arm-linux-gnueabihf-strip --strip-unneeded libsqlite3.so.0

            cp -f $ProjectPath/third-party/opus/lib/libopus.so.0 .
            arm-linux-gnueabihf-strip --strip-unneeded libopus.so.0

            cp -f $ProjectPath/third-party/libnfc/lib/libnfc.so.5 .
            arm-linux-gnueabihf-strip --strip-unneeded libnfc.so.5

            cp -f $ProjectPath/third-party/wireless_tools/lib/libiw.so.29 .
            arm-linux-gnueabihf-strip --strip-unneeded libiw.so.29

            cp -f $ProjectPath/third-party/openssl/lib/libcrypto.so.1.1 .
            arm-linux-gnueabihf-strip --strip-unneeded libcrypto.so.1.1

            cp -f $ProjectPath/third-party/fdk-aac/lib/libfdk-aac.so.2 .
            arm-linux-gnueabihf-strip --strip-unneeded libfdk-aac.so.2

            cp -f $ProjectPath/third-party/libusb/lib/libusb-1.0.so.0 .
            arm-linux-gnueabihf-strip --strip-unneeded libusb-1.0.so.0

        fi

    elif [ "$2" == "b" ] ; then
            echo "build adk >>>>>>>>>>"
            sh $ProjectPath/env_auto7.sh
            export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:$PATH
            declare -x ARCH="arm"
            declare -x CROSS_COMPILE="arm-linux-gnueabihf-"

            adkPath=/home/gray/temp/homekit
            cd $adkPath
    
            arm-linux-gnueabihf-strip --strip-unneeded SeaLion

    fi

fi

if [ "$1" == "code" ] ; then
    if [ "$2" == "s" ] ; then
        code ~/Gray/s.sh
    fi
fi

if [ "$1" == "st" ] ; then

    # sh $ProjectPath/env_auto7.sh
    export PATH=$ProjectPath/gcc-sigmastar-9.1.0-2019.11-x86_64_arm-linux-gnueabihf/bin:$PATH
    declare -x ARCH="arm"
    declare -x CROSS_COMPILE="arm-linux-gnueabihf-"

    # arm-linux-gnueabihf-strip --strip-unneeded $2
    arm-linux-gnueabihf-strip $2

fi
