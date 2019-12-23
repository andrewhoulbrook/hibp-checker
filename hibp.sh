#!/bin/bash
# Short script to check password hashes and email addresses against HIBP datasets
# Uses HIBP's V3 API. Ref: https://haveibeenpwned.com/API/v3
# Note: The V3 API now requires an API access key in order to conduct email account checks. 

function usage() {
    echo "usage: $(basename $0) [-a] [-p]"
    echo "  -a check breached email accounts on HIBP. Requires hibp-api-key."
    echo "  -p check breached password hashes on HIBP."
    echo "   e.g. >$ $(basename $0) -p"
    echo "        >$ Enter password: "
    exit 1
}

# Check a password hash in breached datasets (Pwned Passwords) via the HIBP
function checkPassword() {
    read -sp "Enter password: " PASSWORD_STR   # don't print to terminal

    # HIBP uses k-anonymity method to query password hashes
    PASSWORD_HASH=$(echo "${PASSWORD_STR}" | tr -d '\n' | sha1sum | tr [:lower:] [:upper:])
    PASSWORD_HASH_PREFIX="${PASSWORD_HASH:0:5}"
    PASSWORD_HASH_SUFFIX="${PASSWORD_HASH:5:35}"

    # Create URL for HIBP API endpoint
    URL_PASSWORD="https://api.pwnedpasswords.com/range/${PASSWORD_HASH_PREFIX}"
    
    # Pass first five chars of password hash (SHA-1) to HIBP, grep results for an exact match on full password hash
    RESULT=$(curl -A "HIBP-Checker-for-Linux" "${URL_PASSWORD}" 2>/dev/null)
    MATCH=$(echo "${RESULT}" | grep "${PASSWORD_HASH_SUFFIX}") 
    
    # Print matches from HIBP response. If match found, print number of times password is found in HIBP datasets  
    printf "\nWARNING: password appears in HIBP datasets: %d times.\n" "${MATCH#*:}" 2>/dev/null
}

# Check an email account in breached datasets via the HIBP
function checkAccount() {
    read -sp "Enter HIBP API Key: " API_KEY     # Don't print to terminal
    read -p "Enter email address: " ACCOUNT_STR

    # Create URL for HIBP API endpoint
    URL_ACCOUNT="https://haveibeenpwned.com/api/v3/breachedaccount/${ACCOUNT_STR}?truncateResponse=true&includeUnverified=true"

    # Pass a valid API Access Key and user-agent header otherwise the API returns HTTP 403 response
    RESULT=$(curl -A "HIBP-Checker-for-Linux" -H "hibp-api-key: ${API_KEY}" -H "Accept: application/json" -H "Content-Type: application/json" $URL_ACCOUNT 2>/dev/null) 
    LEN="${RESULT[@]}"

    # Loop and print any matches found in HIBP breach datasets
    if [[ "${LEN}" > 0 ]]
    then 
        printf "User account featured in following data breaches." 
        for (( i=0; i<"${LEN}"; i++ )); do echo "${RESULT[$i]}"; done
    else 
        printf "No breaches found." 
    fi
}

# Handle user input options
# -h for usage
# -a check breached email accounts on HIBP
# -p check password hashes on HIBP
while getopts "hpa" OPTION
do
    case "${OPTION}" in
        \?) echo "Invalid option: -${OPTARG}" >&2
            exit 1 ;;
        h)  usage || exit 1
            exit 0 ;;
        p)  checkPassword || exit 1
            exit 0 ;;
        a)  checkAccount || exit 1
            exit 0 ;;
        :)  echo "Option -${OPTARG} requires an argument." >&2
            exit 1 ;;
    esac
done