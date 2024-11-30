#!/bin/bash
#The user enters the network range, and a new directory should be created.
	echo "Your IPV4 and your netmask:"
	ifconfig | head -n2 | grep -i inet | awk '{print $1,$2,$3,$4}'
	echo
	echo "[!]Enter your ip you wish to scan"
	read ip
	echo
function START() {
	directory=$(echo $ip)
	echo "Creating directory..."
	sleep 2
	mkdir $directory
	cd $directory 
	echo
	echo "[*]The Directory Created!"
	sleep 2
	pwd
	sleep 2
 } 
 
#The script scans and maps the network, saving information into the directory.
function SCAN() {
	echo
	echo "[*] Starting Nmap Scan, Please Wait!"
	sleep 2
	nmap $ip -sV --open -T5 -oN NmapResulets.txt 1>/dev/null 2>/dev/null
	nmap $ip -sV --open -T5 -oX NmapResulets.xml 1>/dev/null 2>/dev/null
	xsltproc NmapResulets.xml -o NmapResulets.html 1>/dev/null 2>/dev/null
	sleep 2
	echo 
	echo "[!] Done."
	sleep 2
	cat NmapResulets.txt | grep -i scan | grep -i report | awk '{print $5}' > HOSTS.txt
	sleep 2
	echo
	echo "[*] Starting Masscan Scan, Please Wait!"
	masscan -iL HOSTS.txt -sU --rate=10000 > MasscanResulets.xml  1>/dev/null 2>/dev/null
	masscan -iL HOSTS.txt -sU --rate=10000 > MasscanResulets.txt  1>/dev/null 2>/dev/null
	xsltproc MasscanResulets.xml -o MasscanResulets.html 1>/dev/null 2>/dev/null
	sleep 2
	echo 
	echo "[!] Done."
}
	sleep 2

#The script will look for vulnerabilities using the nmap scripting engine,
#searchsploit, and finding weak passwords used in the network.

#Use the scanning results and run NSE to extract more information.
function NSE() {
	echo
	echo "[*] Starting Nmap Scan for NSE, Please Wait!"
	nmap -sV --open -T5 --script vuln $ip -oX NseResults.xml 1>/dev/null 2>/dev/null
	xsltproc NseResults.xml -o NseResults.html 1>/dev/null 2>/dev/null
	sleep 2
	echo 
	echo "[!] Done."
	echo
}

#Use the service detection results to find potential vulnerabilities.
function SEARCHSPLOIT() {
	echo "[*] Starting SearchSploit Scan, Please Wait!"
	searchsploit --exclude="Privilege Escalation"  --disable-colour --nmap NmapResulets.xml > SearchsploitResults.txt  2>/dev/null
	sleep 2
	echo
	echo "[!] Done."
	echo
}

#Use the scanning results and find via brute force login services with leak passwords.
function BRUTEFORCE() {
	echo "[*] Preparing To Launch Hydra"
	echo
	echo "[!]Create Your usernames list (CTRL+D after finished)"
	cat > User.lst
	echo
	echo "[!]Create Your password list (CTRL+D after finished)"
	cat > Password.lst
	echo
	echo
	cat NmapResulets.txt
	read -p "[!]Enter a service to use it in [Hydra] Brute-Force (ssh,ftp,etc..)" SERVICE
	echo
	echo "[*]Starting Hydra Brute Force!"
	hydra -L User.lst -P Password.lst -M HOSTS.txt $SERVICE -V > HydraResults.txt 2>/dev/null
	cat HydraResults.txt | grep -iv Attempt | grep -iv Data | grep -iv targets | grep -iv hydra > HydraCracked.txt
	rm HydraResults.txt
	echo 
	echo "[!] Done."
	echo
}

#At the end of the scan, show the user the general scanning statistics.

