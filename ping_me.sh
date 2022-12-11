#!/bin/bash

# Set the URL for the online and offline POST requests
ONLINE_URL= process.env.ONLINE_URL
OFFLINE_URL= process.env.OFFLINE_URL
LOGS_URL= process.env.LOGS_URL

# Set the IP address of the server to check
SERVER_IP= process.env.SERVER_IP

# Set the number of times the server must be offline before sending a POST request
MAX_OFFLINE_COUNT= process.env.MAX_OFFLINE_COUNT

# Initialize a counter for the number of times the server is offline
OFFLINE_COUNT=0

# Initialize max log file size
MAX_LOG_FILE_SIZE= process.env.MAX_LOG_FILE_SIZE

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

  #log the ping result to an output file
  echo $PING_RESULT >> output.txt

  # Check if the server is online
  if [[ $PING_RESULT == *"bytes from"* ]]; then
    # Reset the offline counter
    OFFLINE_COUNT=0
    LAST_PING_SUCCESSFUL = true

    # Send a POST request to the online URL if the last ping was not successful
    if [ $LAST_PING_SUCCESSFUL = false ]; then
      curl -X POST $ONLINE_URL
    fi
    
  else
    # Increment the offline counter
    OFFLINE_COUNT=$((OFFLINE_COUNT + 1))

    # Check if the server has been offline for the MAX_OFFLINE_COUNT times consecutively and the last ping was not successful
    if [ $OFFLINE_COUNT -eq $MAX_OFFLINE_COUNT ] && [ $LAST_PING_SUCCESSFUL = false ]; then
      # Send a POST request to the offline URL
      curl -X POST $OFFLINE_URL

      # Set the last ping to false
      LAST_PING_SUCCESSFUL = false

      # Send a POST request to the offline URL
      curl -X POST $OFFLINE_URL
    
    fi
  fi

  # Wait 3 minutes before checking again
  sleep 180

# if the output file is greater than MAX_LOG_FILE_SIZE lines, send/post to LOGS_URL with the logs in the output file as the body and clear the file
if [ $(wc -l < output.txt) -gt $MAX_LOG_FILE_SIZE ]; then
  curl -X POST -d @output.txt $LOGS_URL
  echo "" > output.txt
fi

done