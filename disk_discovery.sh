#!/bin/bash

function get_iops {
	iops=`ssh -i /var/lib/zabbix/id_rsa user@zabbix "c2-ec2 DescribeVolumes VolumeId.1 $1 | grep iops | cut -d\> -f2 | cut -d\< -f1"`
	if [ $iops -z 2>/dev/null ];then
		iops=400
	fi
	echo "$(($iops*9/10)) "
}

disks=`ls -l /dev/{h,s,v}d* 2>/dev/null | awk '{print $NF}' | sed -e 's/[0-9]//g' | uniq`
count=`echo $disks | wc -w`
instance_id=`curl 169.254.169.254/lastet/meta-data/instance-id 2>/dev/null`
cloud_disks=`ssh -i /var/lib/zabbix/id_rsa user@zabbix "c2-ec2 DescribeInstances InstanceId.1 $instance_id | grep vol- | cut -d\> -f2 | cut -d\< -f1"`
iops=''

for volume in $cloud_disks;do
	iops+=`get_iops $volume`
done		

ind=1
echo -e '{\n\t"data" : ['
for disk in $disks;do
if [ $ind == $count ];then
	echo -e "\t\t{\"{#DISKNAME}\":\"$disk\",\"{#SHORTDISKNAME}\":\"${disk:5}\",\"{#IOPS}\":\"`echo $iops | cut -d\  -f$ind`\"}"
else
	echo -e "\t\t{\"{#DISKNAME}\":\"$disk\",\"{#SHORTDISKNAME}\":\"${disk:5}\",\"{#IOPS}\":\"`echo $iops | cut -d\  -f$ind`\"},"
fi
ind=$((ind+1))
done
echo -e ']\n}'

