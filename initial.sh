#!/bin/bash

#################
# Welcome message
#################
echo ""; tput smacs; echo 'lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk'; tput rmacs
tput smacs; echo -n "x"; tput rmacs

echo -n " Welcome to                    "

tput smacs; echo "x"; tput rmacs
tput smacs; echo -n "x"; tput rmacs

echo -n " Initial Server Setup          "

tput smacs; echo "x"; tput rmacs
tput smacs; echo -n "x"; tput rmacs

echo -n " By "; tput smso; echo -n "me@zeidb.com"; tput rmso; echo -n "               "

tput smacs; echo "x"; tput rmacs
tput smacs; echo 'mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj'; tput rmacs; echo ""

##################################################################
##################################################################
##################################################################

####################
# Update and Upgrade
####################

tput smso; printf "[             WARNING             ]\n"; tput rmso;
printf "If you start the initial setup now,\nthe script will update your packages,\nand configure certain files (eg. /etc/hostname) automatically.\n\n"

printf "==========================================\n"
tput smso; echo -n "Do you want to start initial setup? [y/n]:"; tput rmso; read -p " " start_script

if [ $start_script == "y" ]
then
	printf "\nUpdating packages... "
	apt update -y &> /dev/null || printf "[ERROR]: Package updates failed!\n"
	
	update_exit_status=$?

	if [ $update_exit_status -eq 0 ]
	then
		tput smso; echo -n "Done."; tput rmso
		printf "\n\nUpgrading packages... "
		apt upgrade -y &> /dev/null || printf "[ERROR]: Upgrade failed!"

		upgrade_exit_status=$?

		if [ $upgrade_exit_status -eq 0 ]
		then
			tput smso; printf "Done.\n\n"; tput rmso
		fi
	fi
else
	printf "\nBye!\n\n"; exit
fi

################################################################
################################################################
################################################################

########################
# Creating new sudo user
########################

echo "============================="
tput smso; echo "[          SUCCESS          ]"; tput rmso
echo "Update and upgrade completed."
echo ""
echo "Now, it's time to create sudo"
echo "user you will use."
echo ""

tput smso; echo -n "Enter the username you want:"; tput rmso; read -p " " new_user_username

if [ $new_user_username != "" ]
then
	adduser $new_user_username

	adduser_exit_status=$?

	if [ $adduser_exit_status -eq 0 ]
	then
		echo "============================="
		tput smso; echo "[          SUCCESS          ]"; tput rmso
		echo "User $new_user_username has been added."
		echo ""
		echo -n "Granting sudo for $new_user_username... "

		usermod -aG sudo $new_user_username || printf "\n\n[ERROR]: Granting failed!\n\n"
	
		usermod_exit_status=$?

		if [ $usermod_exit_status -eq 0 ]
		then
			tput smso; printf "Done.\n\n"; tput rmso
			
			echo "============================="
			tput smso; echo "[          SUCCESS          ]"; tput rmso
			echo "The user has been created and granted."
			echo ""
			echo "On next login, use newly created"
			echo "user."
			echo ""
		fi
	fi
else
	printf "\n\nInvalid username format!\n\n"; exit $?
fi

echo ""
echo "====================================="
echo "Performing important initial tasks..."
echo "====================================="
echo ""

# Setting up the firewall
if [ -e /usr/sbin/ufw ]
then
	echo -n "Enabling firewall... "
	ufw enable &> /dev/null && ufw allow 22 &> /dev/null || printf "\n\n[ERROR]: Cannot enable firewall\n\n"

	ufw_exit_status=$?

	if [ $ufw_exit_status -eq 0 ]
	then
		tput smso; printf "Done.\n\n"; tput rmso
		echo -n "Opening port 22... "; tput smso; printf "Done.\n\n"; tput rmso 
	fi
fi

# Setting up the ftimezone
if [ -e /usr/bin/timedatectl ]
then
	echo -n "Setting up timezone... "
	timedatectl set-timezone Europe/Zurich &> /dev/null || printf "\n\n[ERROR]: Cannot change timezone\n\n"

	timedatectl_exit_status=$?

	if [ $timedatectl_exit_status -eq 0 ]
	then
		tput smso; printf "Done.\n\n"; tput rmso
	fi
else
	printf "\n\nCannot change timezone\n\n"; exit
fi

# Blocking password login for root
echo -n "Locking password-login for root... "
passwd -l root &> /dev/null || printf "\n\n[ERROR]: Cannot lock root account\n\n"

passwd_exit_status=$?

if [ $passwd_exit_status -eq 0 ]
then
	tput smso; printf "Done.\n\n"; tput rmso
else
	printf "\n\nError\n\n"; exit
fi

# Blocking root login in sshd_config
if [ -e /etc/ssh/sshd_config ]
then
	echo -n "Disabling SSH access for root... "
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config &> /dev/null || printf "\n\n[ERROR]: Cannot edit sshd_config file"

	if [ $? -eq 0 ]
	then
		tput smso; printf "Done.\n\n"; tput rmso
	fi
else
	echo -n "Disabling SSH access for root... "
	tput smso; printf "sshd missing, continuing.\n\n"; tput rmso
fi