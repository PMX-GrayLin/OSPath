xDir=~/"OSPath/AICamera"

# docker
dockderDir=~/"Docker"

# gitlab
gitDir="$dockderDir/gitlab"
gitDir_Data="/var/lib/docker/volumes/gitlab_vData/_data"
gitDir_Config="/var/lib/docker/volumes/gitlab_vConfig/_data"
gitDir_ConfigR="/var/lib/docker/volumes/gitlab_vConfig_r/_data"
gitDir_Logs="/var/lib/docker/volumes/gitlab_vLogs/_data"
gitBackupFile="1588961756_2020_05_08_12.9.3"

# Loop through all parameters passed to the script
echo "param 0: $0"
i=1
for arg in "$@"; do
    echo "param $i: $arg"
    ((i++))
done

timestamp=$(TZ='UTC-8' date +"%H%M%S")
echo "timestamp:"$timestamp

product=$(fw_printenv | grep '^product=' | cut -d '=' -f2)
# ai_camera_plus or vision_hub_plus 
echo "product:$product"

hostname_prefix=$(hostname | awk -F'-' '{print $1}')
# aicamera or visionhub
echo "hostname_prefix:$hostname_prefix"

# Load device path from config
device_uvc=$(cat ~/primax/misc/camera_uvc.conf)
if [ -z "$device_uvc" ]; then
  device_uvc="/dev/video137"
fi
echo "device_uvc:$device_uvc"

is_aicamera() {
  if [[ "$hostname_prefix" == "aicamera" || "$product" == "ai_camera_plus" ]]; then
	return 0  # true: it is an aicamera
  else
	return 1  # false: not an aicamera
  fi
}
is_visionhub() {
  if [[ "$hostname_prefix" == "visionhub" || "$product" == "vision_hub_plus" ]]; then
	return 0  # true: it is an visionhub
  else
	return 1  # false: not an visionhub
  fi
}

if [ "$1" = "fixt" ]; then
	find . -exec touch {} +
fi

if [ "$1" = "ccm" ]; then
		echo "ccm..."
		dir_ccm="/home/root/primax/10.1.13.207/ccm_db"
		dir_iq_dev="/usr/share/mtkcam/DataSet/SQLiteModule/db"
		filePath="tuning_DB/imx214_mipi_raw"
		fileName1="ISP_param.db"
		fileName2="ISP_mapping.db"

		if [ -z "$2" ]; then
			echo "filePath_src:$filePath_src should be set correctlly..."
			exit 1
		else
			filePath_src="$filePath/$2"
		fi

		fileReplace1="$dir_ccm/$2/$fileName1"
		fileTarget1="$dir_iq_dev/$filePath/$fileName1"
		fileReplace2="$dir_ccm/$2/$fileName2"
		fileTarget2="$dir_iq_dev/$filePath/$fileName2"

		echo "cp -f $fileReplace1 $fileTarget1"
		cp -f $fileReplace1 $fileTarget1
		echo "cp -f $fileReplace2 $fileTarget2"
		cp -f $fileReplace2 $fileTarget2
		sync
		md5sum $fileReplace1
		md5sum $fileTarget1
		md5sum $fileReplace2
		md5sum $fileTarget2
fi

# copy to
if [ "$1" = "cp" ]; then

	if [ "$2" = "h" ]; then
		path="$HOME"
		cp -rf $3 $path 
	elif [ "$2" = "ftp" ]; then
		path="/mnt/reserved/10.1.13.207"
		cp -rf $3 $path 
	fi
	echo "copy $3 to $path"

fi

if [ "$1" = "ps" ]; then
	if [ "$2" != "" ]; then
		echo "ps aux | grep $2"
		ps aux | grep $2
	fi
fi

if [ "$1" = "gst" ]; then
	echo "gst pipeline..."
	if [ "$2" = "1" ]; then
		cmd=""
	fi
	$cmd 
fi

if [ "$1" = "ot" ]; then
	i2cbus=7
	if [ "$2" = "ck" ]; then
		echo "i2cdetect -r -y $i2cbus"
		i2cdetect -r -y $i2cbus
	elif [ "$2" = "r8" ]; then
		echo "read 8*8... i2ctransfer -y $i2cbus w2@0x68 0x4E 0x00 r141"
		i2ctransfer -y $i2cbus w2@0x68 0x4E 0x00 r141
	elif [ "$2" = "r16" ]; then
		echo "read 16*16... i2ctransfer -y $i2cbus w2@0x68 0x4E 0x00 r525"
		i2ctransfer -y $i2cbus w2@0x68 0x4E 0x00 r525
	fi
fi

