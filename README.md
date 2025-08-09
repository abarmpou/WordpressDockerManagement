# Wordpress Docker Management
A collection of bash scripts for creating, and maintaining a wordpress website using docker.
Tested in Ubuntu 22.04.

### Prerequisites

There are a few basic prerequisites which can be installed by:
```
git clone https://github.com/abarmpou/WordpressDockerManagement.git
WordpressDockerManagement/lightsail_setup.sh
```

## How to create a wordpress docker website

In the terminal type: `./create_site.sh somesite`

This will create a docker wordpress container `somsite_wp` and a database container `somesite_db` and will make the site accessible at `http://localhost:8101/`.

If you want to create the site in a specific path type: `./create_site.sh -u https://www.example.com/some/site/ somesite`

This will create a docker wordpress container `somsite_wp` and a database container `somesite_db` and will make the site accessible at `http://localhost:8101/some/site/`.

To copy the database from an existing wordpress site you need to do: `mysqldump --no-tablespaces --single-transaction -u user -p DBNAME > backup.sql`
and zip the website files by going into the directory `cd /var/www/html` `zip -r /home/user/backup.zip .` 

## How to change the wordpress URL of a website

In the terminal type: `./change_url.sh -u https://www.example.com/some/site/ somesite`

This will change the wordpress url entries in `somesite_db` database to `https://www.example.com/some/site/`

## How to backup a wordpress docker website

In the terminal type: `./backup_site.sh somesite`

This will save the website files in a file `somesite_datestamp.zip` and the database in a file `somesite_datestamp.sql`. 

## How to delete a wordpress docker website

In the terminal type: `./remove_site.sh somesite`

This will stop and remove the containers `somesite_wp` and `somesite_db`. If you also want to remove the files from your local drive type: `rm -r somesite`.

## How to restore a wordpress docker website

If you have previously used `backup_site.sh` to create a backup of a wordpress website, you can restore it by the following:

```
./create_site.sh somesite
./restore_site.sh somesite somesite_datestamp
```
