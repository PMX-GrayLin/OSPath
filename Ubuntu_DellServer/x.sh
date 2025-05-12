xDir=~/"OSPath/Ubuntu"

# docker
dockderDir=~/"OSPath/Docker"
# dockderDir=~/"Docker"

# redmine
redDir="$dockderDir/redmine"
redDir_Home="/var/lib/docker/volumes/redmine_vHome/_data"
redDir_Files="/var/lib/docker/volumes/redmine_vFiles/_data"
redDir_Config="/var/lib/docker/volumes/redmine_vConfig/_data"
redDir_Mysql="/var/lib/docker/volumes/redmine_vMysql/_data"
redDir_Postgres="/var/lib/docker/volumes/redmine_vPostgres/_data"

# gitlab
gitDir="$dockderDir/gitlab"
gitDir_Data="/var/lib/docker/volumes/gitlab_vData/_data"
gitDir_Config="/var/lib/docker/volumes/gitlab_vConfig/_data"
gitDir_ConfigR="/var/lib/docker/volumes/gitlab_vConfig_r/_data"
gitDir_Logs="/var/lib/docker/volumes/gitlab_vLogs/_data"
gitBackupFile="1588961756_2020_05_08_12.9.3"

# jenkins
jksDir="$dockderDir/jenkins"
jksDir_Home="/var/lib/docker/volumes/jenkins_vHome/_data"

echo xDir = $xDir
echo "param 0:"$0
echo "param 1:"$1
echo "param 2:"$2
echo "param 3:"$3
echo "param 4:"$4
echo "param 5:"$5
echo "PROJ_ROOT:"$PROJ_ROOT
echo "BUILD_DIR:"$BUILD_DIR

# Test
if [ "$1" = "tt" ] ; then
	cd ~
	
	rd=$(($RANDOM % 2))
	if [ $rd = 0 ] ; then
		echo "0..."

	elif [ $rd = 1 ] ; then
		echo "1..."
	fi

fi

# BitBake
if [ "$1" = "bb" ] ; then
	echo "BitBake..."
	if [  "$2" = "c" ] ; then
		echo "clean recipe... $3"
		# bitbake -c cleansstate $3
		bitbake -c cleanall $3
		
	elif [ "$2" = "b" ] ; then
		echo "build recipe... $3"
		bitbake $3

	elif [ "$2" = "ocv" ] ; then
		echo "only compile recipe... $3, bitbake $3 -c compile"
	    # make build tag
		WORKDIR="$BUILD_DIR/tmp/work/armv8a-poky-linux/primax/1.0-r0"
		touch "$WORKDIR/temp/tag_ignoreBuild_test"

		bitbake $3 -c compile

		rm "$WORKDIR/temp/tag_ignoreBuild"*

	elif [ "$2" = "oct" ] ; then
		echo "only compile recipe... $3, bitbake $3 -c compile"
	    # make build tag
		WORKDIR="$BUILD_DIR/tmp/work/armv8a-poky-linux/primax/1.0-r0"
		touch "$WORKDIR/temp/tag_ignoreBuild_visionBox"

		bitbake $3 -c compile

		rm "$WORKDIR/temp/tag_ignoreBuild"*

	elif [ "$2" = "i" ] ; then
		echo "check recipe info... $3"
		bitbake -e $3 | grep -E "^SRC_URI=|^FILE=|^PV="
	
	elif [ "$2" = "l" ] ; then
		echo "layer..."
		if [  "$3" = "sl" ] ; then
			echo "bitbake-layers show-layers"
			bitbake-layers show-layers

		elif [  "$3" = "sr" ] ; then
			echo "show-recipe..."
			if [ "$4" != "" ] ; then
				bitbake-layers show-recipes | grep $4
			else
				bitbake-layers show-recipes
			fi

		elif [  "$3" = "cl" ] ; then
			echo "bitbake-layers create-layer $4"
			bitbake-layers create-layer $4

		elif [  "$3" = "cr" ] ; then
			echo "bitbake-layers create-recipe $4"
			bitbake-layers create-recipe $4
		fi
	fi
fi