# AICamera 
if [ "$1" = "aic" ]; then
	echo "aicamera command..."

	if [ "$2" = "jobs" ]; then
		pm2 list

	elif [ "$2" = "ck" ]; then
		echo "check feature..."
		if [ "$3" = "dp" ]; then
			echo "display port..."
			echo "i2cdetect -r -y 0"
			i2cdetect -r -y 0
			echo "i2cdetect -r -y 4"
			i2cdetect -r -y 4
			echo "modeprint mediatek"
			modeprint mediatek
			echo "ls /sys/class/drm/"
			ls /sys/class/drm/
			echo "cat /sys/class/drm/card0-DP-1/status"
			cat /sys/class/drm/card0-DP-1/status

		elif [ "$3" = "pkg" ]; then
			echo "opkg list-installed..."
			if [ "$4" != "" ]; then
				opkg list-installed | grep --color=auto $4
			else
				opkg list-installed
			fi

		elif [ "$3" = "tof" ]; then
			echo "tof sensor..."
			echo "i2cdetect -r -y 1"
			i2cdetect -r -y 1
		
		elif [ "$3" = "cam" ]; then
			echo "camera..."

			if [ "$4" = "usb" ]; then
			    VIDEO_DEV=137
				echo "v4l2-ctl --device=${VIDEO_DEV} --list-formats-ext"
				v4l2-ctl --device=${VIDEO_DEV} --list-formats-ext
				echo "v4l2-ctl --device=${VIDEO_DEV} --list-ctrls"
				v4l2-ctl --device=${VIDEO_DEV} --list-ctrls
			elif [ "$4" = "l" ]; then
				echo"v4l2-ctl --list-devices"
				v4l2-ctl --list-devices
			else
				echo "declare -a VIDEO_DEV=(\`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d \"\n\"\`)"
				declare -a VIDEO_DEV=(`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d "\n"`)
				echo "VIDEO_DEV[0]:${VIDEO_DEV[0]}"
				echo "v4l2-ctl --device=${VIDEO_DEV[0]} --list-formats-ext"
				v4l2-ctl --device=${VIDEO_DEV[0]} --list-formats-ext
				echo "v4l2-ctl --device=${VIDEO_DEV[0]} --list-ctrls"
				v4l2-ctl --device=${VIDEO_DEV[0]} --list-ctrls

				# echo "udevadm info -a -p $(udevadm info -q path -n ${VIDEO_DEV[0]})"
				# udevadm info -a -p $(udevadm info -q path -n ${VIDEO_DEV[0]})
				# udevadm info -a -p $(udevadm info -q path -n ${VIDEO_DEV[1]})
				# udevadm info -a -p $(udevadm info -q path -n ${VIDEO_DEV[2]})
			fi

		elif [ "$3" = "net" ]; then
			echo "net..."
			echo "========== systemctl status systemd-networkd =========="
			systemctl status systemd-networkd
			echo "========== systemctl status NetworkManager =========="
			systemctl status NetworkManager
			echo "========== ip addr show eth0 =========="
			ip addr show eth0
			echo "========== networkctl status eth0 =========="
			networkctl status eth0
			echo "========== fw_printenv | grep eth =========="
			fw_printenv | grep --color=auto eth

		elif [ "$3" = "i2c" ]; then
			echo "ls /dev/i2c-*"
			ls /dev/i2c-*
			echo "i2cdetect -r -y 0"
			i2cdetect -r -y 0
			echo "i2cdetect -r -y 1"
			i2cdetect -r -y 1
			echo "i2cdetect -r -y 2"
			i2cdetect -r -y 2
			echo "i2cdetect -r -y 3"
			i2cdetect -r -y 3
			echo "i2cdetect -r -y 4"
			i2cdetect -r -y 4
			echo "i2cdetect -r -y 5"
			i2cdetect -r -y 5
			
		elif [ "$3" = "di" ]; then
			echo "gpioget /dev/gpiochip0 0 1"
			gpioget /dev/gpiochip0 0 1

		elif [ "$3" = "triger" ]; then
			echo "gpioget /dev/gpiochip0 17 70"
			gpioget /dev/gpiochip0 17 70

		elif [ "$3" = "gige" ]; then
			echo "arv-tool-0.8 control Width Height ExposureAuto ExposureTime GainAuto Gain"
			arv-tool-0.8 control Width Height ExposureAuto ExposureTime GainAuto Gain

		else
			echo "check version... cat /etc/primax_version"
			cat /etc/primax_version
			echo ""
			echo "check build commit... cat ~/primax/misc/build_commit"
			cat ~/primax/misc/build_commit
			echo ""
			echo "check process... ps aux | grep -E --color=auto \"vision_box|mediamtx|fw_daemon|gst\""
			ps aux | grep -E --color=auto "vision_box|mediamtx|fw_daemon|gst"
		fi
	
	elif [ "$2" = "u" ]; then
		echo "update..."
		dir_local_ftp="/mnt/reserved/10.1.13.207"
		dir_target="/home/root/backend_data"
		dir_backend="$dir_target/vision-sensor-backend"
		dir_frontend="$dir_target/vision-sensor-frontend"
		
		cd $dir_target
		if [ "$3" = "be" ]; then
			echo "backend..."
			cp -f $dir_local_ftp/AD/vision-sensor-backend.tar.gz .
			rm -r vision-sensor-backend/
			tar -zxvf vision-sensor-backend.tar.gz
		elif [ "$3" = "fe" ]; then
			echo "frontend..."
			cp -f $dir_local_ftp/AD/vision-sensor-frontend.tar.gz .
			rm -r vision-sensor-frontend/
			tar -zxvf vision-sensor-frontend.tar.gz
		fi

	elif [ "$2" = "c" ]; then
		echo "clean..."
		cd ~/primax
		rm fw_*.png fw_*.jpg fw_*.bmp

	elif [ "$2" = "rp" ]; then
		echo "run .py..."
		if [ "$3" = "wifi" ]; then
			python3 /home/root/primax/misc/wifi_scan_ui.py&
		elif [ "$3" = "status" ]; then
			python3 /home/root/primax/misc/network_status_ui.py&
		fi

	elif [ "$2" = "rs" ]; then
		echo "restart $3..."
		
		if [ "$3" = "mtx" ]; then
			pkill mediamtx
			sleep 1
			mediamtx /etc/mediamtx/mediamtx.yml&
		
		elif [ "$3" = "fw" ]; then
			pkill vision_box
			sleep 1
			vision_box_DualCam &

		elif [ "$3" = "fw2" ]; then
			pkill fw_daemon
			sleep 1
			~/primax/fw_daemon &

		elif [ "$3" = "net" ]; then
			systemctl restart systemd-networkd

		elif [ "$3" = "gige" ]; then
			echo "arv-tool-0.8 control DeviceReset"
			arv-tool-0.8 control DeviceReset

		elif [ "$3" = "all" ]; then
			pkill vision_box
			pkill fw_daemon
			pkill mediamtx

			sleep 3
			vision_box_DualCam &
			~/primax/fw_daemon &
			mediamtx /etc/mediamtx/mediamtx.yml&
		fi

	elif [ "$2" = "gst" ]; then

		if [ "$3" = "usb" ]; then
			echo "usb..."
			if [ "$4" = "tee" ]; then
				cmd="gst-launch-1.0 -e -v v4l2src device="/dev/video5" ! image/jpeg,width=1920,height=1080,framerate=30/1 ! jpegdec ! videoconvert ! tee name=t ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true     t. ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! rtspclientsink location=rtsp://localhost:8554/mystream"
			elif [ "$4" = "dp" ]; then
				cmd="gst-launch-1.0 -e -v v4l2src device="/dev/video137" ! image/jpeg,width=1920,height=1080,framerate=30/1 ! jpegdec ! videoconvert ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true"
			else
				cmd="gst-launch-1.0 -e -v v4l2src device="/dev/video137" ! image/jpeg,width=1920,height=1080,framerate=30/1 ! jpegdec ! videoconvert ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! rtspclientsink location=rtsp://localhost:8554/mystream"
			fi

		elif [ "$3" = "gige" ]; then
			echo "gige..."
			
			if [ "$4" = "tee" ]; then
				cmd="gst-launch-1.0 aravissrc camera-name=id1 ! videoconvert ! video/x-raw,format=NV12 ! tee name=t t. ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true t. ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			elif [ "$4" = "dp" ]; then
				cmd='gst-launch-1.0 aravissrc camera-name=id1 ! videoconvert ! video/x-raw,format=NV12,width=1536,height=1024 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true'
			elif [ "$4" = "dp2" ]; then
				cmd='gst-launch-1.0 aravissrc camera-name=id1 ! videoconvert ! video/x-raw,format=NV12,width=3072,height=2048 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true'
			else
				cmd="gst-launch-1.0 aravissrc camera-name=id1 ! videoconvert ! video/x-raw,format=NV12 ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			fi

		elif [ "$3" = "gige2" ]; then
			echo "gige2..."
			
			if [ "$4" = "tee" ]; then
				cmd="gst-launch-1.0 aravissrc camera-name=id2 ! videoconvert ! video/x-raw,format=NV12 ! tee name=t t. ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true t. ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			elif [ "$4" = "dp" ]; then
				cmd='gst-launch-1.0 aravissrc camera-name=id2 ! videoconvert ! video/x-raw,format=NV12,width=1536,height=1024 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true'
			elif [ "$4" = "dp2" ]; then
				cmd='gst-launch-1.0 aravissrc camera-name=id2 ! videoconvert ! video/x-raw,format=NV12,width=3072,height=2048 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true'
			else
				cmd="gst-launch-1.0 aravissrc camera-name=id2 ! videoconvert ! video/x-raw,format=NV12 ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			fi

		elif [ "$3" = "png" ]; then
			filename="snapshot_${timestamp}.png"
			cmd="gst-launch-1.0 -e v4l2src device=${VIDEO_DEV[0]} num-buffers=1 ! video/x-raw,width=2048,height=1536 ! pngenc ! filesink location="${filename}""

		elif [ "$3" = "jpg" ]; then
			filename="snapshot_${timestamp}.jpg"
			cmd="gst-launch-1.0 -v v4l2src device=${VIDEO_DEV[0]} num-buffers=1 ! queue ! video/x-raw,framrate=30/1,width=2048,height=1536,format=NV12 ! v4l2jpegenc ! queue ! jpegparse ! filesink location="${filename}.jpg""

		elif [ "$3" = "bmp" ]; then
			filename="snapshot_${timestamp}.bmp"
			cmd="gst-launch-1.0 -e v4l2src device=${VIDEO_DEV[0]} num-buffers=1 ! video/x-raw,width=2048,height=1536 ! bmpenc ! filesink location="${filename}.bmp""

		elif [ "$3" = "mtx" ]; then
			cmd="gst-launch-1.0 rtspsrc location=rtsp://localhost:8554/mystream latency=10 drop-on-latency=true ! rtph264depay ! h264parse ! v4l2h264dec extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! v4l2convert ! video/x-raw,width=1920,height=1080 ! fpsdisplaysink video-sink=waylandsink sync=false"

		elif [ "$3" = "cis" ]; then
			echo "cis..."
			declare -a VIDEO_DEV=(`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d "\n"`)

			if [ "$4" = "tee" ]; then
				cmd="gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! tee name=t t. ! videoconvert ! video/x-raw,format=YUY2,width=1280,height=720 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false t. ! queue ! v4l2h264enc extra-controls=cid,video_gop_size=30 capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			elif [ "$4" = "dp" ]; then
				cmd="gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! videoconvert ! video/x-raw,width=1280,height=720 ! fpsdisplaysink video-sink=waylandsink sync=false"
				# cmd="gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! v4l2convert output-io-mode=dmabuf-import ! video/x-raw,width=1280,height=720 ! fpsdisplaysink video-sink=waylandsink sync=false"
			else
				# cmd="gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! video/x-raw,width=2048,height=1536 ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
				cmd="gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! video/x-raw,width=2592,height=1944 ! queue ! v4l2h264enc extra-controls="cid,video_gop_size=30" capture-io-mode=dmabuf ! h264parse config-interval=1 ! rtspclientsink location=rtsp://localhost:8554/mystream"
			fi

		fi

		echo "$cmd"
		$cmd
	
	elif [ "$2" = "cam" ]; then

		echo "declare -a VIDEO_DEV=(`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d \"\n\"`)"
		declare -a VIDEO_DEV=(`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d "\n"`)
		if [ "$3" = "reset" ]; then
			echo "reset ioctls..."
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl white_balance_automatic=1"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl white_balance_automatic=1
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl auto_exposure=0"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl auto_exposure=0
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl saturation=0"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl saturation=0
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl contrast=0"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl contrast=0
		
		elif [ "$3" = "set" ]; then
			echo "set ioctls..."
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl white_balance_automatic=0"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl white_balance_automatic=0
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl auto_exposure=1"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl auto_exposure=1
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl saturation=7"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl saturation=7
			echo "v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl contrast=5"
			v4l2-ctl -d ${VIDEO_DEV[0]} --set-ctrl contrast=5
		fi

		sleep 0.5
		echo "v4l2-ctl -d ${VIDEO_DEV[0]} --list-ctrls"
		v4l2-ctl -d ${VIDEO_DEV[0]} --list-ctrls

	elif [ "$2" = "iq" ]; then
		echo "IQ..."
		dir_iq_new="/home/root/primax/10.1.13.207/IQ_DB/db_new"
		dir_iq_old="/home/root/primax/10.1.13.207/IQ_DB/db_origin"
		dir_iq_dev="/usr/share/mtkcam/DataSet/SQLiteModule/db"

		if [ "$3" = "new" ]; then
			echo "update new DB..."
			if [ "$4" = "os" ]; then
				filePath="tuning_DB/imx214_mipi_raw"
				fileName="ISP_param.db"
				echo "OB & Shading DB : $filePath/$fileName ..."
			elif [ "$4" = "ae" ]; then
				filePath="ae"
				fileName="ParameterDB_ae.db"
				echo "ae DB : $filePath/$fileName ..."
			elif [ "$4" = "awb" ]; then
				filePath="awb"
				fileName="ParameterDB_awb.db"
				echo "awb DB : $filePath/$fileName ..."
			elif [ "$4" = "tone" ]; then
				filePath="tone"
				fileName="ParameterDB_tone.db"
				echo "tone DB..."
			else
				echo "not match..."
			fi
			fileReplace="$dir_iq_new/$filePath/$fileName"

		elif [ "$3" = "old" ]; then
			echo "restore old DB..."
			if [ "$4" = "os" ]; then
				filePath="tuning_DB/imx214_mipi_raw"
				fileName="ISP_param.db"
				echo "OB & Shading DB : $filePath/$fileName ..."
				cp -f "$dir_iq_old/tuning_DB/imx214_mipi_raw/ISP_param.db" "$dir_iq_dev/tuning_DB/imx214_mipi_raw/ISP_param.db"
			elif [ "$4" = "ae" ]; then
				filePath="ae"
				fileName="ParameterDB_ae.db"
				echo "ae DB : $filePath/$fileName ..."
			elif [ "$4" = "awb" ]; then
				filePath="awb"
				fileName="ParameterDB_awb.db"
				echo "awb DB : $filePath/$fileName ..."
			elif [ "$4" = "tone" ]; then
				filePath="tone"
				fileName="ParameterDB_tone.db"
				echo "tone DB..."
			else
				echo "not match..."
			fi
			fileReplace="$dir_iq_old/$filePath/$fileName"
		fi

		fileTarget="$dir_iq_dev/$filePath/$fileName"
		echo "cp -f $fileReplace $fileTarget"
		cp -f $fileReplace $fileTarget
		md5sum $fileReplace
		md5sum $fileTarget
		sync


	elif [ "$2" = "kill" ]; then

		if [ "$3" = "fw" ]; then
			pkill vision_box
			pkill fw_daemon

		elif [ "$3" = "gst" ]; then
			pkill gst-launch-1.0
		fi

	elif [ "$2" = "ftp" ]; then
		echo "update files from ftp..."

		# FTP details
		ftp_user="gray.lin"
		ftp_pass="Zx03310331"
		ftp_host="10.1.13.207"
		dir_ftp="Public/gray/aicamera"
		dir_local="/mnt/reserved"
		dir_exec=~/"primax"

		cd $dir_local
		pkill vision_box
		pkill fw_daemon
		
		if [ "$3" = "sync" ]; then

			if [ "$4" = "down" ]; then
				# Sync from ftp server → aicamera
				rsync -avz -e ssh gray.lin@$ftp_host:/mnt/disk2/FTP/$dir_ftp $dir_local/$ftp_host/
			elif [ "$4" = "up" ]; then
				# Then sync from aicamera → ftp server
				rsync -avz -e ssh $dir_local/$ftp_host/ gray.lin@$ftp_host:/mnt/disk2/FTP/$dir_ftp
			fi

		else
			# all file in ftp folder to aicamera
			wget --mirror --user="$ftp_user" --password="$ftp_pass" "ftp://$ftp_host/$dir_ftp" --no-parent --cut-dirs=3	

			cp -f $dir_local/$ftp_host/vision_box_DualCam $dir_exec
			cp -f $dir_local/$ftp_host/fw_daemon $dir_exec
			chmod 777 $dir_exec/vision_box_DualCam
			chmod 777 $dir_exec/fw_daemon
		fi

	elif [ "$2" = "do" ]; then
		echo "gpioset 0 3=$3 7=$3"
		gpioset 0 3=$3 7=$3

	elif [ "$2" = "led" ]; then
		echo "led..."
		if [ "$3" = "green" ]; then
			status_red=0
			status_green=1
		elif [ "$3" = "red" ]; then
			status_red=1
			status_green=0
		elif [ "$3" = "orange" ]; then
			status_red=1
			status_green=1
		else
			status_red=0
			status_green=0
		fi

		echo "led 1 : gpioset 0 79=$status_red 80=$status_green"
		gpioset 0 79=$status_red 80=$status_green
		sleep 0.5
		echo "led 2 : gpioset 0 81=$status_red 82=$status_green"
		gpioset 0 81=$status_red 82=$status_green
		sleep 0.5
		echo "led 3 : gpioset 0 114=$status_red 115=$status_green"
		gpioset 0 114=$status_red 115=$status_green
		sleep 0.5

		if is_visionhub ; then
			echo "led 4 : gpioset 0 116=$status_red 117=$status_green"
			gpioset 0 116=$status_red 117=$status_green
			sleep 0.5
			echo "led 5 : gpioset 0 119=$status_red 120=$status_green"
			gpioset 0 119=$status_red 120=$status_green
		fi

	elif [ "$2" = "pwm" ]; then
		echo "pwm..."
		# ps aux | grep fw_daemon
		# echo "ex : aic pwm 1 50"
		# curl http://localhost:8765/fw/pwm/$3/$4

		dir_pwm="/sys/devices/platform/soc/10048000.pwm/pwm/pwmchip0"
		pwmTarget="$dir_pwm/pwm0"
		pwmPeriod=200000	# 5 kHz

		if [ "$3" = "enable" ]; then
			cd $dir_pwm
			echo 0 > /sys/class/pwm/pwmchip0/export
			# echo 1 > /sys/class/pwm/pwmchip0/export
			sleep 0.5 
			echo $pwmPeriod > $pwmTarget/period
		elif [ "$3" = "25" ]; then
			duty=$((pwmPeriod / 4))
			echo $duty > "$pwmTarget/duty_cycle"
		elif [ "$3" = "50" ]; then
			duty=$((pwmPeriod / 2))  # 50% duty
			echo $duty > "$pwmTarget/duty_cycle"
		elif [ "$3" = "100" ]; then
			duty=$pwmPeriod
			echo $duty > "$pwmTarget/duty_cycle"
		elif [ "$3" = "on" ]; then
			echo 1 > $pwmTarget/enable
		elif [ "$3" = "off" ]; then
			echo 0 > $pwmTarget/enable
		fi

	elif [ "$2" = "stress" ]; then
		echo "run stress..."
		dir_npu="/mnt/reserved/10.1.13.207/stress_npu"
		if [ "$3" = "on" ]; then
			curl http://localhost:8765/fw/pwm/1/100
			if is_visionhub ; then
				curl http://localhost:8765/fw/pwm/2/100
				gst-launch-1.0 aravissrc camera-name=id1 ! videoconvert ! video/x-raw,format=NV12,width=1536,height=1024 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true &
				gst-launch-1.0 aravissrc camera-name=id2 ! videoconvert ! video/x-raw,format=NV12,width=1536,height=1024 ! queue ! fpsdisplaysink video-sink=waylandsink sync=false text-overlay=true &
			else
				declare -a VIDEO_DEV=(`v4l2-ctl --list-devices | grep mtk-v4l2-camera -A 3 | grep video | tr -d "\n"`)
				gst-launch-1.0 v4l2src device=${VIDEO_DEV[0]} ! videoconvert ! video/x-raw,width=1280,height=720 ! fpsdisplaysink video-sink=waylandsink sync=false &
			fi
			stress-ng --cpu 8 &
			genio-stress-gpu &
			chmod 777 $dir_npu/stress_npu/stress_npu.sh
			$dir_npu/stress_npu.sh &
			
		elif [ "$3" = "off" ]; then
			pkill stress
			pkill neuronrt
			pkill gst
			curl http://localhost:8765/fw/pwm/1/0
			if is_visionhub ; then
				curl http://localhost:8765/fw/pwm/2/0
			fi
		fi

	fi
