# zabbix_disk_discovery

Disk discovery rule for Zabbix, scans all block devices like hda/sda/vda, gather IOPS limit via ec2 API. After executing script will generate the next JSON output:
```
{
	"data" : [
		{"{#DISKNAME}":"/dev/vda","{#SHORTDISKNAME}":"vda","{#IOPS}":"360"},
		{"{#DISKNAME}":"/dev/vdb","{#SHORTDISKNAME}":"vdb","{#IOPS}":"2700"}
]
}
```
In zbx_export_disk_discovery.xml is located discovery rule for Zabbix. There are the next items:

* vfs.dev.read[{#DISKNAME},ops]
* vfs.dev.write[{#DISKNAME},ops]
* vfs.dev.total[{#DISKNAME}] = last("vfs.dev.write[{#DISKNAME},ops]") + last("vfs.dev.read[{#DISKNAME},ops]")
* **Triger** - vfs.dev.total[{#DISKNAME}].last() > {#IOPS}

