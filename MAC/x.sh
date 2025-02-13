echo "param 0:"$0
echo "param 1:"$1
echo "param 2:"$2
echo "param 3:"$3
echo "param 4:"$4
echo "param 5:"$5

xDir=~/OSPath/MAC
RNFolder=~/Work/Prj_RN
piDir=~/Work/pi4

dockderDir=~/"Docker"
u18dir=$dockderDir/Ubuntu1804
BCTTestDir=~/Work/MFi-HomeKit/BCT
# echo "u18dir:$u18dir"

# adkPath="/Users/graylin/Work/MFi-HomeKit/HomeKit ADK 4.0"
# adkPath="/Users/graylin/Work/MFi-HomeKit/HomeKit ADK 5.1"
# adkPath="/Users/graylin/Work/MFi-HomeKit/HomeKit ADK 5.2"
adkPath="/Users/graylin/Work/MFi-HomeKit/HomeKit ADK 5.3"

currentDateTime=`date "+%m%d%H%M"`

# wheeltec
wheeltec_ip="192.168.1.196"

# VisionBox
VisionBox_ip="192.168.1.13"
AICamera_ip="192.168.1.65"
# AICamera_ip="192.168.1.66"
# AICamera_ip="192.168.1.67"
# AICamera_ip="192.168.1.204"
DellServer_ip="10.1.13.207"

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

# SSH
if [ "$1" == "ssh" ] ; then

	if [ "$2" == "dell" ] ; then

		## ctcfw/Primax1234
		if [ "$3" != "" ] ; then
			ssh $3@$DellServer_ip
		else 
			ssh gray.lin@$DellServer_ip
		fi

	elif [ "$2" == "pi" ] ; then
		ssh pi@raspberrypi.local
	
	elif [ "$2" == "vb" ] ; then
		echo "ssh -Y user@$VisionBox_ip"
		ssh -Y user@$VisionBox_ip

	elif [ "$2" == "aic" ] ; then
		if [ "$3" == "r" ] ; then
			echo "ssh-keygen -R $AICamera_ip"
			ssh-keygen -R $AICamera_ip
		fi
		echo "ssh root@$AICamera_ip"
		ssh root@$AICamera_ip

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
	if [ "$2" == "xx" ] ; then
		echo ""
	elif [ "$2" == "aic" ] ; then
		# user="ubuntu"
		# pass="primax1234"
		user="root"
		pass=""
		remoteFolder=""
		# remoteFolder="~/primax/apps"
		if [ "$3" == "up" ] ; then
			echo "sudo sshpass scp $4 $user@$AICamera_ip:$remoteFolder/$5"
			sshpass scp ./$4 $user@$AICamera_ip:$remoteFolder/$5
		elif [ "$3" == "down" ] ; then
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

