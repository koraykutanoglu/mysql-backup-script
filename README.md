## Advanced MySQL Backup Script

- First clone the repository.

```
git clone https://github.com/koraykutanoglu/mysql-backup-script
```

- Go to the directory of the repository.

```
cd mysql-backup-script
```

- In order for the script to work properly, you need to edit the contents of the environment file according to yourself.

```
nano environment
```

- The contents of the environment file are as follows and when you open it you will see a special note for each definition:

```
# MySQL host: IP or localhost (example: 10.10.10.10 or localhost)
MYSQL_HOST=localhost

# MySQL username: example root because it can access every database.
MYSQL_USERNAME=root

# Root password to connect to MySQL.
MYSQL_PASSWORD=Password1

# How long the backups are held in minutes. (will delete all backups exceeding this minute while script is running)
RETENTION_MINUTE=5

# Which directory the backups will be sent to on the machine where the script is running. Important! Do not set public directories such as /root /bin. Just set a directory with backups. It's dangerous because it's deleted.
MYSQL_BACKUP_LOCATION=/Users/koray/Desktop/backup

# Will MySQL be sent to a remote server? If you set it to "no", the backups will be taken to the local directory you specified. If the answer is no, do not fill in the associated environments. It is not taken into account.
MYSQL_BACKUP_SEND_TO_REMOTE="yes"

# The IP address of the machine where the backup will be made.
BACKUP_HOST=34.118.57.xxx

# SSH username:
BACKUP_HOST_USERNAME=root

# SSH password is not written here. Since we do not use an SSH password, we copy our private key to the target machine with the ssh-copy-id command.
BACKUP_HOST_PASSWORD=ssh-copy-id

# Which directory will the backups be sent to on the backup machine?
BACKUP_HOST_LOCATION=/root/backup

# How long will the backups be kept on the backup machine? (Old ones will be deleted.)
BACKUP_HOST_BACKUP_RETENTION_MINUTE=5

# While the backup is being made, should the backups be backed up one by one and sent to the backup server? If the answer is "no", the backup will be taken at once and the backups will be sent at once. Leave "yes" if you have low disk space.
SEQUENTIAL_DELIVERY="yes"

# Do you want notification via Telegram?
TELEGRAM_NOTIFICATION="yes"

# What is the API of the Telegram bot?
TELEGRAM_BOT_API=xxxxxxxx

# What is the ID of the chat that the Telegram bot will send messages to?
TELEGRAM_BOT_CHAT_ID=xxxxxxxx

# DATABASE IMPORT ----------------------------------------------------------------------

# This part is used to restore backups. The following two options cannot be yes or no on the mirror. The LOCAL_BACKUP_IMPORT option restores local backups. The REMOTE_BACKUP_IMPORT option imports and uploads backups from the remote server to itself.
LOCAL_BACKUP_IMPORT="no"
REMOTE_BACKUP_IMPORT="yes"

# The LOCAL_BACKUP_DIRECTORY option takes effect when the LOCAL_BACKUP_IMPORT option is set to yes. You need to enter that directory where the backups are to be installed.
LOCAL_BACKUP_DIRECTORY=/Users/koray/Desktop/backup

# The LOCAL_BACKUP_WORKING_DIRECTORY option works when the REMOTE_BACKUP_IMPORT option is yes. You need to specify where the files pulled from the remote server will be transferred locally.
LOCAL_BACKUP_WORKING_DIRECTORY=/Users/koray/Desktop/backup/cekilecekyedekler

# Delete backups after import?
DELETE_THE_BACKUP_AFTER_INSTALLING="yes"

# Should backups be sequentially imported? So, take the backup, install the backup, delete the backup steps?
REMOTE_BACKUP_IMPORT_SEQUENTIAL_DELIVERY="yes"
```

- After editing the environment file, save and exit and set a cron. Here we set hourly cron by default. We create a file. (If you want daily or weekly: /etc/cron.weekly, /etc/cron.daily)

```
nano /etc/cron.hourly/mysql-backup-script
```

- Insert the following content:

```
#!/bin/sh

bash /root/mysql-backup-script/backup-script.sh
```

- Give the file run permission.

```
chmod +x /etc/cron.hourly/mysql-backup-script
```
