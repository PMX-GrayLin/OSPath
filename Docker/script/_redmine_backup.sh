
redDir_Home="/var/lib/docker/volumes/redmine_vHome/_data"
redDir_Postgres="/var/lib/docker/volumes/redmine_vPostgres/_data"
redDir_Files="/var/lib/docker/volumes/redmine_vFiles/_data"
backupDir="/mnt/disk2/backups/redmine"

cd $backupDir

# TODAY=$(date +"%Y%m%d_%I%M%S")
TODAY=$(date +"%Y%m%d_%I%M")
echo $TODAY
# rm -r $TODAY
mkdir $TODAY
chmod 777 $TODAY
cd $TODAY

# backup DB ================================================================================
## use yaml_db >>  backup & restore ok
## dump contents of database to db/data.yml
docker exec redmine rake db:data:dump
cp $redDir_Home/db/data.yml .

## use pg_dump >> pg_restore get lots of warning, still need to try
# docker exec -it postgres pg_dump -U postgres -Fc --file=var/lib/postgresql/redmine.sqlc redmine
docker exec postgres pg_dump -U postgres -Fc --file=var/lib/postgresql/redmine.sqlc redmine
cp $redDir_Postgres/redmine.sqlc .

# backup files folder ================================================================================
# sudo chmod 777 $redDir_Files/
tar -zcvf redmineFiles.tar.gz $redDir_Files/*

# make all file in backupDir accessable
chmod 777 *
