#!/usr/bin/env bash

vpcName="$1"
region="$2"

vpcId=`aws $AWS_OPTS ec2 describe-vpcs --region $region --filters Name=tag:Name,Values=vpc-bps-p-ew1-edg --query Vpcs[].VpcId --output text`
echo "List all Security Group Rules for VPC $vpcName($vpcId) in $region"

#Ingress
aws $AWS_OPTS ec2 describe-security-groups --region eu-west-1 --filters Name=vpc-id,Values=$vpcId --query SecurityGroups[].IpPermissions > jsonfile

echo "FromPort\\tToPort\\tSource\\tDescription" > ingress.csv
jq -cr '.[][] as $parent | $parent.IpRanges[]         | [($parent.FromPort, $parent.ToPort, .CidrIp,       .Description)] | @tsv' jsonfile >> ingress.csv
jq -cr '.[][] as $parent | $parent.UserIdGroupPairs[] | [($parent.FromPort, $parent.ToPort, .GroupId,      .Description)] | @tsv' jsonfile >> ingress.csv
jq -cr '.[][] as $parent | $parent.PrefixListIds[]    | [($parent.FromPort, $parent.ToPort, .PrefixListId, .Description)] | @tsv' jsonfile >> ingress.csv

#Egress
aws $AWS_OPTS ec2 describe-security-groups --region eu-west-1 --filters Name=vpc-id,Values=$vpcId --query SecurityGroups[].IpPermissionsEgress > jsonfile
echo "FromPort\\tToPort\\tDestination\\tDescription" > egress.csv
jq -cr '.[][] as $parent | $parent.IpRanges[]         | [($parent.FromPort, $parent.ToPort, .CidrIp,       .Description)] | @tsv' jsonfile >> egress.csv
jq -cr '.[][] as $parent | $parent.UserIdGroupPairs[] | [($parent.FromPort, $parent.ToPort, .GroupId,      .Description)] | @tsv' jsonfile >> egress.csv
jq -cr '.[][] as $parent | $parent.PrefixListIds[]    | [($parent.FromPort, $parent.ToPort, .PrefixListId, .Description)] | @tsv' jsonfile >> egress.csv

rm -rf jsonfile