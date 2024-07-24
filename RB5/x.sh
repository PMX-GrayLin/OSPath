
echo "param 0:"$0
echo "param 1:"$1
echo "param 2:"$2
echo "param 3:"$3
echo "param 4:"$4
echo "param 5:"$5

WorkingDir="/home/user/sambashare"
ProjectDir=~"/primax/ros2-galactic/wheeltec_ros2"

emojiDir="$WorkingDir/LCD"
emojiDir2="$WorkingDir/LCD_timeless"
emojiFile="Agree.mp4"
emojiFile2="Blink.mp4"
emojiFiles=(Agree Blink Confused Cute Disagree Dizzy Happy_1 Shock SleepLoop Sleep Smile StartSleep Talk Tired WakeUp2 LookAround Random)

rosDir_Home="/opt/ros/galactic"
testNode="lcd_set_emoji"
nodeDir="$WorkingDir/$testNode"

# speed
if [ "$1" = "t" ] ; then
	if [  "$2" = "1" ] ; then
		ros2 param set /ctrl_led welcome straight_flow
	elif [ "$2" = "2" ] ; then
		ros2 param set /ctrl_led welcome turn_flow
	elif [ "$2" = "3" ] ; then 
		ros2 param set /ctrl_led welcome abort_action_and_reset
	fi	
fi

if [ "$1" = "date" ] ; then
	timedatectl set-ntp yes
	date
fi

# run
if [ "$1" = "run" ] ; then
	if [  "$2" = "led" ] ; then
		cd ~/primax/ros2-galactic/wheeltec_ros2   
		./build_james.sh run led
	elif [ "$2" = "can" ] ; then
		cd ~/primax/ros2-galactic/wheeltec_ros2  
		./build_james.sh run can
	fi	
fi

# wifi
if [ "$1" = "wifi" ] ; then
	if [  "$2" = "3f" ] ; then
		cd ~/network_param
		cp primax_param.conf_3f primax_param.conf
		# sudo reboot
	elif [ "$2" = "b1" ] ; then
		cd ~/network_param	
		cp primax_param.conf_b1 primax_param.conf
		# sudo reboot
	elif [ "$2" = "hostap" ] ; then
		sudo systemctl restart hostapd.service
	fi
fi

# speed
if [ "$1" = "s" ] ; then
	if [  "$2" = "1" ] ; then
		bella_motor_ctl 1000 0 0 5 0 &
	elif [ "$2" = "2" ] ; then
		bella_motor_ctl -1000 0 0 5 0 &
	else 
		echo "else"
	fi	
fi

# lidar
if [ "$1" = "l" ] ; then
	export DISPLAY=192.168.100.10:0
	WorkingDir="/home/user/sambashare/lidar"
	testNode="lidar_ao_oasab0512"
	nodeDir="$WorkingDir/$testNode"

	echo "testNode:$testNode..."

	if [ "$2" = "kill" ] ; then
		echo "kill..."
		sudo killall -SIGTERM $testNode"_node"

	elif [ "$2" = "clean" ] ; then
		echo "clean..."
		# rm -rf $WorkingDir/$testNode

	elif [ "$2" = "git" ] ; then
		echo "git clone..."
		cd $WorkingDir
		rm -rf $testNode
		git clone ssh://git@10.1.7.125:10022/Gray.LIn/lidar_ao_oasab0512.git

	elif [ "$2" = "b" ] ; then
		echo "========== colcon build =========="
		cd $nodeDir
		colcon build
		# colcon build --packages-select lidar_ao_oasab0512

	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode $testNode'_node'"
		sudo chmod 777 /dev/ttyACM0
		source $nodeDir/install/setup.sh
		rviz2 &
		# sudo killall -SIGTERM $testNode
		ros2 run $testNode $testNode"_node"

	elif [  "$2" = "t" ] ; then
	
		testTopic="/scan"
		echo "echo...  ========== topic:$testTopic =========="
		# ros2 topic echo $testTopic
		# ros2 topic echo --no-arr $testTopic
		ros2 topic echo $testTopic | grep -A 3 ranges
	fi
fi

