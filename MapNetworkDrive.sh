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

# Drive Map is an automatic drive mapping tool for Mac OS X, which maps local
# network servers when the computer initially logs in, wakes, and sleeps.
# The tool utilizes the keychain access app in Mac OS X to retrieve 
# generic internet passwords associated with usernames tied to server paths
# you wish to mount. 

# ------------------------------------------------------------------------------------------------------------------------- #

# Define the file to read for the list of servers to attempt to mount
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INPUT_FILE="$DIR/MOUNTLIST.txt"

# Function to get the users password from the keychain access app.  This way we don't hardcode passwords into the bash script
get_pw () {
  security 2>&1 >/dev/null find-internet-password -ga $USERNAME | ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'
}

# Iterate over lines in input file, ignore blank lines with "grep -v "^$"
#for l in $(cat "$INPUT_FILE" | grep -v "^.*$"); do
cat $INPUT_FILE | while read $(echo l | grep -v "^$"); do
	# Set string splitting delimiter
	IFS=';' read -r SERVER_PATH USERNAME <<< "$l"
	
	SERVER_NAME=${SERVER_PATH%%/*}
	PW=$(get_pw)

	# Check if password was found for username or if SERVER_PATH is empty, then continue
	if [ -z "$PW" ] || [ -z "$SERVER_PATH" ]; then
		# Skip to next item in loop if password variable is not set
		continue
	fi
	
	##########################################################################
	# TEST IF NETWORK SERVER IS PINGABLE #
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
		# replace any spaces in the server path with %20 which will ensure proper space evaluation in the path during the mount command
		SERVER_PATH=${SERVER_PATH/ /%20}
		
		# Perform the mount with type smbfs
		mount -t smbfs "smb://$USERNAME:$PW@${SERVER_PATH}" "${MOUNT_POINT}"		
	fi
done