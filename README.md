# Have I Been Pwned (HIBP) Shell Script

A shell script for the Have I Been Pwned API (Version 3). Checks password hashes and email addresses against HIBP's breach datasets.

## The HIBP API

HIBP provides a RESTful API serivce. Read more [here](https://haveibeenpwned.com/API/v3).

The **Pwned Passwords** service allow searching across more than half a billion passwords which have previously been exposed in data breaches. Each password is stored as a SHA-1 hash of a UTF8-encoded password string. HIBP employs a **k-anonymity model** for searching Pwned Passwords, read more [here](https://haveibeenpwned.com/API/v3#PwnedPasswords).

Read more [here](https://haveibeenpwned.com/API/v3#BreachModel) about HIBP email account breach model and searching the API. This script returns all verified and unverified breaches found in HIBP datasets for a given email address.

Version 3 of the API now requires buying an [API Access Key](https://haveibeenpwned.com/API/Key) for searching email addresses. Searching password hashes don't require an Acesss Key.

## Using the Script

This script calls the HIBP API via ```Curl``` requests. The API-Key is handled as a ```Curl``` header. A user agent must also be specified when calling the HIBP API.

Searching HIBP password hashes:

```
>$ hibp.sh -p
>$ Enter password: liverpool1
>$ WARNING: password appears in HIBP datasets: 18270 times
```

Searching email addresses:

```
>$ hibp.sh -a
>$ Enter API Key: XXXX-XXXX-XXXX-XXXX
>$ Enter email address: myemailaddress@email.com
>$ No breaches found.
```

### Example of Intergrating into other Shell Scripts 

In the ```/test-scripts``` repo is an example script called ```addUser.sh``` and an associated ```expect``` script named ```hibp.expect```. This attempts to integrate an HIBP check into a Linux user account creation script.

```addUser.sh``` is a basic script for creating a new user account and checking a user's chosen password against HIBP and ```cracklib-check```. Password choices are rejected based on matches found in HIBP and ```cracklib-check```. Tested on CentOS 7.

I'm sure the HIBP script could be adapted for much more interesting use cases too.

## Built with

* [GNU BASH](http://www.gnu.org/software/bash/)
* [HIBP API](https://haveibeenpwned.com/API/v3)

## Authors

Initial work contributed by Andrew Houlbrook - [andrewhoulbrook](https://github.com/andrewhoulbrook)

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.