fi

# AICamera G1
if [ "$1" = "g1" ]; then
	if [ "$2" = "ftp" ]; then
		echo "copy files from ftp..."
		cd /media/primax

		pkill vision_box

		dir_ftp="Public/AICameraG1"
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/bin.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/docs.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/etc.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/include.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/kmodules.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/lib.tar.gz
		wget ftp://gray.lin:Zx03310331@10.1.13.207/$dir_ftp/apps.tar.gz	           
	fi
fi

# use systemd-networkd
# not use NetworkManager
if [ "$1" = "eth0" ]; then
	if [ "$2" = "static" ]; then
		ip_last_num=99

		if [ "$3" != "" ]; then
			lan="192.168.$3"
			echo "set static IP to $lan.$ip_last_num"
			sed -i '/^\[Network\]/,/^$/d' /etc/systemd/network/00-eth0.network
			echo -e "[Network]\nAddress=$lan.$ip_last_num/24\nGateway=$lan.1\nDNS=8.8.8.8" | tee -a /etc/systemd/network/00-eth0.network
		else
			lan="192.168.1"
			echo "set static IP to $lan.$ip_last_num"
			sed -i '/^\[Network\]/,/^$/d' /etc/systemd/network/00-eth0.network
			echo -e "[Network]\nAddress=$lan.$ip_last_num/24\nGateway=$lan.1\nDNS=8.8.8.8" | tee -a /etc/systemd/network/00-eth0.network
		fi
		echo "write to /etc/systemd/network/00-eth0.network"

	elif [ "$2" = "dhcp" ]; then
		echo "reset to dhcp..."
		sed -i '/^\[Network\]/,/^$/d' /etc/systemd/network/00-eth0.network
	
	elif [ "$2" = "e" ]; then
		echo "nano /etc/systemd/network/00-eth0.network"
		nano /etc/systemd/network/00-eth0.network	

	elif [ "$2" = "c" ]; then
		echo "ip addr flush dev eth0"
		ip addr flush dev eth0	

	elif [ "$2" = "r" ]; then
		echo "systemctl restart systemd-networkd"
		systemctl restart systemd-networkd

	else
		echo "========== ip addr show eth0 =========="
		ip addr show eth0
		echo "cat /etc/systemd/network/00-eth0.network  =========="
		cat /etc/systemd/network/00-eth0.network
	fi
