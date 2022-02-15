#!/usr/bin/env bash

vpcName="$1"
region="$2"

TMPFILE=.jsonfile.tmp
INGRESS=ingress-$vpcName-$region.tsv
EGRESS=egress-$vpcName-$region.tsv

vpcId=`aws $AWS_OPTS ec2 describe-vpcs --region $region --filters Name=tag:Name,Values=vpc-bps-p-ew1-edg --query Vpcs[].VpcId --output text`
echo "List all Security Group Rules for VPC $vpcName($vpcId) in $region"

#Ingress
aws $AWS_OPTS ec2 describe-security-groups --region eu-west-1 --filters Name=vpc-id,Values=$vpcId --query SecurityGroups[].IpPermissions > $TMPFILE

echo "From Port\\tTo Port\\tSource\\tDescription" > $INGRESS
jq -cr '.[][] as $parent | $parent.IpRanges[]         | [($parent.FromPort, $parent.ToPort, .CidrIp,       .Description)] | @tsv' $TMPFILE >> $INGRESS
jq -cr '.[][] as $parent | $parent.UserIdGroupPairs[] | [($parent.FromPort, $parent.ToPort, .GroupId,      .Description)] | @tsv' $TMPFILE >> $INGRESS
jq -cr '.[][] as $parent | $parent.PrefixListIds[]    | [($parent.FromPort, $parent.ToPort, .PrefixListId, .Description)] | @tsv' $TMPFILE >> $INGRESS

#Egress
aws $AWS_OPTS ec2 describe-security-groups --region eu-west-1 --filters Name=vpc-id,Values=$vpcId --query SecurityGroups[].IpPermissionsEgress > $TMPFILE
echo "From Port\\tTo Port\\tDestination\\tDescription" > $EGRESS
jq -cr '.[][] as $parent | $parent.IpRanges[]         | [($parent.FromPort, $parent.ToPort, .CidrIp,       .Description)] | @tsv' $TMPFILE >> $EGRESS
jq -cr '.[][] as $parent | $parent.UserIdGroupPairs[] | [($parent.FromPort, $parent.ToPort, .GroupId,      .Description)] | @tsv' $TMPFILE >> $EGRESS
jq -cr '.[][] as $parent | $parent.PrefixListIds[]    | [($parent.FromPort, $parent.ToPort, .PrefixListId, .Description)] | @tsv' $TMPFILE >> $EGRESS

rm -rf $TMPFILE