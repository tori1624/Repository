#########################################################
#    프로그램명     : lake_env.sh
#    작성자         : YHLEE
#    작성일자       : 2022-09-08
#    설명           : 프로그램 실행에 필요한 변수 설정
#    파라미터       :
#    변경일자       :
#    변경내역       :
#########################################################

source ~/.bash_profile
source $LAKE_ETL/bin/lake.env

# -- Job Log Para $2 : PARAMETER
export work_dt=`echo $1 | cut -c 1-8`
export work_tm=`echo $2 | cut -c 1-4`
export work_ym=`echo $1 | cut -c 1-6`

para_id=$work_dt$work_tm

# -- JOb LOg Para $# : Program ID
pgm_id=${0##*/}
pgm_nm=${pgm_id%.*}
file_type=${pgm_id#*.}
shell_id=${pgm_id}

echo file_type=$file_type

#if [ "$file_type" = "sh" ]; then
#    tbl_nm=`echo $pgm_nm | cut -c 3- | rev | cut -c 4- | rev`
#else
#    tbl_nm=`echo $pgm_nm`
#fi
tbl_nm=`echo $pgm_nm`

echo pgm_id=$pgm_id
echo pgm_nm=$pgm_nm
echo tbl_nm=$tbl_nm
echo shell_id=$shell_id
echo para_id=$para_id

# -- Job Log Para $8 : Log File Name
logfile_nm=${pgm_id}

subject=${3}
echo "subject="$subject

dw_mart=dm
echo "dw_mart="$dw_mart

# -- JOb LOg Table Insert Parameter Initialize End -----------

curr_tms=`date '+%Y%m%d%H%M%S%N'`
curr_sys_dt=`date '+%Y%m%d'`

if [ ! -d "$LAKE_LOG/$dw_mart/${curr_sys_dt}" ]
    then
            mkdir -p $LAKE_LOG/$dw_mart/${curr_sys_dt}
                chmod -R 777 $LAKE_LOG/$dw_mart/${curr_sys_dt}
fi

LOG_FILE=$LAKE_LOG/$dw_mart/${curr_sys_dt}/${pgm_nm}_${work_dt}_${curr_tms}.log
LOG_TEMP=${LOG_FILE}.tmp
LOG_ERR=${LOG_TEMP}.err

echo "LOG_FILE: "$LOG_FILE
echo "LOG_TEMP: "$LOG_TEMP
echo "LOG_ERR: "$LOG_ERR

rm -f $LOG_FILE
rm -f $LOG_TEMP
rm -f $LOG_ERR

## CSV LOCAL PATH
PATH_CSV_OUT=""

## CSV_FTP
PATH_CSV_FTP=""

echo "ParamCnt = " $#

if [ $# -eq 3 ]
then source $LAKE_ETL/bin/insert_pgm_info.sh "$1" "$2" "$3" $tbl_nm
elif [ $# -eq 4 ]
then source $LAKE_ETL/bin/insert_pgm_info.sh "$1" "$2" "$3" "$4" $tbl_nm
fi