fi

# Test
if [ "$1" = "tv" ]; then
	echo "call vision_box..."
	url="http://localhost:9876/fw/$2"
	echo "curl $url"
	curl $url
elif [[ "$1" = "tt" || "$1" = "tf" ]]; then
	echo "call fw_daemon..."
	url="http://localhost:8765/fw/$2"
	echo "curl $url"
	curl $url
fi

# system related 
if [ "$1" = "sys" ]; then
	if [ "$2" = "service" ]; then
		echo "========== Service info =========="
		service --status-all
		#ls /etc/init.d
	elif [ "$2" = "info" ]; then
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
	elif [ "$2" = "users" ]; then
		# awk -F: '{ print $1}' /etc/passwd
		echo "========== online User =========="
		w

		# list normal users
		echo "========== User range =========="
		grep -E '^UID_MIN|^UID_MAX' /etc/login.defs
		echo "========== User info =========="
		getent passwd {1000..60000}

	elif [ "$2" = "user" ]; then
		id -nG $3
	elif [ "$2" = "net" ]; then
		echo "========== nmap -A 192.168.100.* =========="
		nmap -A 192.168.100.*
	else
		echo "param 3 not match"
		exit -1
	fi
fi

# gedit
if [ "$1" = "ge" ]; then
	if [ "$2" = "x" ]; then
		cd $xDir
		gedit x.sh
	elif [ -n "$2" ]; then
		gedit $2
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# vs code
if [ "$1" = "code" ]; then
	if [ "$2" = "x" ]; then
		code $xDir/x.sh
	elif [ "$2" = ".rc" ]; then
		code ~/.bashrc
	elif [ "$2" = "s" ]; then
		code $xDir/s.sh
	elif [ -n "$2" ]; then
		echo "do nothing"
	else
		echo "param 2 not match"
		exit -1
	fi
