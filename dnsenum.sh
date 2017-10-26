#!/bin/bash

MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"
DNSFILE="${MY_PATH}/wordlist/subdomains-top1mil-5000.txt"
DNSSERVER=""
DOMAIN="0"
HTTPCHECK=0
RESULT="0"
VIRUSTOTAL=0
SHODAN="apikey-here"

source ${MY_PATH}/inc/bash_colors.sh

echo -en "\n+\n"
echo "+ DNSenum by theMiddle: https://github.com/theMiddleBlue/DNSenum"
while getopts :hcvd:n:r:s: OPTION; do
	case $OPTION in
		d)
			echo "+ Dns Enumeration for domain ${OPTARG}"
			DOMAIN=${OPTARG}
		;;
		f)
			echo "+ Using file ${OPTARG}"
			DNSFILE=${OPTARG}
		;;
		n)
			echo "+ Using DNS Server ${OPTARG}"
			DNSSERVER=" @${OPTARG}"
		;;
		c)
			HTTPCHECK=1
		;;
		r)
			echo "+ Filter result: ${OPTARG}"
			RESULT="${OPTARG}"
		;;
		v)
			echo "+ Check URL on VirusTotal"
			VIRUSTOTAL=1
		;;
		s)
			echo "+ Set Shodan API Key"
			SHODAN="${OPTARG}"
		;;
		h)
			echo "+ Usage: $0 -d <domain> [-f <file] [-n <dns server>] [-c]"
			echo "+"
			echo "+ -d <domain>      Domain name to test"
			echo "+ -f <file>        Subdomain list file to use for test"
			echo "+ -n <dns server>  DNS Server to use for query"
			echo "+ -c               Check for HTTP Server banner"
			echo "+ -v               Check domain on VirusTotal"
			echo "+ -s               Set Shodan API Key in order to query it"
			echo "+ -r <result>      Show only result that match <result>"
			echo -en "+\n\n"
			exit 0
		;;
	esac
done

if [ ${DOMAIN} = "0" ]; then
	echo "+ Usage $0 -d example.com [-f subdomain-list.txt]"
	echo "+ Full help: $0 -h "
	echo "+"
	exit 0
fi

REGEX="(.+)[[:space:]]+([A-Z0-9]+)[[:space:]]+([a-zA-Z0-9\.\-]+)"
#RANDOMSD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
RANDOMSD=$(perl -pe 'tr/A-Za-z0-9//dc;' < /dev/urandom | head -c 20; echo)
WILDCARD=RANDOMSD
DNSTEST=$(dig +noall +answer +nottlid +nocl ${RANDOMSD}.${DOMAIN}${DNSSERVER} | head -1)
STARTRES=$(dig +noall +answer +nottlid +nocl ${DOMAIN}${DNSSERVER} | head -1)


if [[ ${DNSTEST} =~ $REGEX ]]; then
	WILDCARD="${BASH_REMATCH[3]}"
	echo "+ Wildcard resolution is enabled on this domain (${WILDCARD})"
	echo "+ checking for others results != ${WILDCARD} ..."
fi

echo "+"
echo ""

if [ "${SHODAN}" != "apikey-here" ]; then
	clr_red "+"
	clr_red "+ Querying Shodan..."
	SHCURL=$(curl -s 'https://api.shodan.io/shodan/host/search?key='${SHODAN}'&query=hostname:'${DOMAIN} | inc/JSON.sh | egrep 'hostnames.\]' | egrep -o '[a-zA-Z0-9\-\.]+\"\]$' | egrep -o '[a-zA-Z0-9\-\.]+')
	clr_red "+ Result from Shodan:"
	clr_red "+"

	for element in $SHCURL
	do
		addelem=$(echo "${element}" | sed -e "s/.${DOMAIN}//g")
		DNSRES=$(dig +noall +answer +nottlid +nocl ${element}${DNSSERVER} | head -1)

		clr_red "trying ${element} ..." -n;

		if [[ ${DNSRES} =~ $REGEX ]]; then
			RES="${BASH_REMATCH[3]}"
			if [[ "${WILDCARD}" = "${RES}" ]]; then
				#echo "discard ${RES}"
				echo -en "\033[K"
				echo -en "\033[999D"
			else
				echo -en "\033[999D"
				echo -en "\033[K"

				if [ ${RESULT} = "0" ] || [ ${RESULT} = ${BASH_REMATCH[3]} ]; then
					if [ $HTTPCHECK -eq 1 ]; then
						echo -en "trying to connect to http://${addelem}.${DOMAIN} ..."
						CURL=$(curl -s -I --connect-timeout 2 "http://${addelem}.${DOMAIN}" | grep -i "server:" | sed -e 's/Server: //g')
						echo -en "\033[999D"
						echo -en "\033[K"
					fi

					printf "%30b | %-20b | %-40b | %-10b" "\033[0;32m${addelem}\033[0m" "\033[1;34m${BASH_REMATCH[2]}\033[0m" "${BASH_REMATCH[3]}" "${CURL}"
					echo ""
				fi
			fi
		else
			echo -en "\033[K"
			echo -en "\033[999D"
		fi

	done
	echo -en "\033[K"
	echo -en "\033[999D"
	clr_red "+"
	clr_red "+ End Results from Shodan."
	clr_red "+"
	echo ""

