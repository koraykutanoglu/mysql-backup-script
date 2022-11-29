#!/bin/bash

separator=$(printf "%-73s" "-")
DATE=`date '+%F_%H-%M-%S'`;

if [ -f "environment" ]; then 

  echo "${separator// /-}"

  echo "Environment file is now exporting"
  export $(cat environment | xargs)


    if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

      message="🟢 MySQL Databases Backup Is Starting"
      curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
    fi

  echo "${separator// /-}"

  echo "MySQL up and down?"

  echo "${separator// /-}"

  mysqladmin -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD processlist


    if [ $? -eq 0 ];  then
      
      echo "MySQL is running"

      echo "${separator// /-}"

      echo "MySQL backup is starting"

      echo "${separator// /-}"

      if [ "$MYSQL_BACKUP_SEND_TO_REMOTE" == "yes" ]; then

        echo "backup is sending"
        echo "${separator// /-}"
        echo "Check SSH information if script is waiting here."
        echo "${separator// /-}"

        ssh $BACKUP_HOST_USERNAME@$BACKUP_HOST "mkdir -p $BACKUP_HOST_LOCATION"


          if [ "$SEQUENTIAL_DELIVERY" == "yes" ]; then

            for databases in $(mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h $MYSQL_HOST -e "SHOW DATABASES;"  | awk 'NR>1 {print $1}'); do 

              echo $databases database started to be backed up

                if [ "$databases" ==  "performance_schema" ] || [ "$databases" ==  "information_schema" ] || [ "$databases" ==  "mysql" ] || [ "$databases" ==  "sys" ] ; then
               
                  echo $databases database excluded from backup

                else 

              echo "${separator// /-}"
      
              mysqldump -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $databases > $MYSQL_BACKUP_LOCATION/$databases+$DATE.sql

              scp $MYSQL_BACKUP_LOCATION/$databases+$DATE.sql $BACKUP_HOST_USERNAME@$BACKUP_HOST:$BACKUP_HOST_LOCATION

              rm -rf $MYSQL_BACKUP_LOCATION/$databases+$DATE.sql
              
                if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

                  message="MySQL $databases+$DATE.sql database backed up"
                  curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
                
                fi

              echo "${separator// /-}"

                fi

            done

          else

            for databases in $(mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h $MYSQL_HOST -e "SHOW DATABASES;"  | awk 'NR>1 {print $1}'); do 

            echo $databases database started to be backed up

              if [ "$databases" ==  "performance_schema" ] || [ "$databases" ==  "information_schema" ] || [ "$databases" ==  "mysql" ] || [ "$databases" ==  "sys" ] ; then
               
                echo $databases database excluded from backup

              else 

                echo "${separator// /-}"
      
                mysqldump -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $databases > $MYSQL_BACKUP_LOCATION/$databases+$DATE.sql


                  if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then
                    
                    message="MySQL $databases+$DATE.sql database backed up"
                    curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
                  
                  fi

                echo "${separator// /-}"

              fi

            done

              scp $MYSQL_BACKUP_LOCATION/* $BACKUP_HOST_USERNAME@$BACKUP_HOST:$BACKUP_HOST_LOCATION
              rm -rf $MYSQL_BACKUP_LOCATION/*.sql

          fi

        echo "${separator// /-}"

        echo "local backup is deleting"

        echo "${separator// /-}"

#        rm -rf $MYSQL_BACKUP_LOCATION/*

        echo "${separator// /-}"
        
        echo Backup machine $BACKUP_HOST_LOCATION directory check backup retention

        echo "${separator// /-}"

        echo "deleting $BACKUP_HOST_BACKUP_RETENTION_MINUTE minute before"
 
        ssh $BACKUP_HOST_USERNAME@$BACKUP_HOST "find $BACKUP_HOST_LOCATION/*.sql -mmin +$BACKUP_HOST_BACKUP_RETENTION_MINUTE -delete"

        echo "${separator// /-}"

        echo "deleted $BACKUP_HOST_BACKUP_RETENTION_MINUTE minute before"

        if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

        message="🟢 MySQL Databases Backup Is Completed"
        curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
        
        fi

        exit 1
        
      fi

      exit 1
    
    fi
  
    if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

      message="🔴 MySQL Is Not Running! Backup Is Stopped"
      curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null

    fi

  echo "MySQL is not running!"
  exit 1

fi

echo "Environment file not available!"