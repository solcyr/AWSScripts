#!/usr/bin/env bash

vpcName="$1"
region="$2"

TMPFILE=.jsonfile.tmp
INGRESS=ingress-$vpcName-$region.tsv
EGRESS=egress-$vpcName-$region.tsv

vpcId=`aws $AWS_OPTS ec2 describe-vpcs --region $region --filters Name=tag:Name,Values=$vpcName --query Vpcs[].VpcId --output text`
echo "List all Security Group Rules for VPC $vpcName($vpcId) in $region"

#Ingress
aws $AWS_OPTS ec2 describe-security-groups --region $region --filters Name=vpc-id,Values=$vpcId \
                  --query "SecurityGroups[].{IpPermissions:IpPermissions[], Destination: GroupId}" > $TMPFILE

echo "From Port\\tTo Port\\tSource\\tDestination\\tDescription" > $INGRESS
jq -cr '.[] as $parent | $parent.IpPermissions[] as $perm | $perm.IpRanges[]         
        | [$perm.FromPort, $perm.ToPort,  .CidrIp,       $parent.Destination, .Description] | @tsv'  $TMPFILE >> $INGRESS
jq -cr '.[] as $parent | $parent.IpPermissions[] as $perm | $perm.UserIdGroupPairs[] 
        | [$perm.FromPort, $perm.ToPort,  .GroupId,      $parent.Destination, .Description] | @tsv'  $TMPFILE >> $INGRESS
jq -cr '.[] as $parent | $parent.IpPermissions[] as $perm | $perm.PrefixListIds[]    
        | [$perm.FromPort, $perm.ToPort,  .PrefixListId, $parent.Destination, .Description] | @tsv'  $TMPFILE >> $INGRESS
        

#Egress
aws $AWS_OPTS ec2 describe-security-groups --region $region --filters Name=vpc-id,Values=$vpcId \
                  --query "SecurityGroups[].{IpPermissionsEgress:IpPermissionsEgress[], Source: GroupId}" > $TMPFILE
echo "From Port\\tTo Port\\tSource\\tDestination\\tDescription" > $EGRESS
jq -cr '.[] as $parent | $parent.IpPermissionsEgress[] as $perm | $perm.IpRanges[]         
        | [$perm.FromPort, $perm.ToPort, $parent.Source, .CidrIp,       .Description] | @tsv'  $TMPFILE >> $EGRESS
jq -cr '.[] as $parent | $parent.IpPermissionsEgress[] as $perm | $perm.UserIdGroupPairs[] 
        | [$perm.FromPort, $perm.ToPort, $parent.Source, .GroupId,      .Description] | @tsv'  $TMPFILE >> $EGRESS
jq -cr '.[] as $parent | $parent.IpPermissionsEgress[] as $perm | $perm.PrefixListIds[]    
        | [$perm.FromPort, $perm.ToPort, $parent.Source, .PrefixListId, .Description] | @tsv'  $TMPFILE >> $EGRESS

rm -rf $TMPFILE
