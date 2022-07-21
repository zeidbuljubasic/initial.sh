#!/bin/bash

# Welcome message
printf "$(clear; tput smacs)lqqqqqqqqqqqqqqqqqqqqqqqqqqqqk\nx $(tput rmacs)"
printf "Initial Server Setup"
printf "$(tput smacs)       x\nx $(tput rmacs)"
printf "$(tput smso)me@zeidb.com$(tput rmso)"
printf "$(tput smacs)               x\nmqqqqqqqqqqqqqqqqqqqqqqqqqqqqj\n\n$(tput rmacs)"


# TASK 1: Updating
printf "$(tput smso)Start the script? [y/n]:$(tput rmso) "
read start_script

if [ $start_script == "y" ]
then
	printf "Updating packages... "
	apt update -y &> /dev/null
	
	if [ $? -eq 0 ]
	then
		printf "DONE\n"
		
		printf "Upgrading packages... "
		apt upgrade -y &> /dev/null

		if [ $? -eq 0 ]
		then
			printf "DONE\n\n"
		else
			printf "FAILED\n\nThere was a problem!\n\n"; exit
		fi
	else
		printf "FAILED\n\nThere was a problem!\n\n"; exit
	fi
else
	printf "\n\nBye!\n\n"; exit
fi


# Creating a sudo user
printf "$(tput smso)Enter username for new account:$(tput rmso) "
read username

if [ -n "$username" ]
then
	adduser $username

	if [ $? -eq 0 ]
	then
		usermod -aG sudo $username &> /dev/null

		if [ $? -eq 0 ]
		then
			printf "\nCreating $username... DONE\nGranting $username... DONE\n"
		else
			printf "\nThere was a problem!\n\n"; exit
		fi
	else
		printf "\nThere was a problem!\n\n"; exit
	fi
else
	printf "\nInvalid username!\n\n"; exit
fi


# Setting up the firewall
printf "Enabling firewall... "
ufw enable &> /dev/null || printf "FAIL\n\nThere was a problem!$(exit)"

printf "$(sleep 1)DONE\nOpening port 22... "
ufw allow 22 &> /dev/null || printf "FAIL\n\nThere was a problem!$(exit)"

printf "$(sleep 1)DONE\n"


# Setting up the timezone
printf "Setting Central EU timezone... "
timedatectl set-timezone Europe/Zurich &> /dev/null || printf "FAIL\n\nThere was a problem!$(exit)"
printf "$(sleep 1)DONE\n"


# Locking root account
printf "Locking password-login for root... "
passwd -l root &> /dev/null || printf "FAIL\n\nThere was a problem!$(exit)"
printf "$(sleep 1)DONE\nDisabling SSH access with root... "

if [ -e /etc/ssh/sshd_config ]
then
	sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config &> /dev/null || printf "FAIL\n\nThere was a problem!$(exit)"

	printf "$(sleep 1)DONE\n"
else
	printf "NO sshd, CONTINUING\n"
fi


# Setting up hostname
printf "\n$(tput smso)Enter a new hostname:$(tput rmso) "
read hostname

if [ -n "$hostname" ]
then
	printf "Modifying /etc/hostname... "
	echo $hostname > /etc/hostname || printf "FAIL\n\nThere was a problem!$(exit)"
	
	printf "DONE\nModifying /etc/hosts... "
	
	if grep -q "127.0.1.1" /etc/hosts
	then
		sed -i "s/127.0.1.1.*/127.0.1.1 $hostname/" /etc/hosts || printf "FAIL\n\nThere was a problem!\n\n$(exit)"

		printf "DONE\n"
	else
		sed -i "/127.0.0.1/a 127.0.1.1 $hostname" /etc/hosts || printf "FAIL\n\nThere was a problem!\n\n$(exit)"
		printf "DONE\n"
	fi
else
	printf "\n\nInvalid hostname!\n\n"; exit 
fi
