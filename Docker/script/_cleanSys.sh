
FTPDir="/home/test/FTP"
backupDir_git="/mnt/disk2/backups/gitlab"
backupDir_redmine="/mnt/disk2/backups/redmine"

# clean Jenkins build folder
find $FTPDir/Public/Jenkins/sav530q-20200522 -mtime +180 -type d -exec rm -rf {} \;
find $FTPDir/Public/Jenkins/sav530q-20200804 -mtime +180 -type d -exec rm -rf {} \;
find $FTPDir/Public/Jenkins/sav530q-BUZZ_20200804 -mtime +180 -type d -exec rm -rf {} \;
find $FTPDir/Public/Jenkins/sav530q_dualos-eve20200806 -mtime +180 -type d -exec rm -rf {} \;

# clean backups
find $backupDir_git -type f -mtime +90 -exec rm -f {} \;
find $backupDir_redmine -type f -mtime +90 -exec rm -f {} \;

# clean systemd journal logs
journalctl --vacuum-time=3d

# clean the thumbnail cache
rm -rf ~/.cache/thumbnails/*

# apt
apt-get --assume-yes clean
apt-get --assume-yes autoclean
apt-get --assume-yes autoremove

# do some routines below ==========================================

# chmod 777 to public folder
# chmod 777 -R $FTPDir/Public/