# ADK
if [ "$1" == "adk" ] ; then

	buildType=Debug
	# buildType=Test
	# buildType=Release

	if [ "$2" == "update" ] ; then
		rsync -av --delete -e "ssh" "/Users/graylin/Work/MFi-HomeKit/adk_pi/" "pi@raspberrypi.local:/home/pi/x_adk/"
		# rsync -av --delete -e "ssh" "pi@raspberrypi.local:/home/pi/x_adk/" "/Users/graylin/Work/MFi-HomeKit/adk_pi/"
	elif [ "$2" == "b" ] ; then
		# build
		echo "build path : $adkPath"
		cd "$adkPath"
		if [ "$3" == "app" ] ; then
			echo "build app >>>>"
			make USE_WAC=1 BUILD_TYPE=$buildType TARGET=Raspi apps
			# make USE_WAC=1 USE_HW_AUTH=1 BUILD_TYPE=$buildType TARGET=Raspi apps
		elif [ "$3" == "sc" ] ; then
			echo "build setup code >>>>"
			# setup code
			# 5 >> Lighting
			# 6 >> Locks *
			# 17 >> IP Cameras *
			# 18 >> Video Doorbells *
			accCategory=0
			if [ -n "$4" ] ; then
				accCategory=$4
			else 
				accCategory=18
			fi
			echo "build setup code >>>> category $accCategory"

			# deploy to device via ssh
			# ./Tools/provision_raspi.sh --wac --category $accCategory pi@raspberrypi.local:~/.HomeKitStore

			# generate local
			# 4.0
			# ./Tools/provision_raspi.sh --wac --category $accCategory ~/.HomeKitStore
			# ./Tools/provision_raspi.sh --wac --nfc --category $accCategory ~/.HomeKitStore

			# 5.1, 5.2
			./Tools/provision_posix.sh --wac --nfc --category $accCategory --product-data 1E903F6D20F2B2D8 \
			--mfi-token DF0DBBE5-F6F1-4786-8E6E-DFC0EB764B28 MYGrME4CAQECAQEERjBEAiBq/VghvdwObWRuSlmevmhldF4vfcjq/ZbXKxJftw5P/wIgVGBjfiN/8YOZs9Hb40AIoUkWMMrrVFQggVoXW5L9wWUwWQIBAgIBAQRRMU8wCQIBZgIBAQQBATAQAgFlAgEBBAjL5CdgeAEAADAWAgIAyQIBAQQNMTAwMjc3LTczMDU0MjAYAgFnAgEBBBDUP3MGTj1OCZ88goIKcYPs \
			pi@raspberrypi.local:~/.HomeKitStore

		elif [ "$3" == "c" ] ; then
			echo "clean >>>>"
			make TARGET=Raspi clean
		else
			echo "param 3 not match"
			exit -1
		fi

	elif [ "$2" == "cp" ] ; then

		cd "$adkPath"
		exefile=""
		if [ -z "$3"  ] ; then
			echo "param 3 empty"
			exit -1
		elif [ "$3" == "lb" ] ; then
			exefile="Lightbulb"
		elif [ "$3" == "vd" ] ; then
			exefile="VideoDoorbell"
		elif [ "$3" == "ipc" ] ; then
			exefile="IPCamera"
		elif [ "$3" == "ipcer" ] ; then
			exefile="IPCameraEventRecorder"	
		elif [ "$3" == "sl" ] ; then
			exefile="SeaLion"	
		else
			echo "param 3 not match"
			exit -1
		fi

		echo "install $exefile.OpenSSL >>>>"

		# adk's script
		# ./Tools/install.sh \
		# -d raspi \
		# -a Output/Raspi-armv6k-unknown-linux-gnueabihf/$buildType/IP/Applications/$exefile.OpenSSL \
		# -n raspberrypi \
		# -p raspberry

		# also work, but need password input
		# scp Output/Raspi-armv6k-unknown-linux-gnueabihf/$buildType/IP/Applications/$exefile.OpenSSL pi@raspberrypi.local:~

  expect <<EOF
  set timeout -1
  spawn scp Output/Raspi-armv6k-unknown-linux-gnueabihf/$buildType/IP/Applications/$exefile.OpenSSL pi@raspberrypi.local:~
  expect {
      "password:"  { send "raspberry\n"; exp_continue }
      eof
  }
  lassign [wait] pid spawnID osError value
  exit \$value
EOF

	elif [ "$2" == "ux" ] ; then
  expect <<EOF
  set timeout -1
  spawn scp /Users/graylin/Work/MFi-HomeKit/RaspberryPi/x.sh pi@raspberrypi.local:~/Gray
  expect {
      "password:"  { send "raspberry\n"; exp_continue }
      eof
  }
  lassign [wait] pid spawnID osError value
  exit \$value
EOF

	elif [ "$2" == "bct" ] ; then

		workingDirString="BCT-Belkin-Sealion-WiFi-$currentDateTime"

		if [ "$3" == "" ] ; then
			interface="en0"
		else 
			interface="$3"
		fi

		# if [ "$4" == "" ] ; then
		# 	interface="en0"
		# else 
		# 	interface="$3"
		# fi

		echo "run BCT Test... -I $interface"

		cd $BCTTestDir
		mkdir $workingDirString
		cp BonjourConformanceTest ./$workingDirString/
		cd $workingDirString
		sudo ./BonjourConformanceTest -I $interface -D -F Result-Belkin-Sealion-WiFi.txt -Aip 169.254.90.249 -Amac 6C:70:9F:D7:54:04
		rm BonjourConformanceTest
	else
		echo "param 2 not match"
		exit -1
	fi
		
fi

# vs code
if [ "$1" == "code" ] ; then
	if [ "$2" == "x" ] ; then
		if [ "$3" == "pi" ] ; then
			code "$piDir/x.sh"
		else
			code "$xDir/x.sh"
		fi
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