fi

if [ $VIRUSTOTAL -eq 1 ]; then
	clr_red "+"
	clr_red "+ Querying VirusTotal..."
	VTCURLPRE=$(curl -s -c vtcookie.txt -b vtcookie.txt -A "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" "https://www.virustotal.com/en-gb/domain/${DOMAIN}/information/")
	VTCURL=$(curl -s -c vtcookie.txt -b vtcookie.txt -A "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36" "https://www.virustotal.com/en-gb/domain/${DOMAIN}/information/" | egrep "\<a target\=.\_blank. href\=..en\-gb.domain" | awk 'BEGIN{FS="/"}{print $4}')
	clr_red "+ Result from VirusTotal:"
	clr_red "+"
	for element in $VTCURL
	do
		addelem=$(echo "${element}" | sed -e "s/.${DOMAIN}//g")
		DNSRES=$(dig +noall +answer +nottlid +nocl ${element}${DNSSERVER} | head -1)

		echo -en "trying ${element} ..."

		if [[ ${DNSRES} =~ $REGEX ]]; then
			RES="${BASH_REMATCH[3]}"
			if [[ "${WILDCARD}" = "${RES}" ]]; then
				#echo "discard ${RES}"
				echo -en "\033[K"
				echo -en "\033[99D"
			else
				echo -en "\033[99D"
				echo -en "\033[K"

				if [ ${RESULT} = "0" ] || [ ${RESULT} = ${BASH_REMATCH[3]} ]; then
					if [ $HTTPCHECK -eq 1 ]; then
						echo -en "trying to connect to http://${addelem}.${DOMAIN} ..."
						CURL=$(curl -s -I --connect-timeout 2 "http://${addelem}.${DOMAIN}" | grep -i "server:" | sed -e 's/Server: //g')
						echo -en "\033[99D"
						echo -en "\033[K"
					fi

					#printf "%20s | %-10s | %-30s | %-10s" "${addelem}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${CURL}"
					printf "%30b | %-20b | %-40b | %-10b" "\033[0;32m${addelem}\033[0m" "\033[1;34m${BASH_REMATCH[2]}\033[0m" "${BASH_REMATCH[3]}" "${CURL}"
					echo ""
				fi
			fi
		else
			echo -en "\033[K"
			echo -en "\033[99D"
		fi

	done
	clr_red "+"
	clr_red "+ End Results from VirusTotal."
	clr_red "+"
	echo ""
fi

clr_red "+"
clr_red "+ Start enumeration from file..."
clr_red "+"
if [[ ${STARTRES} =~ $REGEX ]]; then
	if [ ${RESULT} = "0" ] || [ ${RESULT} = ${BASH_REMATCH[3]} ]; then
		if [ $HTTPCHECK -eq 1 ]; then
			echo -en "trying to connect to http://${DOMAIN} ..."
			CURL=$(curl -m 5 -s -I --connect-timeout 2 "http://${DOMAIN}" | grep -i "server:" | sed -e 's/Server: //g')
			echo -en "\033[99D"
			echo -en "\033[K"
		fi

		#printf "%20s | %-10s | %-30s | %-10s" "${DOMAIN}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${CURL}"
		printf "%30b | %-20b | %-40b | %-10b" "\033[0;32m${DOMAIN}\033[0m" "\033[1;34m${BASH_REMATCH[2]}\033[0m" "${BASH_REMATCH[3]}" "${CURL}"
		echo ""
	fi
fi

while read line; do
	DNSRES=$(dig +noall +answer +nottlid +nocl ${line}.${DOMAIN}${DNSSERVER} | head -1)

	echo -en "trying ${line} ..."

	if [[ ${DNSRES} =~ $REGEX ]]; then
		RES="${BASH_REMATCH[3]}"
		if [[ "${WILDCARD}" = "${RES}" ]]; then
			#echo "discard ${RES}"
			echo -en "\033[K"
			echo -en "\033[99D"
		else
			echo -en "\033[99D"
			echo -en "\033[K"

			if [ ${RESULT} = "0" ] || [ ${RESULT} = ${BASH_REMATCH[3]} ]; then
				if [ $HTTPCHECK -eq 1 ]; then
					echo -en "trying to connect to http://${line}.${DOMAIN} ..."
					CURL=$(curl -m5 -s -I --connect-timeout 2 "http://${line}.${DOMAIN}" | grep -i "server:" | sed -e 's/Server: //g')
					echo -en "\033[99D"
					echo -en "\033[K"
				fi

				#printf "%20s | %-10s | %-30s | %-10s" "${line}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${CURL}"
				printf "%30b | %-20b | %-40b | %-10b" "\033[0;32m${line}\033[0m" "\033[1;34m${BASH_REMATCH[2]}\033[0m" "${BASH_REMATCH[3]}" "${CURL}"
				echo ""
			fi
		fi
	else
		echo -en "\033[K"
		echo -en "\033[99D"
	fi
done<$DNSFILE
