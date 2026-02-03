
# Loop through all parameters passed to the script
echo "xDir = $xDir"
echo "param 0: $0"
i=1
for arg in "$@"; do
    echo "param $i: $arg"
    ((i++))
done

xDir=~/OSPath/MAC

currentDateTime=`date "+%m%d%H%M"`

# wheeltec
wheeltec_ip="192.168.1.196"

# dell server
DellServer_ip="10.1.13.207"

# ai camera
# AICamera_ip="192.168.2.99"
AICamera_ip="aicamera-0687.local"
# AICamera_ip="visionhub-0687.local"
# AICamera_ip="aibox-0791.local"
# AICamera_ip="192.168.1.114"

# nfs
if [ "$1" == "nfs" ] ; then
	echo "========== NFS "==========
	cd ~
	if [ "$2" = "+" ] ; then
		mount -t nfs -o nolock 10.1.13.207:/mnt/disk2/yocto_build_folder/gray DellServer/yocto_build_folder
		mount -t nfs -o nolock 10.1.13.207:/home/gray.lin DellServer/home
	
	elif [ "$2" = "-" ] ; then
		umount DellServer/yocto_build_folder
		umount DellServer/home
	fi

fi

# ssh
if [ "$1" == "ssh" ] ; then

	if [ "$2" == "dell" ] ; then

		## ctcfw/Primax1234
		if [ "$3" != "" ] ; then
			ssh $3@$DellServer_ip
		else
			sshpass -p 'Zx03310331' ssh gray.lin@$DellServer_ip
			# ssh gray.lin@$DellServer_ip
		fi

	elif [ "$2" == "pi" ] ; then
		ssh pi@raspberrypi.local
	
	elif [ "$2" == "aic" ] ; then
		if [ "$3" == "r" ] ; then
			echo "ssh-keygen -R $AICamera_ip"
			ssh-keygen -R $AICamera_ip
		fi
		echo "ssh root@$AICamera_ip"
		ssh root@$AICamera_ip

	elif [ "$2" == "usb" ] ; then
		# device_ip="192.168.1.190"
		device_ip="192.168.1.127"
		if [ "$3" == "r" ] ; then
			echo "ssh-keygen -R $device_ip"
			ssh-keygen -R $device_ip
		fi
		echo "ssh root@$device_ip"
		ssh root@$device_ip

	elif [ "$2" == "wt" ] ; then
		# wheeltech
		if [ "$3" = "r" ] ; then
			ssh -Y root@$wheeltec_ip
		else
			echo "ssh -Y wheeltec@$wheeltec_ip"
			ssh -Y wheeltec@$wheeltec_ip
		fi
	else
		if [ "$2" == "r" ] ; then
			echo "ssh-keygen -R $3"
			ssh-keygen -R $3
		fi

	fi
fi

# scp
if [ "$1" == "scp" ] ; then
	echo "copy files..."
	if [ "$2" == "aic" ] ; then
		# user="ubuntu"
		# pass="primax1234"
		user="root"
		pass=""
		remoteFolder=""
		# remoteFolder="~/primax/apps"
		if [ "$3" == "up" ] ; then
			echo "scp ./$4 $user@$AICamera_ip:$remoteFolder$5"
			scp ./$4 $user@$AICamera_ip:$remoteFolder$5
			# sshpass scp ./$4 $user@$AICamera_ip:$remoteFolder/$5
		elif [ "$3" == "down" ] ; then
			echo "sshpass scp $user@$AICamera_ip:$remoteFolder$4 ."
			sshpass scp $user@$AICamera_ip:$remoteFolder$4 .
		fi
	fi
fi

if [ "$1" == "lan" ] ; then
	if [ "$2" == "scan" ] ; then
		lan="192.168.$3.0/24"
		echo "nmap -sn "$lan""
		nmap -sn "$lan"
	fi
fi

