#!/bin/bash

#############################################################################################################################
#
# $$$$$$$\  $$$$$$$\  $$$$$$\ $$\    $$\ $$$$$$$$\       $$\      $$\  $$$$$$\  $$$$$$$\  $$$$$$$\  $$$$$$$$\ $$$$$$$\  
# $$  __$$\ $$  __$$\ \_$$  _|$$ |   $$ |$$  _____|      $$$\    $$$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  _____|$$  __$$\ 
# $$ |  $$ |$$ |  $$ |  $$ |  $$ |   $$ |$$ |            $$$$\  $$$$ |$$ /  $$ |$$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |
# $$ |  $$ |$$$$$$$  |  $$ |  \$$\  $$  |$$$$$\          $$\$$\$$ $$ |$$$$$$$$ |$$$$$$$  |$$$$$$$  |$$$$$\    $$$$$$$  |
# $$ |  $$ |$$  __$$<   $$ |   \$$\$$  / $$  __|         $$ \$$$  $$ |$$  __$$ |$$  ____/ $$  ____/ $$  __|   $$  __$$< 
# $$ |  $$ |$$ |  $$ |  $$ |    \$$$  /  $$ |            $$ |\$  /$$ |$$ |  $$ |$$ |      $$ |      $$ |      $$ |  $$ |
# $$$$$$$  |$$ |  $$ |$$$$$$\    \$  /   $$$$$$$$\       $$ | \_/ $$ |$$ |  $$ |$$ |      $$ |      $$$$$$$$\ $$ |  $$ |
# \_______/ \__|  \__|\______|    \_/    \________|      \__|     \__|\__|  \__|\__|      \__|      \________|\__|  \__|
#
#############################################################################################################################

# Map appropriately specified network drives when exectued

# Define the file to read for the list of servers to attempt to mount
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INPUT_FILE="$DIR/MOUNTLIST.txt"

# Function to get the users password from the keychain access app.  This way we don't hardcode passwords into the bash script
get_pw () {
  security 2>&1 >/dev/null find-internet-password -ga $USERNAME | ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}

# Iterate over lines in input file, ignore blank lines with "grep -v "^$"
for l in $(cat "$INPUT_FILE" | grep -v "^$"); do
	# Set string splitting delimiter
	IFS=';'
	set $l

	SERVER_PATH=${1}
	SERVER_NAME=${SERVER_PATH%%/*}
	USERNAME=${2}
	PW=$(get_pw)

	# Check if password was found for username
	if [ -z "$PW" ]; then
		# Skip to next item in loop if password variable is not set
		continue
	fi
	
	##########################################################################
	# TEST IF NETWORK SERVER IF PINGABLE #
	##########################################################################
	x=1
	attempts=5
	sleep_time=5
	# Start while loop to test ping status of server
	while ! ping -c 1 ${SERVER_NAME} &> /dev/null && [ $x -le $attempts ]; do
		# only enters while loop if server is not pingable
		# sleep 1 second
		sleep $sleep_time
		
		# increase x counter to get to loop exit threshold
		x=$(( $x + 1 ))
	done
	# test if x = maximum number of attempts and loop was broken because it was reached
	if [ $x -ge $attempts ]; then
		# Skip to next item in loop if server is not pingable
		continue
	fi
	
	
	# Ensure the server path derived from INPUT_FILE line item is not already mounted
	if ! mount | grep "${SERVER_PATH}" > /dev/null; then
		# Set where we want the mount to occur
		MOUNT_POINT="/Volumes/"$(basename "${SERVER_PATH}")
		
		# Make the base directory for the mount point if necessary
		if [ ! -d "${MOUNT_POINT}" ]; then
			mkdir $MOUNT_POINT
		fi
		# Perform the mount with type smbfs
		mount -t smbfs "smb://$USERNAME:$PW@${SERVER_PATH}" "${MOUNT_POINT}"		
	fi
done