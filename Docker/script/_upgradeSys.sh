
TODAY=$(date +"%Y%m%d_%I%M")
LOG_FILE=/home/test/Docker/logs/UpgradeRun_$TODAY
touch LOG_FILE

# docker
dockderDir=~/"Docker"
# redmine
redDir="$dockderDir/redmine"
# gitlab
gitDir="$dockderDir/gitlab"
# jenkins
jksDir="$dockderDir/jenkins"

echo "=========================" >> $LOG_FILE
echo "redmine down..." >> $LOG_FILE
# /usr/local/bin/docker-compose -f "$redDir/docker-compose-red.yml" down >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "gitlab down..." >> $LOG_FILE
# /usr/local/bin/docker-compose -f "$gitDir/docker-compose-git.yml" down >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "gitlab down..." >> $LOG_FILE
# /usr/local/bin/docker-compose -f "$jksDir/docker-compose-jenkins.yml" down >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "apt-get update start" >> $LOG_FILE
apt-get update >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "apt-get -qq upgrade start" >> $LOG_FILE
apt-get --yes upgrade >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "apt autoremove start" >> $LOG_FILE
apt-get --yes autoremove >> $LOG_FILE

echo "=========================" >> $LOG_FILE
echo "/sbin/shutdown -r now" >> $LOG_FILE
/sbin/shutdown -r now




