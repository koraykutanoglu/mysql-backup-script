#!/bin/bash

separator=$(printf "%-73s" "-")

if [ -f "environment" ]; then 

  echo "${separator// /-}"
  echo "Environment file is now exporting"
  export $(cat environment | xargs)
  
  if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

    message="🟢 MySQL Databases Import Is Starting"
    curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
  fi
  

  echo "${separator// /-}"
  echo "MySQL up and down?"
  echo "${separator// /-}"
  mysqladmin -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD processlist

  if [ $? -eq 0 ];  then
      
    echo "MySQL is running"
    
    if [ "$LOCAL_BACKUP_IMPORT" == "yes" ]; then

    echo "burada"

      if [ "$REMOTE_BACKUP_IMPORT" == "yes" ]; then

        echo "You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
        exit 1

      else

        if [ "$REMOTE_BACKUP_IMPORT" == "no" ]; then

          echo "local backup işlemleri yapılıyor"

        else

        echo "You should set the value to yes or no!2"
        exit 1
        
        fi
      
      fi

    else

      if [ "$LOCAL_BACKUP_IMPORT" == "no" ]; then

        if [ "$REMOTE_BACKUP_IMPORT" == "no" ]; then

          echo "You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
          exit 1

        else

          if [ "$REMOTE_BACKUP_IMPORT" == "yes" ]; then

            echo "remote backup import işlemi başlıyor"
          
          else

            echo "You should set the value to yes or no!"
            exit 1            

          fi
        
        fi   

      else 

        echo "You should set the value to yes or no!3"
        exit 1

      fi

    fi

  fi
    
  if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

    message="🔴 MySQL Is Not Running! Backup Is Stopped"
    curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null

  fi

  echo "MySQL is not running!"
  exit 1

fi

echo "Environment file not available!"
exit 1