# system related 
if [ "$1" = "sys" ] ; then
	if [ "$2" = "service" ] ; then
		echo "========== Service info =========="
		echo "(macOS doesn't use 'service --status-all')"
		echo "Listing loaded LaunchDaemons and LaunchAgents..."
		echo "---- System Services ----"
		launchctl list | head -n 30
		echo "---- User Services ----"
		launchctl list gui/$(id -u) | head -n 30

	elif [ "$2" = "info" ] ; then
		echo "========== System info =========="
		echo "==== macOS version ( sw_vers ) ===="
		sw_vers
		echo "==== Kernel version ( uname -a ) ===="
		uname -a
		echo "==== CPU info ( sysctl -n machdep.cpu.* ) ===="
		sysctl -n machdep.cpu.brand_string
		sysctl -n machdep.cpu.core_count
		sysctl -n machdep.cpu.thread_count
		echo "==== Memory info ( vm_stat ) ===="
		vm_stat | grep "free\|active\|inactive\|speculative"
		echo "==== Disk info ( df -h ) ===="
		df -h | grep /dev/

	elif [ "$2" = "users" ] ; then
		echo "========== Logged-in Users =========="
		who
		echo "========== All Local Users =========="
		dscl . list /Users | grep -v '^_'

	elif [ "$2" = "user" ] ; then
		echo "========== User Groups =========="
		id -Gn $3

	elif [ "$2" = "net" ] ; then
		echo "========== Network Scan =========="
		echo "nmap is not preinstalled on macOS, use 'brew install nmap' first."
		if command -v nmap >/dev/null 2>&1; then
			nmap -A 192.168.100.*
		else
			echo "nmap not found."
		fi

	else
		echo "param 3 not match"
		exit 1
	fi
fi

# vs code
if [ "$1" == "code" ] ; then
	if [ "$2" == "x" ] ; then
		code "$xDir/x.sh"
	elif [ "$2" == ".rc" ] ; then
		echo "edit ~/.zshrc"
		code ~/.zshrc
	elif [ "$2" == "fp" ] ; then
		echo "full path $3"
		code $3
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# gstreamer
if [ "$1" == "gst" ] ; then

	gstVersion="1.20.3"
	# gstVersion="1.18.6"
	cerberoFolder=~/"Work/libs/cerbero"
	badSrcFolder="$cerberoFolder/build/sources/ios_universal/arm64/gst-plugins-bad-1.0-$gstVersion"
	
	configfile="cross-ios-universal.cbc"
	# configfile="cross-ios-arm64.cbc"

	echo "cerberoFolder:$cerberoFolder"
	echo "badSrcFolder:$badSrcFolder"

	if [ "$2" == "c" ] ; then
		echo "clean GStreamer installed folders"
		sudo rm -rf ~/Library/Developer/Xcode/Templates
		sudo rm -rf ~/Library/Developer/GStreamer
	elif [ "$2" == "chmod" ] ; then
		echo "make source files r/w"
		cd $badSrcFolder
		sudo chmod -R 777 .

	elif [ "$2" == "e" ] ; then
		cd $cerberoFolder
		code cerbero/build/recipe.py
		code build/sources/ios_universal/arm64/gstreamer-1.0/subprojects/gst-plugins-bad/sys/applemedia/avfvideosrc.h
		code build/sources/ios_universal/arm64/gstreamer-1.0/subprojects/gst-plugins-bad/sys/applemedia/avfvideosrc.m

	elif [ "$2" == "udp" ] ; then
		echo "GStreamer start udp stream server"
		gst-launch-1.0 -v udpsrc port=5000 caps="application/x-rtp,media=video,encoding-name=H264" ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink

	elif [ "$2" == "b" ] ; then
		echo "build GStreamer..."
		cd $cerberoFolder

		if [ "$3" == "env" ] ; then
			echo "bootstrap, setup environment"
			sudo ./cerbero-uninstalled -c config/$configfile bootstrap
		
		elif [ "$3" == "bad" ] ; then
			echo "build gst-plugins-bad..."
			sudo ./cerbero-uninstalled -c config/$configfile buildone gst-plugins-bad-1.0
		 
		elif [ "$3" == "all" ] ; then
			echo "package GStreamer..."
			ls
			rm -f "gstreamer-1.0-devel-$gstVersion-ios-universal.pkg"
			rm -f "ios-framework-$gstVersion-universal.pkg"
			ls
			sudo ./cerbero-uninstalled -c config/$configfile package gstreamer-1.0 
			open $cerberoFolder
		
		elif [ "$3" == "c" ] ; then
			echo "wipe GStreamer installed folders"
			sudo ./cerbero-uninstalled -c config/$configfile wipe
			sudo rm -rf $cerberoFolder/build
		else
			echo "param 3 not match"
		fi
	
	else
		echo "param 2 not match"
	fi
