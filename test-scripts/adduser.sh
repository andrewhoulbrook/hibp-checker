#!/bin/bash
# A simple but ugly looking test script to add a new user to a CentOS 7 Linux system
# Checks user's chosen password against HIBP before standard pam_pwquality / cracklib checks

password_attemtps=3

# Check if user is root
if [[ $(id -u) -eq 0 ]]
then
    # Get username and password
    read -p "Enter username: " username

    # Check if username already exists, exit if username exists
    egrep "^${username}" /etc/passwd &> /dev/null
    if [[ $? -eq 0 ]]
    then
		printf "\nERROR: username ${username} already exists.\n"
		exit 1
    else
        # Add new user account
        useradd "${username}"

        # Check password against HIBP datasets
        # Loop until user chooses password not in HIBP 
        attempt=1
        while [[ "${attempt}" -le "${password_attempts}"]]
        do 
            stty -echo
            read -sp "Enter password: " password    # don't print to console
            
            # Execute 'expect' script passing $password into hibp.sh
            hibp=$(expect -f hibp.expect "${password}")
            if [[ "${hibp}" == *": 0 times."* ]]
            then
                # If pam_pwquality.so configured, let system handle setting of new password
                egrep "pwquality" /etc/pam.d/password-auth &> /dev/null
                if [[ $? -eq 0 ]]
                then
                    passwd "${username}" <<< "${password}"
                    if [[ $? -eq 0 ]]
                    then
                        exit 0
                    fi
                else
                    # If pa_pwquality.so not configured, check if cracklib is installed
                    if [[ -f "/usr/sbin/cracklib-check" ]]
                    then
                        # Check password via cracklib
                        cracklib=$(cracklib-check <<< "${password}")
                        if [[ "${cracklib}" == *": OK"* ]]
                        then 
                            passwd "${username}" <<< "${password}"
                            if [[ $? -eq 0 ]]
                            then
                                exit 0
                            fi
                        fi                
            fi
            attempt+=1
            stty echo
            printf "\nPassword rejected.\n"
        done
        printf "\nERROR: Exceeded maximum number of password attempts.\n"
        exit 1             
    fi
else
    printf "\nERROR: root privilages are required to add a new user.\n"
    exit 1
fi