# restore code
if [ "$1" == "rs" ] ; then

	echo "restore code"
	echo "RNFolder:"$RNFolder
	SrcFolder=$RNFolder/backup
	DstFolder=$RNFolder/PmxHome/node_modules

	echo "SrcFolder:"$SrcFolder
	echo "DstFolder:"$DstFolder

	# vlcplayer
	cp -f -r $SrcFolder/react-native-yz-vlcplayer $DstFolder

	# pjsip
	cp -f -r $SrcFolder/react-native-pjsip $DstFolder
	rm $DstFolder/react-native-pjsip/ios/VialerPJSIP.framework

fi

# backup code
if [ "$1" == "bk" ] ; then

	echo "backup code"
	echo "RNFolder:"$RNFolder
	SrcFolder=$RNFolder/PmxHome/node_modules
	DstFolder=$RNFolder/backup

	echo "SrcFolder:"$SrcFolder
	echo "DstFolder:"$DstFolder

	# vlcplayer
	cp -f -r $SrcFolder/react-native-yz-vlcplayer $DstFolder

	# pjsip
	cp -f -r $SrcFolder/react-native-pjsip $DstFolder

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

# ubuntu 18.04 in docker
if [ "$1" == "u18" ] ; then

	if [ "$2" == "up" ] ; then
		docker-compose -f "$u18dir/docker-compose.yml" up -d
	elif [ "$2" == "down" ] ; then
		docker-compose -f "$u18dir/docker-compose.yml" down
	elif [ "$2" == "bash" ] ; then
		echo "========== docker exec -it -u root jenkins /bin/bash =========="
		docker exec -it -u root Ubuntu18 /bin/bash
	elif [ "$2" == "log" ] ; then
		echo "========== docker logs -tf jenkins =========="
		docker logs -tf Ubuntu18
	else
		echo "param 2 not match"
		exit -1
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

# tar
if [ "$1" = "zip" ] ; then
		echo ">>>> zip $2 to $3.tar.gz"
		tar -czvf $3.tar.gz $2
fi
if [ "$1" = "unzip" ] ; then
		echo ">>>> unzip file"
		tar -xzvf $2
fi


# RB5
if [ "$1" == "pi" ] ; then

	if [ "$2" == "ux" ] ; then
		echo "update x.sh...."

expect <<EOF
  set timeout -1
  spawn scp $piDir/x.sh pi@raspberrypi.local:~/Gray
  expect {
      "password:"  { send "raspberry\n"; exp_continue }
      eof
  }
  lassign [wait] pid spawnID osError value
  exit \$value
EOF

	fi
fi

# Raspberry pi
if [ "$1" == "pi" ] ; then

	if [ "$2" == "ux" ] ; then
		echo "update x.sh...."

expect <<EOF
  set timeout -1
  spawn scp $piDir/x.sh pi@raspberrypi.local:~/Gray
  expect {
      "password:"  { send "raspberry\n"; exp_continue }
      eof
  }
  lassign [wait] pid spawnID osError value
  exit \$value
EOF

	elif [ "$2" == "wpas" ] ; then
		echo "wpas...."
		if [ "$3" == "fd" ] ; then	
			echo "file download...."

# expect <<EOF
#   set timeout -1
#   spawn scp pi@raspberrypi.local:/etc/wpa_supplicant/wpa_supplicant.conf $piDir/ 
#   expect {
#       "password:"  { send "raspberry\n"; exp_continue }
#       eof
#   }
#   lassign [wait] pid spawnID osError value
#   exit \$value
# EOF			

		elif [ "$3" == "fu" ] ; then
			echo "file upload...."

		else 
			echo "...."
		fi

	else
		echo "...."
  	fi

fi

# Old ==========================================================================

#build related command
if [ "$1" == "b" ] ; then
	echo "build...."
	

	echo "build....done"
	
fi

# flash related command
if [ "$1" == "f" ] ; then
	echo "flash...."
	
 
	echo "flash....done"
fi

# edit x
if [ "$1" == "ex" ] ; then
	echo "edit x...."
	cd $prjRoot/myPath
	gedit x
	echo "edit x....done"
fi

# reboot
if [ "$1" == "r" ] ; then
	echo "reboot...."
	adb shell reboot
	echo "reboot....done"
fi

# file / folder size
if [ "$1" == "size" ] ; then
	du -sh $2
fi