fi

# open finder
if [ "$1" == "f" ] ; then
	if [ "$2" == "code" ] ; then
		# vs code snippet folders
		open ~/"Library/Application Support/Code/User/snippets"

	else
		open .
	fi
fi

# cd folders && open explorer
if [ "$1" == "cd" ] ; then

	if [ "$2" == "vscode" ] ; then
		# vs code snippet folders
		open ~/"Library/Application Support/Code/User/snippets"

	elif [ "$2" == "gst" ] ; then
		open ~/"Work/libs/cerbero"
	fi
	
	if [ "$2" == "." ] ; then
		open .
	fi	
		
fi

# related
if [ "$1" == "clean" ] ; then

	#  clean pod
	if [ "$2" == "pod" ] ; then
		echo "pod clean, should in project dir"
		# sudo gem install cocoapods-clean
		# rm -rf ~/Library/Caches/CocoaPods
		# rm -rf ~/Library/Developer/Xcode/DerivedData/*
		# rm -rf Pods
		pod deintegrate
		rm -f Podfile.lock

	elif [ "$2" == "ds" ] ; then
		echo "clean *.DS_Store"
		find . -name "*.DS_Store" -exec rm -f {} \; 

	else
		echo "============================================"
		echo "pod >> pod clean, should in project dir"
		echo "ds >> clean *.DS_Store"
		echo "============================================"
	fi

fi

# kill
if [ "$1" == "kill" ] ; then
	sudo ps aux | grep TextInputMenuAgent | awk '{print $2}' | xargs kill -9
	sudo ps aux | grep distnoted | awk '{print $2}' | xargs kill -9
fi

# patch
if [ "$1" == "patch" ] ; then

	if [ "$2" == "gen" ] ; then
		# generate a patch file
		if [ ! -n "$3" ] || [ ! -n "$4" ] || [ ! -n "$5" ] ; then
			echo "param 3 & 4 & 5 shoud not be null"
			echo "diff -uN \"oldFile\" \"newFile\" > patch"
			exit -1
		fi
		
		diff -uN $3 $4 > $5.patch

	elif [ "$2" == "p" ] ; then
		# patch
		if [ ! -n "$3" ] || [ ! -n "$4" ] ; then
			echo "param 3 & 4 shoud not be null"
			exit -1
		fi

		patch $3 < $4

	elif [ "$2" == "r" ] ; then
		# restore 
		if [ ! -n "$3" ] || [ ! -n "$4" ] ; then
			echo "param 3 & 4 shoud not be null"
			exit -1
		fi

		patch -RE $3 < $4

	else
		echo "generate a patch file"
		echo "diff -uN originFile newFile > patchFile"
		
	fi 

fi

# rename project
if [ "$1" == "rename" ] ; then

	if [ ! -n "$2" ] || [ ! -n "$3" ] ; then
		echo "param 3 & 4 shoud not be null"
		exit -1
	fi

	if [ "$4" == "1" ] ; then
		echo "step 1 : rename file content"
		find . -name "*.*" -type f -exec sed -i "" "s/$2/$3/g" {} \; 
	elif [ "$4" == "2" ] ; then
		echo "step 2 : rename file name"
		find . -name "*$2*" -type f -exec rename "s/$2/$3/g" {} \; 	
	elif [ "$4" == "3" ] ; then
		echo "step 3 : rename directory name"
		find . -name "*$2*" -type d -exec rename "s/$2/$3/g" {} \; 
	else
		echo "step 1 : rename file content"
		find . -name "*.*" -type f -exec sed -i "" "s/$2/$3/g" {} \; 
		echo "step 2 : rename file name"
		find . -name "*$2*" -type f -exec rename "s/$2/$3/g" {} \; 
		echo "step 3 : rename directory name"
		find . -name "*$2*" -type d -exec rename "s/$2/$3/g" {} \; 
	fi
