#!/bin/bash

function GetOH_FromProcess {
	declare -A myarray
	printf "%6s %-20s %-80s\n" "PID" "NAME" "ORACLE_HOME"
	#pgrep -lf _pmon_ | while read pid pname  y ; do
	while read pid pname  y ; do
	  i=$(( i + 1 ))
	  printf "%6s %-20s %-80s\n" $pid $pname `readlink /proc/$pid/exe | sed 's/bin\/oracle$//' | sort | uniq`
	  FOUND_HOME=$(readlink /proc/$pid/exe | sed 's/bin\/oracle$//')
	  [ $(grep -c 'grid' <<< ${HOME}) -eq 1 ] && GI_HOME=${FOUND_HOME}
	  [ $(grep -v 'grid' <<< ${HOME} | grep -c '11\.') -eq 1 ] && ORA11=${FOUND_HOME}
	  [ $(grep -v 'grid' <<< ${HOME} | grep -c '12\.') -eq 1 ] && ORA12=${FOUND_HOME}
	  myarray[$i]=${FOUND_HOME}
	  eval PSHOME$i=$(ps ea  $pid | awk -F"ORACLE_HOME=" '{print $2}' | awk '{print $1}' | grep -v -e '^$' | grep -v print)
	done < <(pgrep -lf _pmon_)

	echo -e "\nIdentified Homes using /proc :"
	echo GI_HOME=${GI_HOME}
	echo ORA11_H=${ORA11}
	echo ORA12_H=${ORA12}

	echo -e "\nIdentified Homes using PS :"
	echo PSHOME1=$PSHOME1
	echo PSHOME2=$PSHOME2
	echo PSHOME3=$PSHOME3
}


function GetGI_FromProcess {
	GI_HOME=$(dirname $(ps -eo args | grep [o]cssd.bin) | awk '{print substr( $1, 1, length($1)-4)}')
	export ORACLE_HOME=${GI_HOME}
}

function GetInfo_FromCRS {
GetGI_FromProcess
crsctl status resource -w "TYPE = ora.database.type" -p|grep USR_ORA_INST_NAME|sed "s:.*=::"|sort -u
}

function GetOH_FromInventory {
	unset homes_array i
	declare -A homes_array
	ORA_INV_LOC=`cat /etc/oraInst.loc | grep inventory_loc | cut -d'=' -f2`
	for LIST_HOME in `cat $ORA_INV_LOC/ContentsXML/inventory.xml | grep 'TYPE="O"' | egrep -v "agent" | grep -v 'REMOVED="T"' | cut -d'"' -f4`
	do
		i=$(( i + 1 ))
		homes_array[$i]=${LIST_HOME}
	done

	if [ -z "$1" ]; then
		echo -e "\nAvailable Oracle Homes"
		for index in "${!homes_array[@]}"
		do
		  echo "${index}) : ${homes_array[${index}]}"
		done
		echo -e "\nChoose an item : "
		read item
	else
		for index in "${!homes_array[@]}"
		do
			[[ "${homes_array[${index}]}" =~ "$1" ]] && item=${index}
			#case "${homes_array[${index}]}" in *"$1"*) item=${index}; break ;; esac 
		done	
	fi

	if [ -n "${item}" ] && [ -n "${homes_array[${item}]}" 2>/dev/null ] 
	then
		export ORACLE_HOME=${homes_array[${item}]}
		echo -e "\nOracle Home Set to : ORACLE_HOME=${ORACLE_HOME}"
		[ $(grep -c ${ORACLE_HOME}/bin <<< $PATH) -eq 0 ] && export PATH=$PATH:${ORACLE_HOME}/bin
	else
		echo "!!! Invalid choice !!!"
	fi
}

GetOH_FromInventory $*
