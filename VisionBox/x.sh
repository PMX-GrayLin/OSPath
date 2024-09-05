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

echo xDir = $xDir
echo "param 0:"$0
echo "param 1:"$1
echo "param 2:"$2
echo "param 3:"$3
echo "param 4:"$4
echo "param 5:"$5

# update x
if [ "$1" == "ux" ] ; then
	cd ~/OSPath
	git reset --hard HEAD
	git pull
	sudo chmod 777 VisionBox/x.sh
fi

# VisionBox 
if [ "$1" == "vb" ] ; then
	echo "VisionBox command..."
	appDir="vision_box_DualCam_gray"
	cd ~/primax/apps

	if [ "$2" = "jobs" ] ; then
		pm2 list

	elif [ $2 = "git" ] ; then
		echo "update src..."
		cd $appDir 
		git reset --hard HEAD
		git pull
		git clone https://github.com/PMX-GrayLin/vision_box_DualCam_gray.git

	elif [ $2 = "b" ] ; then
		echo "Build..."
		cd $appDir 
		make

	elif [ $2 = "r" ] ; then
		echo "Run..."
		cd $appDir 
		./vision_box_DualCam
	

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
				sudo chmod -R 444 .
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

