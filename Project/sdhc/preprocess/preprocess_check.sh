#########################################################
#    프로그램명     : preprocess_check.sh
#    작성자         : Youngho Lee
#    작성일자       : 2023-03-08
#    설명           : 전처리 과정 데이터 및 모델 생성 확인
#    파라미터       : $1:type(train/inference) $2:directory name
#########################################################

# -- Directory
export BASE=${2}
export BASE_LOG=$BASE/log
export BASE_DATA=$BASE/data
export BASE_MODEL=$BASE/model

# -- Job Log Para $# : Program ID
pgm_id=${0##*/}
pgm_nm=${pgm_id%.*}

# -- Job Log Para $1 : Type
type=${1}

# -- Create Log File
curr_tms=`date '+%Y%m%d%H%M%S%N'`
curr_sys_dt=`date '+%Y%m%d'`

if [ ! -d "$BASE_LOG/${curr_sys_dt}" ]
    then
        mkdir -p $BASE_LOG/${curr_sys_dt}
        chmod -R 777 $BASE_LOG/${curr_sys_dt}
fi

LOG_FILE=$BASE_LOG/${curr_sys_dt}/${pgm_nm}_${type}_${curr_sys_dt}_${curr_tms}.log

echo "LOG_FILE: "$LOG_FILE


# -- Log Basic Information
echo "--------PGM_INFO-----------------------------" >> $LOG_FILE
echo "(pgm_nm       )  ="${pgm_nm}                   >> $LOG_FILE
echo "(type         )  ="${type}                     >> $LOG_FILE
echo "(check_date   )  ="${curr_sys_dt}              >> $LOG_FILE
echo "---------------------------------------------" >> $LOG_FILE
echo "                                             " >> $LOG_FILE


# -- Check for a file's existence
if [ $type = "train" ]
then
    # -- train
    preprocess_train="$BASE_DATA/preprocess_train.csv"
    train="$BASE_DATA/train.csv"

    files=($preprocess_train $train)

    for file in "${files[@]}"
        do

        if [ -e "${file}" ]
            then
                file_yn="Y"
                update_dt=`stat -c '%y' ${file}`
            else
                file_yn="N"
                update_dt="-"

        fi

        echo "file name         ="${file##*/}            >> $LOG_FILE
        echo "existence         ="$file_yn               >> $LOG_FILE
        echo "last updated date ="${update_dt%.*}        >> $LOG_FILE
        echo ""                                          >> $LOG_FILE

    done

else
    # -- inference
    # -- 1) file
    preprocess_infer="$BASE_DATA/preprocess_inference.csv"
    infer_input="$BASE_DATA/inference_input.csv"

    files=($preprocess_infer $infer_input)

    for file in "${files[@]}"
        do

        if [ -e "${file}" ]
            then
                file_yn="Y"
                update_dt=`stat -c '%y' ${file}`
            else
                file_yn="N"
                update_dt="-"

        fi

        echo "file name         ="${file##*/}            >> $LOG_FILE
        echo "existence         ="$file_yn               >> $LOG_FILE
        echo "last updated date ="${update_dt%.*}        >> $LOG_FILE
        echo ""                                          >> $LOG_FILE

    done
    
    # -- 2) shape
    train_shape=`grep -m 1 "train data" $BASE/log/${curr_sys_dt}/debug.log | cut -d ":" -f4`
    infer_shape=`grep -m 1 "inference data" $BASE/log/${curr_sys_dt}/debug.log | cut -d ":" -f4`
    
    echo "The shape of train data :"$train_shape        >> $LOG_FILE
    echo "The shape of inference data :"$infer_shape    >> $LOG_FILE
    echo ""                                             >> $LOG_FILE
    
fi