# AI Camera
if [ "$1" = "aic" ] ; then

	echo "========== PROJ_ROOT:$PROJ_ROOT =========="
	aicDir="$dockderDir/AICameraG2"

	if [ "$2" = "dk" ] ; then
		echo "========== docker cmd =========="

		if [ "$3" = "up" ] ; then
			echo "docker-compose -f "$aicDir/docker-compose-aicamerag2.yml" up -d"
			docker-compose -f "$aicDir/docker-compose-aicamerag2.yml" up -d
			# docker-compose -f "$aicDir/docker-compose-aicamerag2.yml" up
		elif [ "$3" = "down" ] ; then
			echo "docker-compose -f "$aicDir/docker-compose-aicamerag2.yml" down"
			docker-compose -f "$aicDir/docker-compose-aicamerag2.yml" down
		elif [ "$3" = "bash" ] ; then
			echo "========== docker exec -it -u root aicamerag2 /bin/bash =========="
			# docker exec -it -u root aicamerag2 /bin/bash
			docker exec -it aicamerag2 /bin/bash
		elif [ "$3" = "log" ] ; then
			echo "========== docker logs -tf jenkins =========="
			docker logs -tf aicamerag2
		fi

	elif [ "$2" = "tcus" ] ; then
		echo "========== update yocto primax src =========="
		cd $PROJ_ROOT/src/meta-primax/recipes-primax/primax/files/primax-1.0/src/Test_C_yocto
		# git reset --hard HEAD
		git pull

	elif [ "$2" = "us" ] ; then
		echo "========== update yocto primax src =========="
		cd $PROJ_ROOT/src/meta-primax/recipes-primax/primax/files/primax-1.0/src/vision_box_DualCam
		# git reset --hard HEAD
		git pull

	elif [ "$2" = "ftp" ] ; then
		echo "========== update files to FTP =========="
		dir_ftp="/mnt/disk2/FTP/Public/gray"

		targetPlatform="armv8a-poky-linux"
		# targetPlatform="genio_700_evk-poky-linux"

		dir_work="$PROJ_ROOT/build/tmp/work/$targetPlatform/primax/1.0-r0"
		cp -f $dir_work/temp/log.do_compile $dir_ftp/
		cp -f $dir_work/primax-1.0/src/vision_box_DualCam/vision_box_DualCam "$dir_ftp/aicamera/"
		cp -f $dir_work/primax-1.0/src/Test_C_yocto/test "$dir_ftp/aicamera/"

	else
		echo "param 2 not match"
		exit -1
	fi
fi

# Yocto
if [ "$1" = "yt" ] ; then
	echo "Yocto..."
	
	if [  "$2" = "b" ] ; then
		echo "build whole image..."
		echo "DISTRO=rity-demo MACHINE=genio-700-evk bitbake rity-demo-image"
		DISTRO=rity-demo MACHINE=genio-700-evk bitbake rity-demo-image

	elif [  "$2" = "bk" ] ; then
		echo "build kernel..."
		echo "MACHINE=genio-700-evk bitbake linux-mtk"
		MACHINE=genio-700-evk bitbake linux-mtk

	elif [  "$2" = "kconf" ] ; then
		echo "kernel config..."
		echo "bitbake virtual/kernel -c menuconfig"
		bitbake virtual/kernel -c menuconfig

	elif [ "$2" = "f" ] ; then

		dtbos_ai="--load-dtbo gpu-mali.dtbo --load-dtbo apusys.dtbo"
		dtbos_codec="--load-dtbo video.dtbo"
		dtbos_cam="--load-dtbo camera-imx214-csi0.dtbo"
		dtbos_dp="--load-dtbo display-dp.dtbo"		

		if [ "$3" = "cam" ] ; then
			echo "===== genio-flash $dtbos_cam $dtbos_codec ====="
			genio-flash $dtbos_cam $dtbos_codec
		elif [ "$3" = "dp" ] ; then
			echo "===== genio-flash $dtbos_dp ====="
			genio-flash $dtbos_dp
		elif [ "$3" = "k" ] ; then
			if [ "$4" = "dp" ] ; then
				echo "genio-flash --load-dtbo display-dp.dtbo kernel mmc0boot1..."
				genio-flash --load-dtbo display-dp.dtbo kernel mmc0boot1
			else 
				echo "genio-flash kernel..."
				genio-flash kernel
			fi
		elif [ "$3" = "all" ] ; then
			echo "===== genio-flash $dtbos_ai $dtbos_codec $dtbos_cam $dtbos_dp ====="
			genio-flash $dtbos_ai $dtbos_codec $dtbos_cam $dtbos_dp
		else
			echo "===== genio-flash ====="
			genio-flash
			#aiot-flash
		fi

	elif [ "$2" = "repo" ] ; then
		echo "repo..."
		repo init -u https://gitlab.com/mediatek/aiot/bsp/manifest.git -b rity/kirkstone -m default.xml
 		repo sync

	elif [ "$2" = "git" ] ; then
		echo "========== git clone org-169115935@github.com:PMX-CTC/C_AI-Camera-G2_FW.git =========="
		git clone org-169115935@github.com:PMX-CTC/C_AI-Camera-G2_FW.git

	elif [ "$2" = "us" ] ; then
		echo "========== update yocto project =========="
		cd ~/C_AI-Camera-G2_FW
		git reset --hard HEAD
		git pull

	elif [ "$2" = "dtb2dts" ] ; then
		echo "========== dtc -I dtb -O dts -o $3.dts $3.dtb =========="
		dtc -I dtb -O dts -o $3.dts $3.dtb

	elif [ "$2" = "dts2dtb" ] ; then
		echo "========== dtc -I dts -O dtb -o $3.dtb $3.dts =========="
		dtc -I dts -O dtb -o $3.dtb $3.dts

	else
		echo "priject env vars..."
		echo "PROJ_ROOT:${PROJ_ROOT}"
		echo "TEMPLATECONF:${TEMPLATECONF}"
		echo "BUILD_DIR:${BUILD_DIR}"
		echo "BB_NUMBER_THREADS:${BB_NUMBER_THREADS}"
		echo "PARALLEL_MAKE:${PARALLEL_MAKE}"
	fi