fi

# react native related
if [ "$1" == "rn" ] ; then
	
	PackectManagementTool=yarn
	
	# init project
	# PmxHome >> 0.60.5 
	if [ "$2" == "init" ] ; then
		if [ -n "$3" ] ; then
			if [ -z "$4" ] ; then
				npx react-native init $3			
			else
				npx react-native init --version $4 $3
			fi	
		else
			echo "please input project name"
		fi
	fi

	# react-native version
	if [ "$2" == "v" ] ; then
		react-native -v
	fi

	# run project
	if [ "$2" == "x" ] ; then

		if [ -z "$3" ] ; then
			echo "default run iOS"
			npx react-native run-ios
		else
			echo "run android"
			npx react-native run-android
		fi
	fi

	# run metro bunduler
	if [ "$2" == "xnode" ] ; then

		if [ "$3" == "c" ] ; then
			watchman watch-del-all
			npm start -- --reset-cache		
		else
			npm start
		fi
	fi

	# add a react-native module
	if [ "$2" == "module+" ] ; then
		echo "add a react-native module"
		if [ -n "$3" ] ; then
			npm install --save $3
		else
			echo "please input moudle"
		fi
	fi
	if [ "$2" == "module++" ] ; then
		echo "add a react-native module [with link]"
		if [ -n "$3" ] ; then
			npm install --save $3
			react-native link $3
		else
			echo "please input moudle"
		fi
	fi

	# remove a react-native module
	if [ "$2" == "module-" ] ; then
		echo "remove a react-native module"
		if [ -n "$3" ] ; then
			# react-native unlink $3
			npm uninstall --save $3
		else
			echo "please input moudle"
		fi
	fi
	if [ "$2" == "module--" ] ; then
		echo "remove a react-native module [with link]"
		if [ -n "$3" ] ; then
			react-native unlink $3
			npm uninstall --save $3
		else
			echo "please input moudle"
		fi
	fi

	if [ "$2" == "clean" ] ; then
		echo "clean a react-native project"
		cd ios
		xcodebuild clean 

		cd ..
		cd android
		./gradlew clean
	fi

	# change react-native version
	if [ "$2" == "cv" ] ; then
		if [ -n "$3" ] ; then
			npm install react-native@$3
		else
			echo "please input version, ex:0.63.0"
		fi
	fi
	# upgrade react-native version
	if [ "$2" == "uv" ] ; then
		if [ -n "$3" ] ; then
			npx react-native upgrade $3
		else
			npx react-native upgrade		
		fi
	fi

fi

