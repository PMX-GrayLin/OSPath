xDir=~/"OSPath/Ubuntu"

# docker
dockderDir=~/"Docker"

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

# ROS
rosDir_Home="/opt/ros/humble"
# testNode="lcd_set_emoji"
testNode="ctrl_head"
# testNode="lidar_ao_oasab0512"
nodeDir=~/"$testNode"

# NAS
nasDir="$dockderDir/nas"

# wheeltec
wheeltec_ip="192.168.1.196"

echo xDir		= $xDir
echo "param 0:"$0
echo "param 1:"$1
echo "param 2:"$2
echo "param 3:"$3
echo "param 4:"$4
echo "param 5:"$5

# AI Camera
if [ "$1" = "aic" ] ; then
	echo "========== AI Camera =========="
	DellServer_ip="10.1.13.207"
	if [ "$2" = "nfs" ] ; then
		# nfs mount dir
		dir_nfs_remote="/home/gray.lin/iot-yocto-mtk"
		dir_nfs="~/nfs-share"

		if [  "$3" = "+" ] ; then
			sudo mount $DellServer_ip:$dir_nfs_remote $dir_nfs
		elif [  "$3" = "-" ] ; then
			sudo umount $dir_nfs
		fi

	fi
fi

# wheeltec
if [ "$1" = "wt" ] ; then

	if [ "$2" = "i" ] ; then
		echo "========== wheeltec ip:($wheeltec_ip) =========="
		echo "========== ls -al /mnt =========="
		ls -al /mnt

	elif [ "$2" = "nfs" ] ; then
		if [  "$3" = "+" ] ; then
			sudo mount $wheeltec_ip:/home/wheeltec/wheeltec_ros2 /mnt
		elif [  "$3" = "-" ] ; then
			sudo umount /mnt
		fi
		ls -al /mnt

	elif [ "$2" = "map" ] ; then
		nautilus /mnt/install/wheeltec_nav2/share/wheeltec_nav2/map\

	elif [ "$2" = "go" ] ; then
		ros2 topic pub /cmd_vel geometry_msgs/Twist "{linear: {x: $3, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: $4}}" --once
		sleep 3
		ros2 topic pub /cmd_vel geometry_msgs/Twist "{linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}" --once
	fi

fi

# lidar
if [ "$1" = "l" ] ; then
	WorkingDir=~/git
	testNode="lidar_ao_oasab0512"
	nodeDir="$WorkingDir/$testNode"
	cd $nodeDir
	echo "testNode:$testNode:$nodeDir"
	if [ "$2" = "kill" ] ; then
		echo "kill..."
		sudo killall -SIGTERM $testNode"_node"
	elif [ "$2" = "clean" ] ; then
		echo "clean..."
		rm -r build
		rm -r install
		rm -r log
	elif [ "$2" = "git" ] ; then
		echo "git clone..."
		rm -rf $testNode
		git clone ssh://git@10.1.7.125:10022/Gray.LIn/lidar_ao_oasab0512.git
	elif [ "$2" = "b" ] ; then
		echo "========== colcon build =========="
		colcon build
	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode $testNode'_node'"
		sudo chmod 777 /dev/ttyACM0
		source install/setup.sh
		# rviz2 &
		sudo killall -SIGTERM $testNode
		ros2 run $testNode $testNode"_node"
	elif [  "$2" = "r2" ] ; then
		source install/setup.sh
		ros2 launch $testNode aolidar_launch.py
	elif [  "$2" = "kill" ] ; then
		echo "kill..."
		killall -SIGTERM $testNode
	elif [  "$2" = "tp" ] ; then
		testTopic="/scan"
		echo "ros2 topic echo $testTopic"
		ros2 topic echo $testTopic
	fi
fi