# head
if [ "$1" = "h" ] ; then
	WorkingDir="/root/sambashare/head"
	ProjectDir="/root/primax/ros2-galactic/wheeltec_ros2"
	testNode="ctrl_head"
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
		colcon build
	
	elif [ "$2" = "cp" ] ; then
		rm "$ProjectDir"/install/ctrl_head/lib/ctrl_head/ctrl_head
		cp "$nodeDir"/install/ctrl_head/lib/ctrl_head/ctrl_head "$ProjectDir"/install/ctrl_head/lib/ctrl_head

	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode $testNode"
		source $nodeDir/install/setup.sh
		sudo killall -SIGTERM $testNode
		ros2 run $testNode "$testNode"

	elif [ "$2" = "p" ] ; then
		echo "param ctrl_fixed_action..."

		if [ "$3" = "set" ] ; then
			echo "ros2 param set $testNode ctrl_fixed_action '$4'"
			ros2 param set $testNode ctrl_fixed_action "$4"
		elif [ "$3" = "get" ] ; then
			echo "ros2 param get $testNode ctrl_fixed_action"
			ros2 param get $testNode ctrl_fixed_action
		fi

	elif [ "$2" = "p1" ] ; then
		echo "param set_angle..."

		ros2 param set $testNode select_servo_num 1
		if [ "$3" = "set" ] ; then
			echo "ros2 param set $testNode set_angle '$4'"
			ros2 param set $testNode set_angle "$4"
		elif [ "$3" = "get" ] ; then
			echo "ros2 param get $testNode set_angle"
			ros2 param get $testNode set_angle
		fi
	elif [ "$2" = "p2" ] ; then
		echo "param set_angle..."

		ros2 param set $testNode select_servo_num 2
		if [ "$3" = "set" ] ; then
			echo "ros2 param set $testNode set_angle '$4'"
			ros2 param set $testNode set_angle "$4"
		elif [ "$3" = "get" ] ; then
			echo "ros2 param get $testNode set_angle"
			ros2 param get $testNode set_angle
		fi

	elif [ "$2" = "p3" ] ; then
		echo "param set_angle..."

		ros2 param set $testNode select_servo_num 3
		if [ "$3" = "set" ] ; then
			echo "ros2 param set $testNode set_angle '$4'"
			ros2 param set $testNode set_angle "$4"
		elif [ "$3" = "get" ] ; then
			echo "ros2 param get $testNode set_angle"
			ros2 param get $testNode set_angle
		fi

	elif [ "$2" = "rt" ] ; then
		echo "reset..."
		ros2 param set $testNode select_servo_num 1
		ros2 param set $testNode set_servo_en 0
		ros2 param set $testNode select_servo_num 2
		ros2 param set $testNode set_servo_en 0
		ros2 param set $testNode select_servo_num 3
		ros2 param set $testNode set_servo_en 0

		ros2 param set $testNode select_servo_num 1
		ros2 param set $testNode reset_mid_pos 1
		ros2 param set $testNode select_servo_num 2
		ros2 param set $testNode reset_mid_pos 1
		ros2 param set $testNode select_servo_num 3
		ros2 param set $testNode reset_mid_pos 1

	elif [ "$2" = "ttt" ] ; then
		echo "test..."
		ros2 param set $testNode select_servo_num 3

		while true
		do
			ros2 param set $testNode set_angle 30
			ros2 param set $testNode ctrl_fixed_action 0
			ros2 param set $testNode set_angle -30
			ros2 param set $testNode ctrl_fixed_action 0
		done

	else
		echo "not a case..."
	fi
fi

if [ "$1" = "emoji" ] ; then
	
	WorkingDir=~/"sambashare/lcd"
	testNode="lcd_set_emoji"
	nodeDir="$WorkingDir/$testNode"
	emojiDir="$WorkingDir/LCD"
	emojiDir2="$WorkingDir/LCD_timeless"

	export XDG_RUNTIME_DIR=/run/user/root
	PID_2kill=`cat $WorkingDir/PID_2kill`
	PID_last=`cat $WorkingDir/PID_last`

	if [ "$2" = "kill" ] ; then
		echo "kill..."
		# kill -9 $PID_2kill
		# kill -9 $PID_last
		pkill gst*
		sudo killall -SIGTERM $testNode

	elif [ "$2" = "clean" ] ; then
		echo "clean..."
		rm $WorkingDir/PID_*
		rm -rf $WorkingDir/lcd_set_emoji

	elif [ "$2" = "git" ] ; then
		echo "git clone..."
		cd $WorkingDir
		rm -rf lcd_set_emoji
		git clone ssh://git@10.1.7.125:10022/Gray.LIn/lcd_set_emoji.git

	elif [ "$2" = "b" ] ; then
		echo "========== colcon build =========="
		cd $nodeDir
		colcon build
		# colcon build --packages-select lcd_set_emoji

	elif [  "$2" = "r" ] ; then
		echo "ros2 run $testNode "$testNode"_node"
		source $nodeDir/install/setup.sh
		sudo killall -SIGTERM $testNode
		ros2 run $testNode "$testNode"_node

	elif [  "$2" = "tt" ] ; then

		ros2 param set /lcd_set_emoji param_emoji_name "Confused" &
		sleep 0.15
		ros2 param set /lcd_set_emoji param_emoji_name "Smile" &
		sleep 1

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
	echo "========== ROS =========="

	if [  "$2" = "n" ] ; then
		echo "========== node =========="
		if [  "$3" = "i" ] ; then
			cd $nodeDir
			echo "ros2 node info $4"
			ros2 node info $4
		elif [  "$3" = "r" ] ; then
			echo "ros2 run $testNode "$testNode"_node"
			source install/setup.sh
			ros2 run $testNode "$testNode"_node
		elif [ "$3" = "b" ] ; then
			echo "========== colcon build =========="
			cd $nodeDir
			colcon build
		else
			echo "ros2 node list"
			ros2 node list
		fi
	elif [ "$2" = "env" ] ; then
		source /opt/ros/galactic/setup.bash

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
		elif [ "$3" = "c" ] ; then
			echo "ros2 pkg create $4"
			ros2 pkg create $4 --build-type ament_cmake --dependencies rclcpp
		else 
			echo "ros2 pkg list"
			ros2 pkg list
		fi

	elif [ "$2" = "tp" ] ; then
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
		elif [ "$3" = "show" ] ; then
			echo "ros2 interface show $4"
			ros2 interface show $4
		else 
			echo "ros2 interface list"
			ros2 ros2 interface list
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

