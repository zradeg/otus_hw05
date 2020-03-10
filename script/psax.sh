#!/bin/bash

get_tty(){
#	if [[ -e /proc/${P_I_D}/fd ]]; then
		TERMINAL_=`ls -l /proc/${P_I_D}/fd 2>/dev/null| grep -oP 'tty\d|pts\/\d{1,2}' | head -n1`
#	else	
	if [[ -z ${TERMINAL_} ]]; then
		echo ? 
	else
		echo ${TERMINAL_}
	fi
}

get_stat(){
	MAIN_STAT=`echo ${STATLINE} | awk '{print $3}'`
	NICE_TMP=`echo ${STATLINE} | awk '{print $19}'`
	S_ID=`echo ${STATLINE} | awk '{print $6}'`
	S_LEAD=$((S_ID-P_I_D))
	if [[ ${NICE_TMP} -lt 0 ]]; then
		NICE_STAT="<"
	elif [[ ${NICE_TMP} -gt 0 ]]; then
		NICE_STAT="N"
	else
		NICE_STAT=""
	fi
	[[ ${S_LEAD} == 0 ]] &&	S_ID="s" || S_ID=""
	[[ -z ${MAIN_STAT}  ]] && MAIN_STAT="?"
	echo ${MAIN_STAT}${NICE_STAT}${S_ID}
}

get_time(){
	UTIME=`echo ${STATLINE} | awk '{print $14}'`
	STIME=`echo ${STATLINE} | awk '{print $15}'`
	FREAQ=`getconf CLK_TCK`
	TOTAL_TIME=$((UTIME+STIME))
	CPU_TIME=$((TOTAL_TIME/FREAQ))
	if [[ ${CPU_TIME} -lt 3540 ]] || [[ ${CPU_TIME} == 0 ]]; then
		echo `date -u -d @${CPU_TIME} +"%M:%S"`
	else
		echo `date -u -d @${CPU_TIME} +"%T"`
	fi
}

get_cmdline(){
	CMD_LINE=`cat /proc/${P_I_D}/cmdline | sed -e "s/\x00/ /g"; echo`
	if [[ -z ${CMD_LINE} ]]; then
		CMD_LINE=`echo ${STATLINE} | awk '{print $2}' | tr '()' '[]'`
	fi
	echo ${CMD_LINE}
}

PCSS=`ls -l /proc | grep -P '^d.*\d{1,}$' | awk '{print $9}' | sort -n`
echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"
for P_I_D in ${PCSS}; do
	if [[ -e /proc/${P_I_D} ]]; then
		STATLINE=`cat /proc/${P_I_D}/stat`
		echo -e "${P_I_D}\t$(get_tty)\t$(get_stat)\t$(get_time)\t$(get_cmdline)" | cut -c-80
	fi
done
