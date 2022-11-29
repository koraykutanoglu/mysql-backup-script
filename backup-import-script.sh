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

      if [ "$REMOTE_BACKUP_IMPORT" == "yes" ]; then

        if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

          message="🔴 You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
          curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
        fi  

        echo "You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
        exit 1

      else

        if [ "$REMOTE_BACKUP_IMPORT" == "no" ]; then

          echo "${separator// /-}"
          echo "Loading Local Backups is Starting."
          echo "${separator// /-}"
          
          for databasesi in $(ls $LOCAL_BACKUP_DIRECTORY); do 

            databasename=$(echo $databasesi | tr '+' ' ' | awk '{print $1}')
            mysql -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $databasename < $LOCAL_BACKUP_DIRECTORY/$databasesi
            echo "${separator// /-}"
            echo $databasename database imported
            echo "${separator// /-}"

          done

          if [ "$DELETE_THE_BACKUP_AFTER_INSTALLING" == "yes" ]; then

            rm -rf $LOCAL_BACKUP_DIRECTORY/*.sql
  
          fi 

          if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

            message="🟢 MySQL Databases Import Is Completed."
            curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
          fi

          exit 1

        else

        echo "You should set the value to yes or no!"
        exit 1
        
        fi
      
      fi

    else

      if [ "$LOCAL_BACKUP_IMPORT" == "no" ]; then

        if [ "$REMOTE_BACKUP_IMPORT" == "no" ]; then

          if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

            message="🔴 You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
            curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
          fi  

          echo "You cannot set the LOCAL_BACKUP_IMPORT and REMOTE_BACKUP_IMPORT definitions to yes or no at the same time."
          exit 1

        else

          if [ "$REMOTE_BACKUP_IMPORT" == "yes" ]; then
  
            if [ "$REMOTE_BACKUP_IMPORT_SEQUENTIAL_DELIVERY" == "yes" ]; then

              echo "Backups on the remote server will be loaded. The process is starting."
              echo "Backups on the remote machine will be transferred to the local machine."

              for databasesi in $(ssh $BACKUP_HOST_USERNAME@$BACKUP_HOST "ls $BACKUP_HOST_LOCATION"); do 
                
                cd $LOCAL_BACKUP_WORKING_DIRECTORY
                scp $BACKUP_HOST_USERNAME@$BACKUP_HOST:$BACKUP_HOST_LOCATION/$databasesi .
                databasename=$(echo $databasesi | tr '+' ' ' | awk '{print $1}')
                mysql -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $databasename < $LOCAL_BACKUP_WORKING_DIRECTORY/$databasesi
                echo "${separator// /-}"
                echo $databasename database imported.
                echo "${separator// /-}"
                echo $databasename database removed.
                rm -rf $LOCAL_BACKUP_WORKING_DIRECTORY/$databasesi

              done

            if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

              message="🟢 MySQL Databases Import Is Completed."
              curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
            fi  
            
            echo "${separator// /-}"
            echo "MySQL Databases Import Is Completed."

            exit 1 

            fi
            
            echo "Backups on the remote server will be loaded. The process is starting."
            echo "Backups on the remote machine will be transferred to the local machine."
            cd $LOCAL_BACKUP_WORKING_DIRECTORY
            scp $BACKUP_HOST_USERNAME@$BACKUP_HOST:$BACKUP_HOST_LOCATION/*.sql .

            for databasesi in $(ls $LOCAL_BACKUP_WORKING_DIRECTORY); do 

              databasename=$(echo $databasesi | tr '+' ' ' | awk '{print $1}')
              mysql -h $MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $databasename < $LOCAL_BACKUP_WORKING_DIRECTORY/$databasesi
              echo "${separator// /-}"
              echo $databasename database imported
              echo "${separator// /-}"

            done

            if [ "$DELETE_THE_BACKUP_AFTER_INSTALLING" == "yes" ]; then

              rm -rf $LOCAL_BACKUP_WORKING_DIRECTORY/*.sql
  
            fi 

            if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

              message="🟢 MySQL Databases Import Is Completed."
              curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
            fi            

            exit 1

          else

            if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

              message="🔴 You should set the value to yes or no!."
              curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
            fi   

            echo "You should set the value to yes or no!"
            exit 1            

          fi
        
        fi   

      else 

        if [ "$TELEGRAM_NOTIFICATION" == "yes" ]; then

          message="🔴 You should set the value to yes or no!."
          curl -s --data "text=$message" --data "chat_id=$TELEGRAM_BOT_CHAT_ID" 'https://api.telegram.org/bot'$TELEGRAM_BOT_API'/sendMessage' > /dev/null
  
        fi  

        echo "You should set the value to yes or no!"
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