# test gst on RB5
if [ "$1" = "gst" ] ; then
	echo "gst..." 
	export XDG_RUNTIME_DIR=/run/user/root
	WorkingDir=~/"sambashare/lcd"
	testNode="lcd_set_emoji"
	nodeDir="$WorkingDir/$testNode"
	# emojiDir="$WorkingDir/LCD"
	emojiDir="$WorkingDir/LCD_timeless"
	emojiFile="Dizzy.mp4"

	echo "$emojiDir/$emojiFile"
	if [ "$2" = "1" ] ; then
		echo "1..., OK" 
		gst-launch-1.0 filesrc location=$emojiDir/$emojiFile ! qtdemux ! decodebin ! videoconvert ! waylandsink
	elif [ "$2" = "2" ] ; then
		echo "2..., OK" 
		gst-launch-1.0 filesrc location=$emojiDir/$emojiFile ! qtdemux ! decodebin ! videoconvert ! waylandsink fullscreen=TRUE
	elif [ "$2" = "3" ] ; then
		echo "3..., NG" 
		gst-launch-1.0 filesrc location=$emojiDir/$emojiFile ! qtdemux ! vaapidecode ! videoconvert ! waylandsink fullscreen=TRUE
	elif [ "$2" = "4" ] ; then
		echo "4..., NG" 
		gst-launch-1.0 filesrc location=$emojiDir/$emojiFile ! qtdemux ! avdec_h264 ! videoconvert ! waylandsink fullscreen=TRUE
	elif [ "$2" = "5" ] ; then
		echo "5..., NG" 
		gst-launch-1.0 videotestsrc ! kmssink
	elif [ "$2" = "6" ] ; then
		echo "6..., NG" 
		gst-launch-1.0 playbin uri=file://$emojiDir/$emojiFile
	elif [ "$2" = "7" ] ; then
		echo "7..., OK" 
		gst-launch-1.0 multifilesrc location=$emojiDir2/$emojiFile loop=true ! decodebin ! videoconvert ! waylandsink
	elif [ "$2" = "8" ] ; then
		echo "8..., OK" 
		gst-launch-1.0 multifilesrc location=$emojiDir2/$emojiFile loop=true ! decodebin ! waylandsink
	elif [ "$2" = "9" ] ; then
		echo "9..., OK" 
		gst-launch-1.0 multifilesrc location=$emojiDir2/$emojiFile loop=true ! decodebin ! waylandsink&
	else
		echo "else... OK" 
		gst-launch-1.0 videotestsrc ! waylandsink
	fi

fi

