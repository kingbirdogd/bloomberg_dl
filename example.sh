#!/bin/bash
echo $#;
if [ 3 -ne $# ]
then
	echo "usage example.sh <host> <user> <pass>";
	exit -1;
fi
host=$1;
user=$2;
pass=$3;
dub build -c tools;
./bloomberg_dl_tools DATA ARRAY "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" true 10 100
./bloomberg_dl_tools DATA ARRAY "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" false 10 100
./bloomberg_dl_tools DATA CSV "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" true 10 100
./bloomberg_dl_tools DATA CSV "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" false 10 100
./bloomberg_dl_tools DATA FILE "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" data_with_header.csv 0 true 10 100
./bloomberg_dl_tools DATA FILE "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" data_with_header.csv 9 true 10 100
./bloomberg_dl_tools DATA FILE "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" data_without_header.csv 0 false 10 100
./bloomberg_dl_tools DATA FILE "${host}" "${user}" "${pass}" "FUT_INIT_SPEC_ML,FUT_INIT_HEDGE_ML"  "DUA Comdty,OEA Comdty" data_without_header.csv 9 false 10 100
./bloomberg_dl_tools HISTORY ARRAY "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 true 10 100
./bloomberg_dl_tools HISTORY ARRAY "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 false 10 100
./bloomberg_dl_tools HISTORY CSV "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 true 10 100
./bloomberg_dl_tools HISTORY CSV "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 false 10 100
./bloomberg_dl_tools HISTORY FILE "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 history_with_header.csv 0 true 10 100
./bloomberg_dl_tools HISTORY FILE "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 history_with_header.csv 9 true 10 100
./bloomberg_dl_tools HISTORY FILE "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 history_without_header.csv 0 false 10 100
./bloomberg_dl_tools HISTORY FILE "${host}" "${user}" "${pass}" "PX_LAST_EOD,PX_ASK_EOD,PX_BID_EOD,PX_MID_EOD,YLD_YTM_BID,YLD_YTM_ASK,YLD_YTM_MID" "US912810ST60 Govt" "BGN" 20201113 20210209 history_without_header.csv 9 false 10 100