# docker
if [ "$1" == "dk" ] ; then

	if [ "$2" == "i" ] ; then
		# image related
		if  [ "$3" == "ins" ] ; then
			#inspect valume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" == "rm" ] ; then
			echo "========== docker image rm $4 ========== " 
			docker image rm $4
		else
			# list images
			echo "========== docker image ls ========== " 
			docker image ls
		fi

	elif [ "$2" == "c" ] ; then
		# container related
		if  [ "$3" == "ins" ] ; then
			echo "========== docker inspect 'container id'========== " 
			docker inspect $4
		elif  [ "$3" == "stop" ] ; then
			echo "========== docker container stop 'Container ID' ========== " 
			docker container stop $4
		elif  [ "$3" == "rm" ] ; then
			echo "========== docker container rm 'Container ID' ========== " 
			docker container rm $4
		else
			# list containers
			echo "========== docker container ls ========== " 
			docker container ls
		fi
		
	elif [ "$2" == "v" ] ; then

		if  [ "$3" == "ins" ] ; then
			#inspect valume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" == "rm" ] ; then
			# inspect valume
			echo "========== docker volume rm 'Volume Name' ========== " 
			docker volume rm -f $4
		else
			echo "========== docker volume ls ========== " 
			docker volume ls
		fi

	elif [ "$2" == "bash" ] ; then

		if [ -n "$3" ] ; then
			echo "========== docker exec -it $3 bash ========== " 
			docker exec -it $3 bash
		else
			echo ">> container ID needed!"
			echo "========== docker container ls ========== " 
			docker container ls
		fi

	elif [ "$2" == "clean" ] ; then

		if [ "$3" == "all" ] ; then
			# remove all stopped containers, all dangling images, all unused volumes, and all unused networks
			echo "========== docker system prune --volumes ========== " 
			# docker system prune
			docker system prune --volumes

		elif  [ "$3" == "i" ] ; then
			# remove image
			if [ -n "$4" ] ; then
				echo "========== docker image rm $4 ========== " 
				docker image rm $4

				# >> To remove all images which are not referenced by any existing container
				# docker image prune -a 
			else
				echo "========== docker image ls ========== " 
				docker image ls
			fi
		else
			echo "Param 3 not match" 
		fi
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# docker-compose
if [ "$1" == "dkc" ] ; then
	if [ -n "$3" ] ; then
		if [ "$2" == "up" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			# docker-compose -f $3 up -d
			docker-compose -f $3 up
		elif [ "$2" == "down" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
		elif [ "$2" == "r" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
			docker-compose -f $3 up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	else
		if [ "$2" == "up" ] ; then
			echo "========== docker-compose  ========== " 
			docker-compose up -d
		elif [ "$2" == "down" ] ; then
			docker-compose down
		elif [ "$2" == "r" ] ; then
			docker-compose down
			docker-compose up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	fi
fi

# find content
if [ "$1" == "grep" ] ; then

	grep -r $2 .

fi

# dmesg
if [ "$1" == "dmesg" ] ; then

	adb shell cat /proc/kmsg | grep -v 'restore'

fi

# updata file's date tag
if [ "$1" == "uf" ] ; then

	if [ "$2" == "wpas" ] ; then

		cd $prjRoot/$prjDir/android/external/wpa_supplicant_8
		find . -name "*" -exec touch {} \;

	fi
	
	if [ "$2" == "dhd" ] ; then

		cd $prjRoot/$prjDir/kernel/drivers/net/wireless/bcmdhd
		find . -name "*" -exec touch {} \;
	fi

	if [ "$2" == "wl" ] ; then

		cd $prjRoot/$prjDir/android/hardware/libhardware_legacy/wifi
		find . -name "*" -exec touch {} \;
	fi	
	
	if [ "$2" == "jni" ] ; then

		cd $prjRoot/$prjDir/android/frameworks/base/core/jni
		find . -name "android_net_wifi_Wifi.cpp" -exec touch {} \;
	fi	

	if [ "$2" == "fwb_wifi" ] ; then

		cd $prjRoot/$prjDir/android/frameworks/base/wifi/java/android/net
		find . -name "*" -exec touch {} \;
	fi		

	if [ "$2" == "wpasl" ] ; then

		cd $prjRoot/$prjDir/android/hardware/broadcom/wlan/bcmdhd/wpa_supplicant_8_lib
		find . -name "*" -exec touch {} \;
	fi	
		
	if [ "$2" == "wt" ] ; then

		cd $prjRoot/$prjDir/android/system/extras/tests/wifi
		find . -name "*" -exec touch {} \;
	fi	
	
	if [ "$2" == "." ] ; then

		find . -name "*" -exec touch {} \;
	fi

fi


# chmod -R 777
if [ "$1" == "chmod" ] ; then

	if [ "$2" == "wpas" ] ; then

		cd $prjRoot/$prjDir/android/external/
		chmod -R 777 wpa*

	fi
	
	if [ "$2" == "dhd" ] ; then

		cd $prjRoot/$prjDir/kernel/drivers/net/wireless
		chmod -R 777 bcmdhd
	fi

	if [ "$2" == "wl" ] ; then

		cd $prjRoot/$prjDir/android/hardware/libhardware_legacy/wifi
		chmod -R 777 .
	fi	

	if [ "$2" == "fw_wifi" ] ; then

		cd $prjRoot/$prjDir/android/frameworks/base/wifi
		chmod -R 777 .
	fi		

	if [ "$2" == "fw_srv" ] ; then

		cd $prjRoot/$prjDir/android/frameworks/base/services
		chmod -R 777 .
	fi	
	
	if [ "$2" == "wpasl" ] ; then

		cd $prjRoot/$prjDir/android/hardware/broadcom/wlan/bcmdhd/wpa_supplicant_8_lib
		chmod -R 777 .
	fi
	
	if [ "$2" == "wt" ] ; then

		cd $prjRoot/$prjDir/android/system/extras/tests/wifi
		chmod -R 777 .
	fi	

	if [ "$2" == "." ] ; then
	
		chmod -R 777 .
	fi		
fi

# PJSIP
if [ "$1" == "pj" ] ; then
	echo "pjsip...."
	cd /Users/graylin/Work/Prj_RN/lib/source/Vialer-pjsip-iOS-master
	if [ "$2" == "b" ] ; then
		echo "build...."
		./vialerbuild --no-download-pjsip-src --no-clean-pjsip-src --no-bitcode
		# ./vialerbuild --no-download-pjsip-src --no-bitcode
		# ./vialerbuild --no-bitcode

		echo "build....done"		
	fi
	
fi

# zip
if [ "$1" = "zip" ] ; then
    # $2 must exist
    if [ -z "$2" ]; then
        echo "❗ Missing target path (arg 2)"
        echo "Usage: $0 zip <folder/file> [output_name] [bz2|zip|gz]"
        exit 1
    fi

    # default output name if $3 is empty
    if [ -z "$3" ]; then
        # strip trailing slash & extract base name
        out="$(basename "${2%/}")"
    else
        out="$3"
    fi

    # default type = gzip if no $4
    type="$4"

    # === bz2 ===
    if [ "$type" = "bz2" ]; then
        echo ">>>> bz2 $2 to $out.tar.bz2"
        echo "tar -jcvf $out.tar.bz2 \"$2\""
        tar -jcvf "$out.tar.bz2" "$2"

    # === zip ===
    elif [ "$type" = "zip" ]; then
        echo ">>>> zip $2 to $out.zip"
        echo "zip -r $out.zip \"$2\""
        zip -r "$out.zip" "$2"

    # === default: gzip ===
    else
        echo ">>>> gzip $2 to $out.tar.gz"
        echo "tar -zcvf $out.tar.gz \"$2\""
        tar -zcvf "$out.tar.gz" "$2"
    fi
fi
if [ "$1" = "unzip" ] ; then
    echo ">>>> unzip file: $2"

    if [[ "$2" == *.tar.gz || "$2" == *.tgz ]]; then
		echo "tar -zxvf "$2""
        tar -zxvf "$2"
    elif [[ "$2" == *.tar.bz2 || "$2" == *.tbz || "$2" == *.tbz2 ]]; then
		echo "tar -jxvf "$2""
        tar -jxvf "$2"
    else
        echo "Unsupported file format: $2"
    fi
fi

if [ "$1" == "ping" ] ; then
	if [ "$2" == "aic" ] ; then
		echo "ping $AICamera_ip ..."
		ping $AICamera_ip
	fi
fi

# edit x
if [ "$1" == "ex" ] ; then
	echo "edit x...."
	cd $prjRoot/myPath
	gedit x
	echo "edit x....done"
fi

if [ "$1" == "size" ] ; then
    
    # must have a target path
    if [ -z "$2" ]; then
        echo "❗ No target specified!"
        echo "Usage: $0 size <path> [d|m <depth>]"
        exit 1
    fi
    
    # === List directory size (one level) ===
    if [ "$3" == "d" ]; then
        echo "sudo du -h --max-depth=1 \"$2\" | sort -h"
        sudo du -h --max-depth=1 "$2" | sort -h
        exit 0
    fi
    
    # === Max depth mode (m) ===
    if [ "$3" == "m" ] && [ -n "$4" ] && [[ "$4" =~ ^[0-9]+$ ]]; then
        echo "sudo du -h --max-depth=$4 \"$2\" | sort -h"
        sudo du -h --max-depth="$4" "$2" | sort -h
        exit 0
    fi
    
    # === Default: summary only (file or folder size) ===
    echo "sudo du --no-dereference -sh \"$2\""
    sudo du --no-dereference -sh "$2"
fi

