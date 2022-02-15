#!/usr/bin/env bash
EXTRA=""
curgroup="$1"
echo "List all members of group $curgroup"
USERS=`aws $EXTRA iam list-users --query 'Users[].UserName' --output text`
for user in $USERS
do
    IAM_GROUPS=`aws $EXTRA iam list-groups-for-user --user-name $user --query "Groups[].GroupName" --output text`
    if [[ $IAM_GROUPS = *${curgroup}* ]]; then
        echo -e "$user\\thttps://www.office.com/search?auth=2&q=$user"
    fi
done
