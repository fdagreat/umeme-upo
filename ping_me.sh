#!/bin/bash

# Load the environment variables from the .env file
source .env.sh

# print all variables in the .env file
echo "ONLINE_URL: $ONLINE_URL"
echo "OFFLINE_URL: $OFFLINE_URL"
echo "LOGS_URL: $LOGS_URL"
echo "MAX_OFFLINE_COUNT: $MAX_OFFLINE_COUNT"
echo "MAX_LOG_FILE_SIZE: $MAX_LOG_FILE_SIZE"


echo "SERVER_IP: $SERVER_IP"
echo "MAX_OFFLINE_COUNT: $MAX_OFFLINE_COUNT"
echo "MAX_LOG_FILE_SIZE: $MAX_LOG_FILE_SIZE"


# Set the URL for the online and offline POST requests
# ONLINE_URL= process.env.ONLINE_URL
# OFFLINE_URL= process.env.OFFLINE_URL
# LOGS_URL= process.env.LOGS_URL

# Set the IP address of the server to check
# SERVER_IP= process.env.SERVER_IP

# Set the number of times the server must be offline before sending a POST request
# MAX_OFFLINE_COUNT= process.env.MAX_OFFLINE_COUNT

# Initialize a counter for the number of times the server is offline
OFFLINE_COUNT=0

# # Initialize max log file size
# # MAX_LOG_FILE_SIZE= process.env.MAX_LOG_FILE_SIZE

# variable to check if the last ping was successful
LAST_PING_SUCCESSFUL=false

# Create an output file
touch output.txt

# Clear the output file
echo "" > output.txt

# Loop forever
while true
do
  # Use the ping command to check if the server is online
  PING_RESULT=$(ping -c 1  $SERVER_IP)
  echo 'pinging server' $SERVER_IP
  echo 'we got this result' $PING_RESULT

  #log the ping result to an output file
  echo $PING_RESULT >> output.txt

  # Check if the server is online
  if [[ $PING_RESULT == *"100.0%"* ]]; then
    echo "Server is online"
    # Reset the offline counter
    OFFLINE_COUNT=0
    LAST_PING_SUCCESSFUL=true

    # Send a POST request to the online URL if the last ping was not successful
    if [ $LAST_PING_SUCCESSFUL = false ]; then
      curl -X GET $ONLINE_URL
      echo "Sent server is Online"
    fi
    
  else
    # Increment the offline counter
    OFFLINE_COUNT=$((OFFLINE_COUNT + 1))

    # Check if the server has been offline for the MAX_OFFLINE_COUNT times consecutively and the last ping was not successful
    if [ $OFFLINE_COUNT -eq $MAX_OFFLINE_COUNT ] && [ $LAST_PING_SUCCESSFUL = false ]; then
      # Send a GET request to the offline URL
      curl -X GET $OFFLINE_URL
        echo "Sent Server is offline"

      
    
    fi
    # Set the last ping to false
      LAST_PING_SUCCESSFUL=false
  fi

    # if the output file is greater than MAX_LOG_FILE_SIZE lines, send/post to LOGS_URL with the logs in the output file as the body and clear the file
    if [ $(wc -l < output.txt) -gt $MAX_LOG_FILE_SIZE ]; then
    curl -X POST -d @output.txt $LOGS_URL
    echo "Logs sent"
    echo "" > output.txt
    fi

    # Wait for WAIT_TIME_SECONDS before checking again
    sleep $WAIT_TIME_SECONDS


done