fi

if [ "$1" = "vb" ] ; then
	echo "VisionHub..."
	if [ "$2" = "f" ] ; then
		echo "flash image..."
		cd /mnt/disk2/FTP/joe_handover/3_VisionHub_AICamera/3_11_images

		if [ "$3" = "barcode" ] ; then
			echo "barcode..."
			image2Flash="vb_barcode_ocr_release_20240709.img"
			sudo dd if=$image2Flash of=/dev/sdd bs=1G status=progress && sync

		elif [ "$3" = "barcode" ] ; then
			echo "glue..."
			image2Flash="vb_dualcam_20240908.img"
			sudo dd if=$image2Flash of=/dev/sdd bs=1G status=progress && sync

		elif [ "$3" = "g1" ] ; then
			image2Flash="vs_g1_s004_testok_20231013.img"
			sudo dd if=$image2Flash of=/dev/sdd bs=1G status=progress && sync

		else
			lsblk | grep "sd"
		fi
	else
		echo "else..."
	fi

fi

# working directory 
if [ "$1" = "wd" ] ; then
	echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP" 
	if [  "$XDG_CURRENT_DESKTOP" = "KDE" ] ; then

		if [ "$2" = "git" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "Docker_Gitlab" --working-directory=$gitDir \
			--tab -T "Docker_Gitlab2" --working-directory=$gitDir \
			--tab -T "Gitlab_Data" --working-directory=$gitDir_Data \
			--tab -T "gitDir_Config" --working-directory=$gitDir_Config \
			--tab -T "Home/Gray" --working-directory=$xDir
		elif [ "$2" = "red" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "Docker_Redmine" --working-directory=$redDir \
			--tab -T "Docker_Redmine2" --working-directory=$redDir \
			--tab -T "Redmine_Home" --working-directory=$redDir_Home \
			--tab -T "Redmine_File" --working-directory=$redDir_Files \
			--tab -T "Redmine_Config" --working-directory=$redDir_Config \
			--tab -T "Postgres" --working-directory=$redDir_Postgres
		elif [ "$2" = "ftp" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "FTP Data" --working-directory="/home/test/FTP/" \
			--tab -T "FTP /etc" --working-directory="/etc" \
			--tab -T "FTP /etc/vsftpd" --working-directory="/etc/vsftpd"
		elif [ "$2" = "jks" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "Docker_Jenkins" --working-directory=$jksDir \
			--tab -T "Docker_Jenkins2" --working-directory=$jksDir \
			--tab -T "Jenkins_Home" --working-directory=$jksDir_Home 
		else
			echo "param 3 not match"
			exit -1
		fi

	elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ] ; then
		if [ "$2" = "git" ] ; then
			gnome-terminal --geometry=140x40 \
			--tab -t "Docker_Gitlab" --working-directory=$gitDir \
			--tab -t "Docker_Gitlab2" --working-directory=$gitDir \
			--tab -t "Gitlab_Data" --working-directory=$gitDir_Data \
			--tab -t "gitDir_Config" --working-directory=$gitDir_Config \
			--tab -t "Home/Gray" --working-directory=$xDir
		elif [ "$2" = "red" ] ; then
			gnome-terminal --geometry=150x40 \
			--tab -t "Docker_Redmine" --working-directory=$redDir \
			--tab -t "Docker_Redmine2" --working-directory=$redDir \
			--tab -t "Redmine_Home" --working-directory=$redDir_Home \
			--tab -t "Redmine_File" --working-directory=$redDir_Files \
			--tab -t "Redmine_Config" --working-directory=$redDir_Config \
			--tab -t "Postgres" --working-directory=$redDir_Postgres
		elif [ "$2" = "ftp" ] ; then
			gnome-terminal --geometry=150x40 \
			--tab -t "FTP Data" --working-directory="/home/test/FTP/" \
			--tab -t "FTP /etc" --working-directory="/etc" \
			--tab -t "FTP /etc/vsftpd" --working-directory="/etc/vsftpd"
		elif [ "$2" = "jks" ] ; then
			gnome-terminal --geometry=150x40 \
			--tab -t "Docker_Jenkins" --working-directory=$jksDir \
			--tab -t "Docker_Jenkins2" --working-directory=$jksDir \
			--tab -t "Jenkins_Home" --working-directory=$jksDir_Home 
		elif [ "$2" = "ros" ] ; then
			xfce4-terminal --geometry=150x40 \
			--tab -T "home" --working-directory=~ \
			--tab -T "wheeltec" --working-directory=~ \
			--tab -T "ROS node" --working-directory=$nodeDir \
			--tab -T "ROS install dir" --working-directory=$rosDir_Home
		else
			echo "param 3 not match"
			exit -1
		fi
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# system related 
if [ "$1" = "sys" ] ; then
	if [ "$2" = "service" ] ; then
		echo "========== Service info =========="
		service --status-all
		#ls /etc/init.d
	elif [ "$2" = "info" ] ; then
		echo "========== System info =========="
		echo "==== Ubuntu version ===="
		cat /etc/os-release
		echo "==== Kernel version ===="
		uname -a
		echo "==== CPU info ===="
		lscpu
		echo "==== Memory info ===="
		free -mh
		echo "==== Disk info ===="
		df -h --total | grep sd
	elif [ "$2" = "users" ] ; then
		# awk -F: '{ print $1}' /etc/passwd
		echo "========== online User =========="
		w

		# list normal users
		echo "========== User range =========="
		grep -E '^UID_MIN|^UID_MAX' /etc/login.defs
		echo "========== User info =========="
		getent passwd {1000..60000}

	elif [ "$2" = "user" ] ; then
		id -nG $3
	elif [ "$2" = "net" ] ; then
		echo "========== nmap -A 192.168.100.* =========="
		nmap -A 192.168.100.*
	else
		echo "param 3 not match"
		exit -1
	fi
fi

# copy to
if [ "$1" = "cp" ] ; then

	if [ "$2" = "h" ] ; then
		path="$HOME"
	elif [ "$2" = "ftp" ] ; then
		path="/mnt/disk2/FTP/Public/gray"
	elif [ "$2" = "aic" ] ; then
		path="/mnt/disk2/FTP/Public/gray/aicamera"
	elif [ "$2" = "ccm" ] ; then
		path="/mnt/disk2/FTP/Public/gray/aicamera/ccm_db"
	fi
	echo "cp -rf $3 $path"
	cp -rf $3 $path 
fi

# gedit
if [ "$1" = "ge" ] ; then
	if [ "$2" = "x" ] ; then
		cd $xDir
		gedit x.sh
	elif [ -n "$2" ] ; then
		gedit $2
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# vs code
if [ "$1" = "code" ] ; then
	if [ "$2" = "x" ] ; then
		code $xDir/x.sh
	elif [ "$2" = ".rc" ] ; then
		code ~/.bashrc
	elif [ "$2" = "s" ] ; then
		code $xDir/s.sh
	elif [ -n "$2" ] ; then
		echo "do nothing"
	else
		echo "param 2 not match"
		exit -1
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

# ftp
if [ "$1" = "ftp" ] ; then
	if [ "$2" = "restart" ] ; then
		service vsftpd restart
		sleep 1
		service vsftpd status
	elif [ "$2" = "status" ] ; then
		service vsftpd status
	elif [ "$2" = "stop" ] ; then
		service vsftpd stop
	elif [ "$2" = "d+g" ] ; then
		# add group access for some dir
		echo "ex : sudo setfacl -Rdm g:SAC_EE:rwx DirName/"
		echo "sudo setfacl -Rdm g:$4:rwx $3"
		sudo setfacl -Rdm g:$4:rwx $3
	elif [ "$2" = "config" ] ; then
		code /etc/vsftpd.conf
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# user
if [ "$1" = "user" ] ; then
	mainGroup="CCP"
	subGroup="docker"

	if [ "$2" = "+" ] ; then
		if [ -n "$3" ] ; then

			if [ "$4" = "all" ] ; then
				subGroup="sudo,adm,lpadm,docker"
			fi

			sudo useradd -m $3 -g $mainGroup -G $subGroup -s /bin/bash
			
			echo "$3:$3" | sudo chpasswd
			sudo chage -d 0 $3
			sudo chage -l $3 | head -n 3
		else
			echo "param 3 needed"
		fi
	elif [ "$2" = "-" ] ; then
		sudo userdel -r $3

	elif [ "$2" = "+g" ] ; then
		sudo usermod -aG $3 $4

	elif [ "$2" = "+yt" ] ; then

		if [ -n "$3" ] ; then
			# make a yocto build dir & user link
			buildfolder="/mnt/disk2/yocto_build_folder"
			mkdir $buildfolder/$3
			cp $buildfolder/misc/step* $buildfolder/$3
			sudo chown $3:$mainGroup $buildfolder/$3
			sudo chown $3:$mainGroup $buildfolder/$3/step*
			cd /home/$3
			sudo ln -s /mnt/disk2/yocto_build_folder/$3 yocto_build_folder
			sudo chown $3:$mainGroup yocto_build_folder
		else 
			echo "param 3 needed"
		fi

	elif [ "$2" = "-yt" ] ; then

		if [ -n "$3" ] ; then
			# make a yocto build dir & user link
			buildfolder="/mnt/disk2/yocto_build_folder"
			sudo rm -r $buildfolder/$3
		else 
			echo "param 3 needed"
		fi

	fi
fi

# logout
if [ "$1" = "logout" ] ; then
	gnome-session-quit
fi

# file manager
if [ "$1" = "cd" ] ; then
	echo "XDG_CURRENT_DESKTOP:$XDG_CURRENT_DESKTOP" 
	if [  "$XDG_CURRENT_DESKTOP" = "KDE" ] ; then
			dolphin $2
		elif [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ] ; then
			nautilus $2
		else
			echo "param 2 not match"
			exit -1
		fi
fi

# chown
if [ "$1" = "chown" ] ; then
	if [ -n "$2" ] ; then
		if [ "$2" = "all" ] ; then
			sudo chown -R nobody:nogroup .
		else
			sudo chown nobody:nogroup $2
		fi
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

# chmod
if [ "$1" = "chmod" ] ; then
	if [ -n "$2" ] ; then
		if [ "$2" = "all" ] ; then
			if [ "$3" = "4" ] ; then
				sudo chmod -R 444 .
			elif [ "$3" = "6" ] ; then
				sudo chmod -R 666 .
			else
				sudo chmod -R 777 .
			fi
		elif [ "$2" = "dir" ] ; then
			echo "change only dir..."
			echo "find $3 -type d -exec sudo chmod 777 {} \;"
			find $3 -type d -exec sudo chmod 777 {} \;
		else
			if [ "$3" = "4" ] ; then
				sudo chmod -R 444 $2
			elif [ "$3" = "6" ] ; then
				sudo chmod -R 666 $2
			else
				sudo chmod -R 777 $2
			fi
		fi
	fi
fi

# ssh
if [ "$1" = "ssh" ] ; then
	if [ "$2" = "status" ] ; then
		service sshd status

	elif [ "$2" == "wt" ] ; then
		# wheeltech
		if [ "$3" = "r" ] ; then
			ssh -Y root@$wheeltec_ip
		else
			echo "ssh -Y wheeltec@$wheeltec_ip"
			ssh -Y wheeltec@$wheeltec_ip
		fi
		
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# redmine
if [ "$1" = "red" ] ; then

	if [ "$2" = "up" ] ; then
		docker-compose -f "$redDir/docker-compose-red.yml" up -d
		# docker-compose -f "$redDir/docker-compose-red.yml" up
	elif [ "$2" = "down" ] ; then
		docker-compose -f "$redDir/docker-compose-red.yml" down
	elif [ "$2" = "start" ] ; then
		docker-compose -f "$redDir/docker-compose-red.yml" start
	elif [ "$2" = "stop" ] ; then
		docker-compose -f "$redDir/docker-compose-red.yml" stop
	elif [ "$2" = "bash" ] ; then
		echo "========== docker exec -it redmine /bin/bash =========="
		docker exec -ti redmine /bin/bash
	elif [ "$2" = "chmod" ] ; then
		sudo chmod 777 $redDir_Config/
		sudo chmod 777 $redDir_Config/configuration.yml
		sudo chmod 777 $redDir/data.yml
		sudo chmod 777 $redDir/configuration.yml
		sudo chmod 777 $redDir_Files/
		sudo chmod 777 $redDir_Postgres/
		sudo chmod 777 $redDir_Postgres/redmine.sqlc

	elif [ "$2" = "config" ] ; then
		echo "========== docker exec -it redmine /bin/bash =========="
		if [ "$3" = "in" ] ; then
			sudo chmod 777 $redDir_Config
			sudo cp $redDir/configuration.yml $redDir_Config
		elif [ "$3" = "out" ] ; then
			sudo cp $redDir_Config/configuration.yml.example $redDir/configuration.yml.example
			sudo chmod  666 $redDir/configuration.yml.example
		elif [ "$3" = "code" ] ; then
			code $redDir/configuration.yml 
			code $redDir/configuration.yml.example
		else
			echo ">> param 3 should be 'in' or 'out'"
		fi

	elif [ "$2" = "files" ] ; then
		if [ "$3" = "in" ] ; then
			sudo chmod 777 $redDir_Mysql
			sudo cp $nasDir/redmine/redmine_backup_mysql.sql $redDir_Mysql
			sudo chmod 777 $redDir_Files
			sudo cp $nasDir/redmine/redmine_backup_files.tar.gz $redDir_Files
		elif [ "$3" = "out" ] ; then
			echo ">> do nothing"
		else
			echo ">> param 3 should be 'in' or 'out'"
		fi

	elif [ "$2" = "data" ] ; then
		# data.yml file
		if [ "$3" = "in" ] ; then
			sudo cp $redDir/data.yml $redDir_Home/db/
		elif [ "$3" = "out" ] ; then
			sudo cp $redDir_Home/db/data.yml $redDir/
		elif [ "$3" = "install" ] ; then
			# install yaml_db
			docker exec -it redmine bundle install
		else
			echo ">> param 3 should be 'in' or 'out'"
		fi
	elif [ "$2" = "mysql" ] ; then
		# mysql bash
		echo "========== docker exec -it mysql /bin/bash =========="
		docker exec -ti mysql /bin/bash
	elif [ "$2" = "psql" ] ; then
		# postgres bash
		echo "========== docker exec -it postgres /bin/bash =========="
		docker exec -ti postgres /bin/bash
	elif [ "$2" = "log" ] ; then
		echo "========== docker logs -tf redmine =========="
		docker logs -tf redmine
	elif [ "$2" = "backup" ] ; then
		# use pg_dump
		docker exec -it postgres pg_dump -U postgres -Fc --file=var/lib/postgresql/redmine.sqlc redmine

		# use yaml_db
		docker exec -it redmine rake db:data:dump
	elif [ "$2" = "restore" ] ; then
		# use pg_dump >> not work yet
		# docker exec -it postgres pg_dump -U postgres -Fc --file=var/lib/postgresql/redmine.sqlc redmine

		# use yaml_db
		docker exec -it redmine rake db:data:load
	elif [ "$2" = "compose" ] ; then
		# open compose file
		code $redDir/docker-compose-red.yml

	elif [ "$2" = "gem" ] ; then
		sudo chmod 777 $redDir_Home/Gemfile
		code $redDir_Home/Gemfile
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# gitlab
if [ "$1" = "git" ] ; then
	if [ "$2" = "up" ] ; then
		docker-compose -f "$gitDir/docker-compose-git.yml" up -d
		# docker-compose -f "$gitDir/docker-compose-git.yml" up
	elif [ "$2" = "down" ] ; then
		docker-compose -f "$gitDir/docker-compose-git.yml" down
	elif [ "$2" = "stop" ] ; then
		docker stop gitlab
		
	elif [ "$2" = "chmod" ] ; then
		sudo chmod 755 $gitDir_Data/backups/
		sudo chmod 755 $gitDir_Data/backups/
		sudo chmod 777 $gitDir_Config/gitlab.rb
		sudo chmod 777 $gitDir_Config/gitlab-secrets.json 

	elif [ "$2" = "tar" ] ; then
		# backup tar file
		sudo chmod 755 $gitDir_Data/backups/
		if [ "$3" = "in" ] ; then
			sudo mv $gitDir/$gitBackupFile"_gitlab_backup.tar" $gitDir_Data/backups/
		elif [ "$3" = "out" ] ; then
			sudo mv $gitDir_Data/backups/$gitBackupFile"_gitlab_backup.tar" $gitDir/
		else
			echo ">> param 3 should be 'in' or 'out'"
		fi
	elif [ "$2" = "compose" ] ; then
		# open compose file
		code $gitDir/docker-compose-git.yml
		
	elif [ "$2" = "config" ] ; then
		if [ "$3" = "code" ] ; then
			code $gitDir/config/gitlab.rb
			code $gitDir/config/gitlab.yml
		elif [ "$3" = "in" ] ; then
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
		elif [ "$3" = "out" ] ; then
			sudo chmod 755 $gitDir_ConfigR
sudo chmod 666 $gitDir_Config/gitlab.rb
			sudo chmod 666 $gitDir_ConfigR/gitlab.yml 
			cp $gitDir_Config/gitlab.rb $gitDir/config/
			cp $gitDir_ConfigR/gitlab.yml $gitDir/config
		elif [ "$3" = "update" ] ; then
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
			echo "========== docker exec -it gitlab gitlab-ctl reconfigure =========="
			docker exec -it gitlab gitlab-ctl reconfigure
			echo "========== docker exec -it gitlab gitlab-ctl restart =========="
			docker exec -it gitlab gitlab-ctl restart
		else
			echo ">> param 3 not match"
		fi
	elif [ "$2" = "check" ] ; then
		echo "========== docker exec -it gitlab gitlab-rake gitlab:check SANITIZE=true =========="
		docker exec -ti gitlab gitlab-rake gitlab:check SANITIZE=true
	elif [ "$2" = "info" ] ; then
		echo "========== docker exec -ti gitlab gitlab-rake gitlab:env:info =========="
		docker exec -ti gitlab gitlab-rake gitlab:env:info
	elif [ "$2" = "bash" ] ; then
		echo "========== docker exec -it gitlab /bin/bash =========="
		docker exec -ti gitlab /bin/bash
	elif [ "$2" = "psql" ] ; then
		echo "========== docker exec -it gitlab gitlab-psql =========="
		docker exec -ti gitlab gitlab-psql
	elif [ "$2" = "rail" ] ; then
		echo "========== docker exec -it gitlab gitlab-rails console =========="
		docker exec -ti gitlab gitlab-rails console
	elif [ "$2" = "log" ] ; then
		echo "========== docker logs -tf gitlab =========="
		docker logs -tf --since 1m gitlab
	elif [ "$2" = "backup" ] ; then
		echo "========== docker exec -it gitlab gitlab-rake gitlab:backup:create =========="
			docker exec -ti gitlab gitlab-backup create

			# GitLab 12.1 and earlier
			# docker exec -ti gitlab gitlab-rake gitlab:backup:create
	elif [ "$2" = "restore" ] ; then
		if [ "$3" = "1" ] ; then
			echo "========== step 1 : stop connectivity services ==========" 
			# docker exec -it gitlab gitlab-ctl stop unicorn
docker exec -it gitlab gitlab-ctl stop puma
			docker exec -it gitlab gitlab-ctl stop sidekiq
			docker exec -it gitlab gitlab-ctl status
		elif [ "$3" = "2" ] ; then
			echo "========== step 2 : restore from backup tar : $gitBackupFile ==========" 
			docker exec -it gitlab gitlab-backup restore BACKUP=$gitBackupFile

# gitlab-backup restore BACKUP=1643394275_2022_01_28_14.1.6
			# GitLab 12.1 and earlier
			# docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=$gitBackupFile
		elif [ "$3" = "3" ] ; then
			echo "========== step 3 : re-configure & re-start ==========" 
			echo "========== docker exec -it gitlab gitlab-ctl reconfigure =========="
			docker exec -it gitlab gitlab-ctl reconfigure
			echo "========== docker exec -it gitlab gitlab-ctl restart =========="
			docker exec -it gitlab gitlab-ctl restart

		elif [ "$3" = "4" ] ; then
			# config
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
		else
			echo ">> param 3 not match"
		fi

	elif [ "$2" = "sp" ] ; then
		# show related path
		echo "========== gitlab paths  ==========" 
		echo "# docker mapping dir in host" 
		echo "gitDir_Data:$gitDir_Data"
		echo "gitDir_Config:$gitDir_Config"
		echo "gitDir_Logs:$gitDir_Logs"
		echo "" 
		echo "# gitlab home (Omnibus)" 
		echo "/var/opt/gitlab/"
		echo "" 
		echo "# gitlab home (Source)" 
		echo "/home/git/gitlab/"
		echo "" 
		echo "# configuration file" 
		echo "/etc/gitlab/gitlab.rb"
		echo "" 
		echo "# generated configuration file" 
		echo "/opt/gitlab/embedded/service/gitlab-rails/config"
		echo "" 
		echo "# backup folder" 
		echo "/var/opt/gitlab/backups/"
		echo "" 
		echo "# ssl cert folder" 
		echo "/etc/gitlab/ssl/"
		
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# jenkins
if [ "$1" = "jks" ] ; then

	if [ "$2" = "up" ] ; then
		docker-compose -f "$jksDir/docker-compose-jenkins.yml" up -d
		# docker-compose -f "$jksDir/docker-compose-jenkins.yml" up
	elif [ "$2" = "down" ] ; then
		docker-compose -f "$jksDir/docker-compose-jenkins.yml" down
	elif [ "$2" = "bash" ] ; then
		echo "========== docker exec -it -u root jenkins /bin/bash =========="
		docker exec -it -u root jenkins /bin/bash
elif [ "$2" = "log" ] ; then
		echo "========== docker logs -tf jenkins =========="
		docker logs -tf jenkins
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# docker
if [ "$1" = "dk" ] ; then

	if [ "$2" = "i" ] ; then
		# image related
		if  [ "$3" = "ins" ] ; then
			#inspect volume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" = "rm" ] ; then
			echo "========== docker image rm $4 ========== " 
			docker image rm $4
		else
			# list images
			echo "========== docker image ls ========== " 
			docker image ls
		fi

	elif [ "$2" = "c" ] ; then
		# container related
		if  [ "$3" = "ins" ] ; then
			echo "========== docker inspect 'container id'========== " 
			docker inspect $4
		elif  [ "$3" = "stop" ] ; then
			echo "========== docker container stop 'Container ID' ========== " 
			docker container stop $4
		elif  [ "$3" = "rm" ] ; then
			echo "========== docker container rm 'Container ID' ========== " 
			
			# remove all stoped container
			docker rm $(docker ps -a -q) 

			docker container rm -f $4
		else
			# list containers
			echo "========== docker container ls ========== " 
			docker container ls
		fi
		
	elif [ "$2" = "v" ] ; then

		if  [ "$3" = "ins" ] ; then
			#inspect valume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" = "rm" ] ; then
			# inspect valume
			echo "========== docker volume rm 'Volume Name' ========== " 
			docker volume rm -f $4
		else
			echo "========== docker volume ls ========== " 
			docker volume ls
		fi

	elif [ "$2" = "bash" ] ; then

		if [ -n "$3" ] ; then
			echo "========== docker exec -it $3 bash ========== " 
			docker exec -it $3 bash
		else
			echo ">> container ID needed!"
			echo "========== docker container ls ========== " 
			docker container ls
		fi

	elif [ "$2" = "clean" ] ; then

		if [ "$3" = "all" ] ; then
			# remove all stopped containers, all dangling images, all unused volumes, and all unused networks
			echo "========== docker system prune --volumes ========== " 
			# docker system prune
			docker system prune --volumes

		elif  [ "$3" = "i" ] ; then
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
if [ "$1" = "dkc" ] ; then
	if [ -n "$3" ] ; then
		if [ "$2" = "up" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			# docker-compose -f $3 up -d
			docker-compose -f $3 up
		elif [ "$2" = "down" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
		elif [ "$2" = "r" ] ; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
			docker-compose -f $3 up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	else
		if [ "$2" = "up" ] ; then
			echo "========== docker-compose  ========== " 
			docker-compose up -d
		elif [ "$2" = "down" ] ; then
			docker-compose down
		elif [ "$2" = "r" ] ; then
			docker-compose down
			docker-compose up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	fi
fi

# nfs
if [ "$1" == "nfs" ] ; then
	echo "========== NFS "==========
	if [ "$2" = "e" ] ; then
		echo "========== edit conf file ========== " 
		sudo nano /etc/exports

	elif [ "$2" = "mkdir" ] ; then
		echo "========== make nfs dir ========== " 
		sudo mkdir -p $3
		sudo chown nobody:nogroup /srv/nfs/data
		sudo chmod 777 /srv/nfs/data

	elif [ "$2" = "r" ] ; then
		sudo exportfs -ra
		sudo systemctl restart nfs-kernel-server

	elif [ "$2" = "start" ] ; then

		sudo systemctl start nfs-kernel-server

	elif [ "$2" = "stop" ] ; then
		sudo systemctl stop nfs-kernel-server

	elif [ "$2" = "port" ] ; then
		sudo ufw allow from 10.0.0.0/8 to any port 111
		sudo ufw allow from 10.0.0.0/8 to any port 2049
		sudo ufw allow from 10.0.0.0/8 to any port 13025

	else
		sudo exportfs -v
		sudo systemctl status nfs-kernel-server
		rpcinfo -p
	fi

fi

# update x
if [ "$1" == "ux" ] ; then
	cd ~/OSPath
	git reset --hard HEAD
	git pull
	sudo chmod 777 Ubuntu_DellServer/x.sh
fi

# find content
if [ "$1" == "grep" ] ; then
	grep -r $2 .
fi

# find file
if [ "$1" == "find" ] ; then
	echo "find . -name $2"
	find . -name $2
fi

# file / folder size
if [ "$1" == "size" ] ; then
	du -sh $2
fi