# head
if [ "$1" = "h" ] ; then

	testNode="ctrl_head"
	WorkingDir=~
	nodeDir="$WorkingDir/$testNode"

	if [ "$2" = "kill" ] ; then
		echo "kill..."

	elif [ "$2" = "clean" ] ; then
		echo "clean..."
		rm -rf $WorkingDir/$testNode

	elif [ "$2" = "git" ] ; then
		echo "git clone..."
		cd $WorkingDir
		rm -rf $testNode
		git clone ssh://git@10.1.7.125:10022/Gray.LIn/ctrl_head.git

	elif [ "$2" = "b" ] ; then
		echo "========== colcon build =========="
		cd $nodeDir
		cp -f lib_OS/lib_ubuntu/* lib/
		colcon build
		cp -f lib_OS/lib_RB5/* lib/

	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode $testNode"
		source $nodeDir/install/setup.sh
		ros2 run $testNode $testNode

	fi
fi

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

if [ "$1" = "emoji" ] ; then
	
	WorkingDir=~/git
	testNode="lcd_set_emoji"
	nodeDir="$WorkingDir/$testNode"
	emojiDir="$WorkingDir/LCD"
	emojiDir2="$WorkingDir/LCD_timeless"

	export XDG_RUNTIME_DIR=/run/user/root
	PID_2kill=`cat $WorkingDir/PID_2kill`
	PID_last=`cat $WorkingDir/PID_last`
	run_counter=`cat $WorkingDir/run_counter`

	cd $nodeDir
	echo "testNode:$testNode:$nodeDir"

	if [ "$2" = "kill" ] ; then
		echo "kill..."
		# kill -9 $PID_2kill
		# kill -9 $PID_last
		pkill gst*

	elif [ "$2" = "clean" ] ; then
		echo "clean..."
		rm PID_*
		rm run_counter
		rm -r build
		rm -r install
		rm -r log

	elif [ "$2" = "git" ] ; then
		echo "git clone..."
		cd $WorkingDir
		rm -rf lcd_set_emoji
		# git clone http://10.1.7.125:10447/Gray.LIn/lcd_set_emoji.git
		git clone ssh://git@10.1.7.125:10022/Gray.LIn/lcd_set_emoji.git

	elif [ "$2" = "b" ] ; then
		echo "========== colcon build =========="
		colcon build

	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode "$testNode"_node"
		source $nodeDir/install/setup.sh
		ros2 run $testNode "$testNode"_node

	elif [ "$2" = "ls" ] ; then
		echo "list emoji..."
		ls -al $emojiDir2

	elif [ "$2" = "p" ] ; then
		echo "param..."

		if [ "$3" = "set" ] ; then
			echo "set..."
			ros2 param set /lcd_set_emoji param_emoji_name "$4"
		elif [ "$3" = "get" ] ; then
			echo "get..."
			ros2 param get /lcd_set_emoji param_emoji_name
		elif [ "$3" = "t" ] ; then
			echo "test..."
			ros2 param set /lcd_set_emoji param_emoji_name "A1" &
			ros2 param set /lcd_set_emoji param_emoji_name "A2" &
			ros2 param set /lcd_set_emoji param_emoji_name "A3" &
			ros2 param set /lcd_set_emoji param_emoji_name "A4" &
			ros2 param set /lcd_set_emoji param_emoji_name "A5" &
			ros2 param set /lcd_set_emoji param_emoji_name "A6" &
		fi

	else
		echo "Run emoji $2.mp4"
		if [ -z "$PID_2kill" ] ; then
			echo "PID_2kill empty"
		else
			echo PID_2kill:$PID_2kill
		fi
		if [ -z "$PID_last" ] ; then
			echo "PID_last empty"
		else
			echo PID_last:$PID_last
		fi

		if [ "$3" = "full" ] ; then
			gst-launch-1.0 multifilesrc location=$emojiDir2/$2.mp4 loop=true ! decodebin ! waylandsink fullscreen=TRUE&
		elif [ "$3" = "720" ] ; then
			echo "720P"
			gst-launch-1.0 multifilesrc location=$emojiDir2/$2.mp4 loop=true ! decodebin ! waylandsink x=20 y=20 width=1280 height=720&
		elif [ "$3" = "1080" ] ; then
			echo "1080P"
			gst-launch-1.0 multifilesrc location=$emojiDir2/$2.mp4 loop=true ! decodebin ! waylandsink x=20 y=20 width=1920 height=1080&
		else
			gst-launch-1.0 multifilesrc location=$emojiDir2/$2.mp4 loop=true ! decodebin ! waylandsink&
		fi

		# if [ -z "$run_counter" ] ; then
		# 	echo "run_counter empty"
		# 	$run_counter = "0"
		# else
		# 	echo run_counter:$run_counter
		# 	if [ $run_counter -gt 5 ] ; then
		# 		run_counter=0
		# 		pkill gst*
		# 	else
		# 		run_counter=$(($run_counter+"1"))
		# 	fi
		# fi
		# echo $run_counter > $WorkingDir/run_counter

		echo PID_last:$PID_last
		PID_2kill=$PID_last
		PID_last=$!
		echo $PID_2kill > $WorkingDir/PID_2kill
		echo $PID_last > $WorkingDir/PID_last
		if [ -z "$PID_2kill" ] ; then
			echo "PID_2kill empty"
		else
			sleep 1
			echo "kill -9 $PID_2kill"
			kill -9 $PID_2kill
		fi

	fi

fi

# ROS
if [ "$1" = "ros" ] ; then

	if [  "$2" = "n" ] ; then
		echo "========== node =========="
		# cd $nodeDir
		if [  "$3" = "i" ] ; then
			echo "ros2 node info $4"
			ros2 node info $4
		elif [  "$3" = "r" ] ; then
			echo "ros2 run $testNode "$testNode"_node"
			source install/setup.sh
			ros2 run $testNode "$testNode"_node
		elif [ "$3" = "pid" ] ; then
			pgrep -f $4

		else
			echo "ros2 node list"
			ros2 node list
		fi
	elif [ "$2" = "i" ] ; then
		echo "========== ROS version =========="
		echo "echo ROS_DISTRO:$ROS_DISTRO"
	elif [ "$2" = "b" ] ; then
		echo "========== colcon build --packages-select $3 =========="
		colcon build --packages-select $3
	elif [ "$2" = "r" ] ; then
		if [  "$3" = "talker" ] ; then
			echo "========== ros2 run demo_nodes_cpp talker =========="
			ros2 run demo_nodes_cpp talker
		elif [ "$3" = "listener" ] ; then
			echo "========== ros2 run demo_nodes_cpp listener =========="
			ros2 run demo_nodes_cpp listener
		fi
	elif [ "$2" = "g" ] ; then
		echo "========== rqt_graph =========="
		rqt_graph
	elif [ "$2" = "tf" ] ; then
		echo "========== ros2 run tf2_tools view_frames =========="
		ros2 run tf2_tools view_frames
	elif [ "$2" = "p" ] ; then
		echo "========== pkg =========="
		if [  "$3" = "exe" ] ; then
			if [ -z "$4" ] ; then
				ros2 pkg executables
			else
				ros2 pkg executables $4
			fi
		elif [ "$3" = "prefix" ] ; then
			echo "ros2 pkg prefix <package-name>"
			ros2 pkg prefix $4
		elif [ "$3" = "xml" ] ; then
			echo "ros2 pkg xml <package-name>"
			ros2 pkg xml $4
		elif [ "$3" = "cc" ] ; then
			echo "ros2 pkg create $4"
			ros2 pkg create $4 --build-type ament_cmake --dependencies rclcpp
		elif [ "$3" = "cp" ] ; then
			echo "ros2 pkg create $4"
			ros2 pkg create $4 --build-type ament_python --dependencies rclpy --license Apache-2.0
		else 
			echo "ros2 pkg list"
			ros2 pkg list
		fi

	elif [ "$2" = "tp" ] ; then
		echo "========== topic =========="
		testTopic="/chatter"
		# testTopic2="/chatter2"
		testTopic2="/scan"

		if [  "$3" = "p" ] ; then
			echo "ros2 topic pub $testTopic ..."
			ros2 topic pub $testTopic std_msgs/msg/String 'data: "test"'
		elif [ "$3" = "e" ] ; then
			echo "ros2 topic echo $4"
			ros2 topic echo $4
		elif [ "$3" = "i" ] ; then
			echo "ros2 topic info $4"
			ros2 topic info $4
		elif [ "$3" = "hz" ] ; then
			echo "ros2 topic hz $4"
			ros2 ros2 topic hz $4
		else 
			echo "ros2 topic list -t"
			ros2 topic list -t
		fi

	elif [ "$2" = "if" ] ; then
		echo "========== interface =========="
		if [  "$3" = "p" ] ; then
			echo "ros2 interface packages"
			ros2 interface packages
		elif [ "$3" = "s" ] ; then
			echo "ros2 interface show $4"
			ros2 interface show $4
		else 
			echo "ros2 interface list"
			ros2 interface list
		fi

	elif [ "$2" = "s" ] ; then
		echo "========== service =========="
		if [  "$3" = "r" ] ; then
			echo "run service"
			ros2 run examples_rclpy_minimal_service service
		elif [ "$3" = "x" ] ; then
			echo "xxx..."
		else 
			echo "ros2 service list"
			ros2 service list
		fi

	elif [ "$2" = "param" ] ; then

		if [ "$3" = "set" ] ; then
			echo "set..."
			ros2 param set /lcd_set_emoji param_emoji_name "$4"
		elif [ "$3" = "get" ] ; then
			echo "get..."
			ros2 param get $4 $5
		else 
			echo "ros2 param list"
			ros2 param list
		fi

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
		df -h --total
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
	elif [ "$2" = "user+" ] ; then
		if [ -n "$3" ] ; then
			if [ "$4" = "sidee" ] ; then
				# SAC EE team group
				sudo useradd  -m $3 -g "SAC_EE" -s /bin/bash
			elif [ "$4" = "sidme" ] ; then
				# SAC ME team group
				sudo useradd  -m $3 -g "SAC_ME" -s /bin/bash
			elif [ "$4" = "all" ] ; then
				# all ftp available group
				sudo useradd  -m $3 -G "SAC_EE,SAC_ME,SAC_SW,docker" -s /bin/bash
			elif [ "$4" = "sidsw" ] ; then
				# SAC SW team group for default
				sudo useradd  -m $3 -g "SAC_SW" -s /bin/bash
				sudo usermod -aG docker $3
			else
				# CCPSW team group for default
				sudo useradd  -m $3 -g "CCP" -s /bin/bash
				sudo usermod -aG docker $3
			fi
			echo "$3:$3" | sudo chpasswd
			sudo chage -d 0 $3
			sudo chage -l $3 | head -n 3
		else
			echo "param 3 needed"
		fi
	elif [ "$2" = "user-" ] ; then
		sudo userdel -r $3
elif [ "$2" = "user+g" ] ; then
		sudo usermod -aG $3 $4
	elif [ "$2" = "config" ] ; then
		code /etc/vsftpd.conf
	else
		echo "param 2 not match"
		exit -1
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
				sudo chmod  -R 444 .
			elif [ "$3" = "6" ] ; then
				sudo chmod -R 666 .
			else
				sudo chmod -R 777 .
			fi
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

# chrome-remote-desktop
if [ "$1" = "chrome" ] ; then

		if [ "$2" = "r" ] ; then
			echo "========== restart  chrome-remote-desktop ========== " 
 			sudo systemctl stop chrome-remote-desktop
 			sudo systemctl start chrome-remote-desktop
		else
 			sudo systemctl status chrome-remote-desktop
		fi

fi

# update x
if [ "$1" == "ux" ] ; then
	cd ~/OSPath
	git reset --hard HEAD
	git pull
	sudo chmod 777 Ubuntu/x.sh
fi