fi

# rename project
if [ "$1" == "rename" ]; then

	if [ ! -n "$2" ] || [ ! -n "$3" ]; then
		echo "param 3 & 4 shoud not be null"
		exit -1
	fi

	if [ "$4" == "1" ]; then
		echo "step 1 : rename file content"
		find . -name "*.*" -type f -exec sed -i "" "s/$2/$3/g" {} \; 
	elif [ "$4" == "2" ]; then
		echo "step 2 : rename file name"
		find . -name "*$2*" -type f -exec rename "s/$2/$3/g" {} \; 	
	elif [ "$4" == "3" ]; then
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
if [ "$1" = "ftp" ]; then
	if [ "$2" = "restart" ]; then
		service vsftpd restart
		sleep 1
		service vsftpd status
	elif [ "$2" = "status" ]; then
		service vsftpd status
	elif [ "$2" = "stop" ]; then
		service vsftpd stop
	elif [ "$2" = "d+g" ]; then
		# add group access for some dir
		echo "ex : sudo setfacl -Rdm g:SAC_EE:rwx DirName/"
		echo "sudo setfacl -Rdm g:$4:rwx $3"
		sudo setfacl -Rdm g:$4:rwx $3
	elif [ "$2" = "user+" ]; then
		if [ -n "$3" ]; then
			if [ "$4" = "sidee" ]; then
				# SAC EE team group
				sudo useradd  -m $3 -g "SAC_EE" -s /bin/bash
			elif [ "$4" = "sidme" ]; then
				# SAC ME team group
				sudo useradd  -m $3 -g "SAC_ME" -s /bin/bash
			elif [ "$4" = "all" ]; then
				# all ftp available group
				sudo useradd  -m $3 -G "SAC_EE,SAC_ME,SAC_SW,docker" -s /bin/bash
			elif [ "$4" = "sidsw" ]; then
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
	elif [ "$2" = "user-" ]; then
		sudo userdel -r $3
