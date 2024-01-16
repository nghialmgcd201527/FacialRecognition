# $1 = $API_SLACK
# $2 = $TOKEN_SLACK
# $3 = $CHANNEL_SLACK
# $4 = $REPO
# $5 = $PATH_TO_REPORT
# $6 = $TYPE_REPORT

current_date_time="`date +%Y%m%d%H%M`";
if [ -e "$5" ]
then
      curl $1 -F token=$2 -F channels=$3 -F title="$4_$6_${current_date_time}" -F filename="$5" -F file=@"$5"
else
      buildStatus="SUCCEEDED!"
      buildColor="#2eb886"
      curl -X POST -H "Authorization: Bearer $2" -H 'Content-type: application/json' --data '{"channel":"'"$3"'","attachments":[{"color":"'"$buildColor"'","title":"'"${4}_${6}_${current_date_time}_without_issue"'"}]}' https://slack.com/api/chat.postMessage
fi
