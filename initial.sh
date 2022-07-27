#!/bin/bash

# Welcome message
printf "$(clear; tput smacs)lqqqqqqqqqqqqqqqqqqqqqqqqqqqqk\nx $(tput rmacs)"
printf "Initial Server Setup"
printf "$(tput smacs)       x\nx $(tput rmacs)"
printf "$(tput smso)me@zeidb.com$(tput rmso)"
printf "$(tput smacs)               x\nmqqqqqqqqqqqqqqqqqqqqqqqqqqqqj\n\n$(tput rmacs)"
printf "Starting the script (Press CTRL + C to terminate)...\n\n" && /usr/bin/sleep 5

# Updating the system
printf "Updating packages... "
/usr/bin/apt update &> /dev/null && printf "DONE\n"

printf "Upgrading packages... "
/usr/bin/apt -y upgrade &> /dev/null && printf "DONE\n"


# Creating sudo user
printf "$(tput smso)Enter username for new account:$(tput rmso) "
read username

/usr/sbin/adduser $username && usermod -aG sudo $username &> /dev/null
printf "\nCreating and granting $username... " && /usr/bin/sleep 1 && printf "DONE\n"


# Setting up the firewall
printf "Enabling firewall... "
/usr/sbin/ufw enable &> /dev/null && /usr/bin/sleep 1 && printf "DONE\n"

printf "Opening port 22... "
/usr/sbin/ufw allow 22 &> /dev/null && /usr/bin/sleep 1 && printf "DONE\n"


# Setting up the timezone
printf "Setting Central EU timezone... "
/usr/bin/timedatectl set-timezone Europe/Zurich &> /dev/null && /usr/bin/sleep 1 && printf "DONE\n"


# Locking root account
printf "Locking password-login for root... "
/usr/bin/passwd -l root &> /dev/null && /usr/bin/sleep 1 && printf "DONE\n"

if [ -e /etc/ssh/sshd_config ]; then
	printf "Disabling SSH access for root... "
	/usr/bin/sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config &> /dev/null && /usr/bin/sleep 1 && printf "DONE\n"
fi


# Setting up the hostname
printf "\n$(tput smso)Enter a new hostname:$(tput rmso) "
read hostname

printf "Modifying /etc/hostname... "
echo $hostname > /etc/hostname && printf "DONE\n"
	
printf "Modifying /etc/hosts... "
	
if grep -q "127.0.1.1" /etc/hosts
then
	/usr/bin/sed -i "s/127.0.1.1.*/127.0.1.1 $hostname/" /etc/hosts && printf "DONE\n"
else
	/usr/bin/sed -i "/127.0.0.1/a 127.0.1.1 $hostname" /etc/hosts && printf "DONE\n"
fi