elif [ "$2" = "user+g" ]; then
		sudo usermod -aG $3 $4
	elif [ "$2" = "config" ]; then
		code /etc/vsftpd.conf
	else
		echo "param 2 not match"
		exit -1
	fi
fi

if [ "$1" = "date" ]; then

	if [ "$2" = "+8" ]; then
		timedatectl set-timezone Asia/Singapore
	else
		timedatectl set-ntp yes
		date
	fi
fi

# logout
if [ "$1" = "logout" ]; then
	gnome-session-quit
fi

# file manager
if [ "$1" = "cd" ]; then
	echo "XDG_CURRENT_DESKTOP:$XDG_CURRENT_DESKTOP" 
	if [  "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
			dolphin $2
		elif [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
			nautilus $2
		else
			echo "param 2 not match"
			exit -1
		fi
fi

# chown
if [ "$1" = "chown" ]; then
	if [ -n "$2" ]; then
		if [ "$2" = "all" ]; then
			sudo chown -R nobody:nogroup .
		else
			sudo chown nobody:nogroup $2
		fi
	fi
fi

# tar
if [ "$1" = "zip" ]; then
    echo " zip $2 to $3.tar.gz =========="
    tar -zcvf "$3.tar.gz" "$2"
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

# chmod
if [ "$1" = "chmod" ]; then
	if [ -n "$2" ]; then
		if [ "$2" = "all" ]; then
			if [ "$3" = "4" ]; then
				sudo chmod -R 444 .
			elif [ "$3" = "6" ]; then
				sudo chmod -R 666 .
			else
				sudo chmod -R 777 .
			fi
		else
			if [ "$3" = "4" ]; then
				sudo chmod -R 444 $2
			elif [ "$3" = "6" ]; then
				sudo chmod -R 666 $2
			else
				sudo chmod -R 777 $2
			fi
		fi
	fi
fi

# ssh
if [ "$1" = "ssh" ]; then
	if [ "$2" = "status" ]; then
		service sshd status

	elif [ "$2" == "wt" ]; then
		# wheeltech
		if [ "$3" = "r" ]; then
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

# gitlab
if [ "$1" = "git" ]; then
	if [ "$2" = "up" ]; then
		docker-compose -f "$gitDir/docker-compose-git.yml" up -d
		# docker-compose -f "$gitDir/docker-compose-git.yml" up
	elif [ "$2" = "down" ]; then
		docker-compose -f "$gitDir/docker-compose-git.yml" down
	elif [ "$2" = "stop" ]; then
		docker stop gitlab
		
	elif [ "$2" = "chmod" ]; then
		sudo chmod 755 $gitDir_Data/backups/
		sudo chmod 755 $gitDir_Data/backups/
		sudo chmod 777 $gitDir_Config/gitlab.rb
		sudo chmod 777 $gitDir_Config/gitlab-secrets.json 

	elif [ "$2" = "tar" ]; then
		# backup tar file
		sudo chmod 755 $gitDir_Data/backups/
		if [ "$3" = "in" ]; then
			sudo mv $gitDir/$gitBackupFile"_gitlab_backup.tar" $gitDir_Data/backups/
		elif [ "$3" = "out" ]; then
			sudo mv $gitDir_Data/backups/$gitBackupFile"_gitlab_backup.tar" $gitDir/
		else
			echo ">> param 3 should be 'in' or 'out'"
		fi
	elif [ "$2" = "compose" ]; then
		# open compose file
		code $gitDir/docker-compose-git.yml
		
	elif [ "$2" = "config" ]; then
		if [ "$3" = "code" ]; then
			code $gitDir/config/gitlab.rb
			code $gitDir/config/gitlab.yml
		elif [ "$3" = "in" ]; then
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
		elif [ "$3" = "out" ]; then
			sudo chmod 755 $gitDir_ConfigR
			sudo chmod 666 $gitDir_Config/gitlab.rb
			sudo chmod 666 $gitDir_ConfigR/gitlab.yml 
			cp $gitDir_Config/gitlab.rb $gitDir/config/
			cp $gitDir_ConfigR/gitlab.yml $gitDir/config
		elif [ "$3" = "update" ]; then
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
			echo "========== docker exec -it gitlab gitlab-ctl reconfigure =========="
			docker exec -it gitlab gitlab-ctl reconfigure
			echo "========== docker exec -it gitlab gitlab-ctl restart =========="
			docker exec -it gitlab gitlab-ctl restart
		else
			echo ">> param 3 not match"
		fi
	elif [ "$2" = "check" ]; then
		echo "========== docker exec -it gitlab gitlab-rake gitlab:check SANITIZE=true =========="
		docker exec -ti gitlab gitlab-rake gitlab:check SANITIZE=true
	elif [ "$2" = "info" ]; then
		echo "========== docker exec -ti gitlab gitlab-rake gitlab:env:info =========="
		docker exec -ti gitlab gitlab-rake gitlab:env:info
	elif [ "$2" = "bash" ]; then
		echo "========== docker exec -it gitlab /bin/bash =========="
		docker exec -ti gitlab /bin/bash
	elif [ "$2" = "psql" ]; then
		echo "========== docker exec -it gitlab gitlab-psql =========="
		docker exec -ti gitlab gitlab-psql
	elif [ "$2" = "rail" ]; then
		echo "========== docker exec -it gitlab gitlab-rails console =========="
		docker exec -ti gitlab gitlab-rails console
	elif [ "$2" = "log" ]; then
		echo "========== docker logs -tf gitlab =========="
		docker logs -tf --since 1m gitlab
	elif [ "$2" = "backup" ]; then
		echo "========== docker exec -it gitlab gitlab-rake gitlab:backup:create =========="
			docker exec -ti gitlab gitlab-backup create

			# GitLab 12.1 and earlier
			# docker exec -ti gitlab gitlab-rake gitlab:backup:create
	elif [ "$2" = "restore" ]; then
		if [ "$3" = "1" ]; then
			echo "========== step 1 : stop connectivity services ==========" 
			# docker exec -it gitlab gitlab-ctl stop unicorn
			docker exec -it gitlab gitlab-ctl stop puma
			docker exec -it gitlab gitlab-ctl stop sidekiq
			docker exec -it gitlab gitlab-ctl status
		elif [ "$3" = "2" ]; then
			echo "========== step 2 : restore from backup tar : $gitBackupFile ==========" 
			docker exec -it gitlab gitlab-backup restore BACKUP=$gitBackupFile

			# gitlab-backup restore BACKUP=1643394275_2022_01_28_14.1.6
			# GitLab 12.1 and earlier
			# docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=$gitBackupFile
		elif [ "$3" = "3" ]; then
			echo "========== step 3 : re-configure & re-start ==========" 
			echo "========== docker exec -it gitlab gitlab-ctl reconfigure =========="
			docker exec -it gitlab gitlab-ctl reconfigure
			echo "========== docker exec -it gitlab gitlab-ctl restart =========="
			docker exec -it gitlab gitlab-ctl restart

		elif [ "$3" = "4" ]; then
			# config
			cp -rf $gitDir/config/gitlab.rb $gitDir_Config
		else
			echo ">> param 3 not match"
		fi

	elif [ "$2" = "sp" ]; then
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

# docker
if [ "$1" = "dk" ]; then

	if [ "$2" = "i" ]; then
		# image related
		if  [ "$3" = "ins" ]; then
			#inspect volume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" = "rm" ]; then
			echo "========== docker image rm $4 ========== " 
			docker image rm $4
		else
			# list images
			echo "========== docker image ls ========== " 
			docker image ls
		fi

	elif [ "$2" = "c" ]; then
		# container related
		if  [ "$3" = "ins" ]; then
			echo "========== docker inspect 'container id'========== " 
			docker inspect $4
		elif  [ "$3" = "stop" ]; then
			echo "========== docker container stop 'Container ID' ========== " 
			docker container stop $4
		elif  [ "$3" = "rm" ]; then
			echo "========== docker container rm 'Container ID' ========== " 
			
			# remove all stoped container
			docker rm $(docker ps -a -q) 

			docker container rm -f $4
		else
			# list containers
			echo "========== docker container ls ========== " 
			docker container ls
		fi
		
	elif [ "$2" = "v" ]; then

		if  [ "$3" = "ins" ]; then
			#inspect valume
			echo "========== docker volume inspect 'Volume Name' ========== " 
			docker volume inspect $4
		elif  [ "$3" = "rm" ]; then
			# inspect valume
			echo "========== docker volume rm 'Volume Name' ========== " 
			docker volume rm -f $4
		else
			echo "========== docker volume ls ========== " 
			docker volume ls
		fi

	elif [ "$2" = "bash" ]; then

		if [ -n "$3" ]; then
			echo "========== docker exec -it $3 bash ========== " 
			docker exec -it $3 bash
		else
			echo ">> container ID needed!"
			echo "========== docker container ls ========== " 
			docker container ls
		fi

	elif [ "$2" = "clean" ]; then

		if [ "$3" = "all" ]; then
			# remove all stopped containers, all dangling images, all unused volumes, and all unused networks
			echo "========== docker system prune --volumes ========== " 
			# docker system prune
			docker system prune --volumes

		elif  [ "$3" = "i" ]; then
			# remove image
			if [ -n "$4" ]; then
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
if [ "$1" = "dkc" ]; then
	if [ -n "$3" ]; then
		if [ "$2" = "up" ]; then
			echo "========== docker-compose -f $3 up ========== " 
			# docker-compose -f $3 up -d
			docker-compose -f $3 up
		elif [ "$2" = "down" ]; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
		elif [ "$2" = "r" ]; then
			echo "========== docker-compose -f $3 up ========== " 
			docker-compose -f $3 down
			docker-compose -f $3 up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	else
		if [ "$2" = "up" ]; then
			echo "========== docker-compose  ========== " 
			docker-compose up -d
		elif [ "$2" = "down" ]; then
			docker-compose down
		elif [ "$2" = "r" ]; then
			docker-compose down
			docker-compose up -d
		else
			echo "========== docker-compose donothing ========== " 
		fi
	fi
fi

# update x
if [ "$1" == "ux" ]; then
	cd ~/OSPath
	git reset --hard HEAD
	git pull
	sudo chmod 777 AICamera/x.sh
fi

# find
if [ "$1" == "find" ]; then
	echo "find . -name \"$2\""
	find . -name "$2" 
fi

