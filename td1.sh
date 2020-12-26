#!/bin/bash

#Creating a variable which will store RED color
	RED='\033[91m'
	BLUE='\033[94m'
	RESET='\e[0m'

#clearing the console before executing the script
	clear
	echo -e "${RED}    ....... ........ ........ .....   ......  ........   ........   ${RESET}"
	echo -e "${RED}       .    .      . .      . ..   .  .    .  .                .    ${RESET}"
	echo -e "${RED}       .    .      . ........ ..   .  .    .  .     . .       .     ${RESET}"
	echo -e "${RED}       .    .      . .        ..   .  .    .  .     . .        .    ${RESET}"
	echo -e "${RED}       .    ........ .        .....   ......  ....... .  ........   ${RESET}"
	echo ""
	echo -e "Created with <3 by Pronged_Fork"
	echo ""

	#Begining of the script
	if [[ $# -eq 0 ]] ;
	then
		echo -e "${RED}Usage: bash sub.sh bing.com${RESET}"
		exit 1
	else

	#resolve the target to its ip address
		echo -e "${BLUE}Finding IP address and other information associated with ${1}:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		IP=`ping -4 -c 2 $1 | grep from | cut -d ' ' -f5 | awk '{if(NR==1) print $0}'`
		IP_LEN=${#IP}-3
		IP2=${IP:1:IP_LEN}
		echo "${IP2}"
		echo ""
		curl http://ipinfo.io/${IP2}
		echo ""

	#Collecting the headers and following the redirects for extra headers
		echo -e "${BLUE}Available headers on ${1}:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		TARGET_HEADERS=`curl -L -I http://${1}`
		echo "${TARGET_HEADERS}"
		echo ""

	#Performing ASN Enumeration
		echo -e "${BLUE}ASN value of ${1} is:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		ASN_VALUE=`curl -s http://ip-api.com/json/${IP2} |  jq -r .as | cut -d ' ' -f1`
		echo "${ASN_VALUE}"
		echo ""
		whois -h whois.cymru.com " -v ${ASN_VALUE}" 
		echo ""		

	#Enumerating supported HTTP Verbs using nmap
		echo -e "${BLUE}${1} supports following HTTP Verbs:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		HTTP_METHODS=`nmap -p 443 --script http-methods --script-args http-methods.url-path='/' ${1} | grep "|" | cut -d ":" -f2`		
		echo "${HTTP_METHODS}"
		echo ""

	#Enumerating CIDR using nmap
		echo -e "${BLUE}PERFORMING ASN ENUMERATION USING NMAP and advanced Whoisquery:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		ASN_VALUE2=${ASN_VALUE:2}
		nmap --script targets-asn --script-args targets-asn.asn=${ASN_VALUE2}
		whois -h whois.radb.net  -- "-i origin ${ASN_VALUE}" | grep -Eo "([0-9.]+){4}/[0-9]+" | uniq 
		echo ""

	#Performing WHOIS Lookup
		echo -e "${BLUE}PERFORMING WHOIS LOOKUP ON $1:${RESET}"
		echo -e "${BLUE}--------------------------------------------------------------${RESET}"
		whois ${1} | grep "Registrar URL" | awk '{if(NR==1) print $0}'
		whois ${1} | grep "Registry Expiry Date:" | awk '{if(NR==1) print $0}'
		echo ""


	fi
