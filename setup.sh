#!/bin/bash

#Create new SSH keys for the Debian systems 
mkdir /etc/ssh/backup-keys
mv /etc/ssh/ssh_host_* /etc/ssh/backup-keys
dpkg-reconfigure openssh-server
md5sum /etc/ssh/ssh_host_*
md5sum /etc/ssh/backup-keys/ssh_host_*

# Install updates and upgrade to the sytem
apt install fail2ban #This hardens the system by making sure it cannot be bruteforced 
apt update -y 
apt upgrade -y

#Create text files to store downloaded Tools
touch MasterList-LocalTools
touch MasterList-RepoTools

# Put the local tools into the txt file and make an executable
while IFS= read -r line
do
        if ! grep -q "$line" MasterList-LocalTools
        then
                eval $line
                echo "$line" > MasterList-LocalTools
        else
                echo -e "Tool has already been installed"
        fi
done < LocalTools.txt

# Put tools from git repos into text file and make it an executable 
while IFS= read -r line
   do
        DIR=`echo "${line##*/}" | sed -e s/[[:blank:]]//g`
        echo "Checking ***"$DIR"***"
        if [ -d "$DIR" ]
        then 
             cd "$DIR"
             echo -e "Repo tool ("$DIR") already exists pulling latest update..."
             git pull
             cd ..
        else
            echo "Cloning "$DIR""
            git clone $line
fi
   done < RepoTools

