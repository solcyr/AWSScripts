
 function aws_assume_role {
    OUTPUT=$(aws sts assume-role --role-arn arn:aws:iam::${1}:role/$2 --role-session-name $1 --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text) || return

    export AWS_ACCESS_KEY_ID=$(echo $OUTPUT | awk '{print $1}')
    export AWS_SECRET_ACCESS_KEY=$(echo $OUTPUT | awk '{print $2}')
    export AWS_SESSION_TOKEN=$(echo $OUTPUT | awk '{print $3}')
}

function aws_switch_back {
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

function aws_who {
    aws sts get-caller-identity
}

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

export PATH=.:${PATH}