if [ "$1" = "test" ] ; then
	PID_2kill=`cat $WorkingDir/PID_2kill`
	PID_last=`cat $WorkingDir/PID_last`

	if [ "$2" = "1" ] ; then
		echo "1..., OK"
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
		gst-launch-1.0 multifilesrc location=$emojiDir2/$emojiFile loop=true ! decodebin ! waylandsink&
		PID_2kill=$PID_last
		PID_last=$!
		echo $PID_2kill > $WorkingDir/PID_2kill
		echo $PID_last > $WorkingDir/PID_last
		if [ -z "$PID_2kill" ] ; then
			echo "PID_2kill empty"
		else
			echo "kill -9 $PID_2kill"
			sleep 1
			kill -9 $PID_2kill
		fi

	elif [ "$2" = "2" ] ; then
		echo "2..., OK"
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
		gst-launch-1.0 multifilesrc location=$emojiDir2/$emojiFile2 loop=true ! decodebin ! waylandsink&
		PID_2kill=$PID_last
		PID_last=$!
		echo $PID_2kill > $WorkingDir/PID_2kill
		echo $PID_last > $WorkingDir/PID_last
		if [ -z "$PID_2kill" ] ; then
			echo "PID_2kill empty"
		else
			echo "kill -9 $PID_2kill"
			sleep 1
			kill -9 $PID_2kill
		fi

	elif [ "$2" = "kill" ] ; then
		kill -9 $PID_2kill
		kill -9 $PID_last

	elif [ "$2" = "while" ] ; then
		while true
		do
			gst-launch-1.0 filesrc location=$emojiDir/$emojiFile ! qtdemux ! decodebin ! videoconvert ! waylandsink
		done
	else
		echo "else..." 

	fi
fi


xDir=~/"Gray"

# docker
dockderDir=~/"Docker"

# redmine
redDir="."
redDir_Home="/srv/redmine/vHome/_data"
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
gitBackupFile="1643394275_2022_01_28_14.1.6"

# jenkins
jksDir="$dockderDir/jenkins"
jksDir_Home="/var/lib/docker/volumes/jenkins_vHome/_data"

# NAS
nasDir="$dockderDir/nas"

# working directory 
if [ "$1" = "wd" ] ; then
	echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP" 
	if [  "$XDG_CURRENT_DESKTOP" = "KDE" ] ; then

		if [ "$2" = "git" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "Docker_Gitlab" --working-directory=$gitDir \
			--tab -T "Gitlab_Data" --working-directory=$gitDir_Data \
			--tab -T "gitDir_Config" --working-directory=$gitDir_Config \
			--tab -T "gitDir_ConfigR" --working-directory=$gitDir_ConfigR 
		elif [ "$2" = "red" ] ; then
			xfce4-terminal --geometry=160x40 \
			--tab -T "Docker_Redmine" --working-directory=$redDir \
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
			--tab -T "Jenkins_Home" --working-directory=$jksDir_Home \
			--tab -T "Jenkins_workspace" --working-directory=$jksDir_Home"/workspace" 
		else
			echo "param 3 not match"
			exit -1
		fi

	elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ] ; then
		if [ "$2" = "git" ] ; then
			gnome-terminal --geometry=160x40 \
			--tab -t "Docker_Gitlab" --working-directory=$gitDir \
			--tab -t "Gitlab_Data" --working-directory=$gitDir_Data \
			--tab -t "gitDir_Config" --working-directory=$gitDir_Config \
			--tab -t "gitDir_ConfigR" --working-directory=$gitDir_ConfigR 
		elif [ "$2" = "red" ] ; then
			gnome-terminal --geometry=160x40 \
			--tab -t "Docker_Redmine" --working-directory=$redDir \
			--tab -t "Redmine_Home" --working-directory=$redDir_Home \
			--tab -t "Redmine_File" --working-directory=$redDir_Files \
			--tab -t "Redmine_Config" --working-directory=$redDir_Config \
			--tab -t "Postgres" --working-directory=$redDir_Postgres
		elif [ "$2" = "ftp" ] ; then
			gnome-terminal --geometry=160x40 \
			--tab -t "FTP Data" --working-directory="/home/test/FTP/" \
			--tab -t "FTP /etc" --working-directory="/etc" \
			--tab -t "FTP /etc/vsftpd" --working-directory="/etc/vsftpd"
		elif [ "$2" = "jks" ] ; then
			gnome-terminal --geometry=160x40 \
			--tab -t "Docker_Jenkins" --working-directory=$jksDir \
			--tab -t "Docker_Jenkins2" --working-directory=$jksDir \
			--tab -t "Jenkins_Home" --working-directory=$jksDir_Home 
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

		# list  normal users
		echo "========== User range =========="
		grep -E '^UID_MIN|^UID_MAX' /etc/login.defs
		echo "========== User info =========="
		getent passwd {1000..60000}

	elif [ "$2" = "user" ] ; then
		id -nG $3
	else
		echo "param 3 not match"
		exit -1
	fi
fi

# tar
if [ "$1" = "zip" ] ; then
		echo ">>>> zip src dst"
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

# reboot
# if [ "$1" = "r" ] ; then
# 	echo "========== reboot ========== " 
# 	reboot
# fi