function LOG() {
	echo "Hosts Discoverd:" > LOG.txt
	cat HOSTS.txt | wc -l >> LOG.txt
	echo "Open Ports By 'Nmap':" >> LOG.txt
	cat NmapResulets.txt | grep -i open | grep -i /tcp | sort | uniq | wc -l >> LOG.txt
	echo "Open Ports By 'Masscan Scan':" >> LOG.txt
	cat MasscanResulets.txt | grep -i open | grep -i /tcp | sort | uniq | wc -l >> LOG.txt
	echo "Number of VMware Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i VMware | sort | uniq | wc -l >> LOG.txt
	echo "Number of VSFTPD Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i vsftpd | sort | uniq | wc -l >> LOG.txt
	echo "Number of OpenSSH Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i OpenSSH | sort | uniq | wc -l >> LOG.txt
	echo "Number of BOINC Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i BOINC | sort | uniq | wc -l >> LOG.txt
	echo "Number of Telnet Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i Telnet | sort | uniq | wc -l >> LOG.txt
	echo "Number of ISC BIND Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i ISC | sort | uniq | wc -l >> LOG.txt
	echo "Number of Apache Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i Apache | sort | uniq | wc -l >> LOG.txt
	echo "Number of RpcBind Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i rpcbind | sort | uniq | wc -l >> LOG.txt
	echo "Number of ProFTPd Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i ProFTPd | sort | uniq | wc -l >> LOG.txt
	echo "Number of PostgreSQL Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i PostgreSQL | sort | uniq | wc -l >> LOG.txt
	echo "Number of VNC Vulnerability Found By 'Searchsploit':" >> LOG.txt
	cat SearchsploitResults.txt | grep -i VNC | sort | uniq | wc -l >> LOG.txt
	echo "Number of Cracked Logins Found by 'Hydra':" >> LOG.txt
	cat HydraCracked.txt | wc -l >> LOG.txt
	clear
	echo "The Script Activated at:" >> /home/kali/Desktop/pt/Auth.log
	date >> /home/kali/Desktop/pt/Auth.log
}

function MENU() {
	EXIT=EXIT
	echo "Welcome to the script MENU!"
	echo "*OPENING AS HTML*"
	echo "*Auth.log file is in your Desktop!*"
	echo
	echo "[*] Enter [N] - Nmap Results"
	echo
	echo "[*] Enter [E] - NSE Results"
	echo
	echo "[*] Enter [H] - Hosts List Results"
	echo
	echo "[*] Enter [R] - Hydra Cracked Results"
	echo
	echo "[*] Enter [L] - Log Results *Better cheack Searchsploit Results"
	echo
	echo "[*] Enter [M] - Masscan Results *UDP ONLY RESULTS IF AVAILABLE*"
	echo
	echo "[*] Enter [S] - Searchsploits Results"
	echo
	echo "[*] Enter [HYDRA] - BRUTE FORCE AGAIN - Recommended open Nmap Results Before!"
	echo
	echo "[*] Enter [W] - Clear Terminal"
	echo
	echo "[*] Enter [EXIT] - For EXIT ..."
	echo
	while [ "$EXIT" == EXIT ];
	do
	read -p "[!] Please enter your choose:" CHOOSE
	case $CHOOSE in
	N)
	firefox NmapResulets.html 2>/dev/null
	;;
	E)
	firefox NseResults.html 2>/dev/null
	;;
	H)
	firefox HOSTS.txt 2>/dev/null
	;;
	R)
	firefox HydraCracked.txt 2>/dev/null
	;;
	L)
	firefox LOG.txt 2>/dev/null
	;;
	M)
	open MasscanResulets.html 2>/dev/null
	;;
	S)
	firefox SearchsploitResults.txt 2>/dev/null
	;;
	HYDRA)
	BRUTEFORCE
	clear
	MENU
	;;
	W)
	clear
	MENU
	;;
	EXIT)
	exit 
	;;
	esac
done
}

#Calling the Functions
START
SCAN
NSE
SEARCHSPLOIT
BRUTEFORCE
LOG
MENU
