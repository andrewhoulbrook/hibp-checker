#!/bin/bash
# Simple test script to add a new user to a Linux system
# Checks user's chosen password against HIBP and cracklib 

# Check if user is root
if [[ $(id -u) -eq 0 ]]
then
	# Get username and password
    read -p "Enter username: " USERNAME
	read -sp "Enter password: " PASSWORD    # don't print to terminal

    # Check if username already exists, exit if username exists
    egrep "^${USERNAME}" /etc/passwd >/dev/null
	if [[ $? -eq 0 ]]
    then
		printf "\nERROR: username ${USERNAME} already exists.\n"
		exit 1
	else
		# Check password against HIBP breached datasets
        # Loop until user chooses password not in HIBP 
        BADPASSWORD=1
        while [[ "${BADPASSWORD}" == 1 ]]
        do 
            # Execute 'expect' script passing $PASSWORD into hibp.sh (HIBP API v3)
            HIBP=$(expect -f hibp.expect "${PASSWORD}")
            if [[ "${HIBP}" == *": 0 times."* ]]
            then
                # Check password via cracklib
                CRACKLIB=$(cracklib-check<<<"${PASSWORD}")
                if [[ "${CRACKLIB}" == *": OK"* ]]
                then 
                    BADPASSWORD=0   # password accepted    
                else
                    printf "\nPassword rejected.\n"
                    read -sp "Enter a different password: " PASSWORD
                fi                
            else
                printf "\nPassword rejected.\n"
                read -sp "Enter a different password: " PASSWORD
            fi
        done             
        
        # Execute 'python' script to create cryptographic hash (SHA-512) of the user's chosen password
        PASS=$(python -c "import os; import crypt; print crypt.crypt(\""${PASSWORD}"\", crypt.mksalt(crypt.METHOD_SHA512))")

        # Add user to the system with chosen username and password, check for errors
		useradd -m -p "${PASS}" "${USERNAME}"
		if [[ $? -eq 0 ]] 
        then 
            printf "\nINFO: username ${USERNAME} has been added to system.\n" 
        else
            printf "\nERROR: failed to create new user account for username ${USERNAME}.\n"
        fi
    fi
else
	printf "\nERROR: root privilages are required to add a new user.\n"
	exit 2
fi