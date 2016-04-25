# Drive Map, Bash Automatic Drive Mapping Tool
Drive Map is an automatic drive mapping tool for Mac OS X, which maps local
network servers when the computer initially logs in, wakes, and sleeps.
The tool utilizes the keychain access app in Mac OS X to retrieve 
generic internet passwords associated with usernames tied to server paths
you wish to mount.  

Drive Map is maintained by Emerus, Holdings and is distributed under GNU GPL 3.

# Common Usage
List the servers and usernames you wish to mount
in the supplied "MOUNTLIST" file in the following format: 
<SERVERNAME>;<USERNAME>.  Ensure, the username is associated with a
password in the keychain access application as an internet password.

## Source content

Here you can find a description of files and directory distributed
with Drive Map:

* AUTHORS   : development team of Drive Map
* ChangeLog : log of changes
* LICENSE   : GNU GPL3 details
* MapNetworkDrive.sh    : source in Bash

## Licence

Copyright (C) 2015 Emerus, Holdings

This file is part of Drive Map.

Drive Map is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Drive Map is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Drive Map.  If not, see <http://www.gnu.org/licenses/>.

