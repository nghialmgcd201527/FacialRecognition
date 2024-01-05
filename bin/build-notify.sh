# $1 = $CODEBUILD_BUILD_SUCCEEDING
# $2 = $SLACK_IDS
# $3 = $STAGE
# $4 = $SLACK_WEBHOOKS

# SLACK_IDS="{\"Quy Ho\":\"DPN6RKY03\",\"ha_le\":\"U02RZV4LCQ3\"}"

LOG_GROUP="log-group"
logPath=$(echo $CODEBUILD_LOG_PATH | sed -e "s/\//\$252f/g")
logPath="https://${AWS_REGION}.console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#logsV2:log-groups/log-group/${LOG_GROUP}/log-events/${logPath}"

awsAccountId=$(echo "$CODEBUILD_BUILD_ARN" | cut -d':' -f5)
codebuildName=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $1}')
codebuildId=$(echo $CODEBUILD_BUILD_ID | sed -e "s/:/\%3A/g")
codebuildPath="https://${AWS_REGION}.console.aws.amazon.com/codesuite/codebuild/${awsAccountId}/projects/${codebuildName}/build/${codebuildId}/?region=${AWS_REGION}"

gitRepo=`basename $(git rev-parse --show-toplevel)`
gitBranch=`git name-rev HEAD | sed -e "s/HEAD //"`
gitUrl=`git remote get-url origin`

repoPath="https://${AWS_REGION}.console.aws.amazon.com/codesuite/codecommit/repositories/${gitRepo}/browse?region=${AWS_REGION}"

appName=$(echo $gitRepo | awk 'BEGIN{FS=OFS="-"}{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr '-' ' ')

developerName=`git log -1 --pretty=format:"%an"`
commitMessage=`git log -1 --pretty=%B`
developerName=$(echo $developerName| tr ' ' '_')

SLACK_IDS=$(echo $SLACK_IDS| tr ' ' '_')
developerId=$(echo $SLACK_IDS | grep -o '"'$developerName'":"[^"]*' | grep -o '[^"]*$')

echo "Developer Name: $developerName, Developer ID: $developerId"

if [ -z "$developerId" ]
then
      developerId=$developerName
else
      echo $developerId
fi

developerName=$(echo $developerName| tr '_' ' ')

buildStatus="FAILED!"
buildColor="#EA2027"

if [ "$1" = "1" ] ; then
  buildStatus="SUCCEEDED!"
  buildColor="#2eb886"
fi

if [ "$1" = "0" ] ; then
  buildStatus="FAILED!"
  buildColor="#EA2027"
fi

curl -X POST -H 'Content-type:application/json' --data '{"text":"*'"$developerName"'* committed to *'"$gitRepo"'* _('"$STAGE"')_","attachments":[{"color":"'"$buildColor"'","title":"'"$appName"'","title_link":"'"$repoPath"'","text":"*`'"$buildStatus"'`* <'"$codebuildPath"'|#'"$CODEBUILD_BUILD_NUMBER"'> ('"$gitBranch"')","fields":[{"title":"_'"$commitMessage"'_","value":"Author:<@'"$developerId"'|cal>","short":false}]}]}' $4;
