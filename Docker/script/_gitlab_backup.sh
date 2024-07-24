

gitDir_Config="/var/lib/docker/volumes/gitlab_vConfig/_data"
gitDir_ConfigR="/var/lib/docker/volumes/gitlab_vConfig_r/_data"
gitDir_Data="/var/lib/docker/volumes/gitlab_vData/_data"
backupDir="/mnt/disk2/backups/gitlab"


cd $backupDir

# # TODAY=$(date +"%Y%m%d_%I%M%S")
# TODAY=$(date +"%Y%m%d_%I%M")
# echo $TODAY
# # rm -r $TODAY
# mkdir $TODAY
# chmod 777 $TODAY
# cd $TODAY

# backup configuration files
mkdir "configs"
rsync -r  $gitDir_Config/ configs/

# cp $gitDir_Config/gitlab-secrets.json .
# cp $gitDir_Config/gitlab.rb .

# backup whole instance
# docker exec -ti gitlab gitlab-backup create
docker exec gitlab gitlab-backup create
chmod 777 -R $gitDir_Data/backups/
rsync -r  $gitDir_Data/backups/ .

# make all file in backupDir is accessable
# chmod 777 *

# delete file older than 90 days
# find $backupDir -type f -mtime +90 -exec rm -f {} \;
