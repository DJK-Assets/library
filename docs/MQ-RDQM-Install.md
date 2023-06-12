# Deploying MQ RDQM with Floating IP Address on VSphere

[Download Instructions](./pdf/Deploying%20MQ%20RDQM%20with%20Floating%20IP%20Address%20on%20VSphere.pdf)

This is the instructions for deploying RDQM and configuring a HA Queue Manager with floating ip address. 

## Requirements


**Platform:  VSphere 6.7**

* 3 Virtual Machines

**VM OS:     RHEL 9.2**

* Need a second disk 100 GB on all 3 VM’s
* 2 CPU x 16GB of Mem
* Public IP Address

**Software:  IBM MQ 9.3.0.2**

* Download the software from IBM’s Internal DSW Downloads Site [Software XL](https://w3-03.ibm.com/software/xl/download/ticket.wss)


##Sites of Interest

* [https://www.ibm.com/docs/en/ibm-mq/9.3?topic=configurations-rdqm-high-availability](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=configurations-rdqm-high-availability)
* [https://www.royalcyber.com/blog/middleware/high-availability-of-replicated-data-queue-manager/](https://www.royalcyber.com/blog/middleware/high-availability-of-replicated-data-queue-manager/)

**Preparing for RDQM**

* [https://www.ibm.com/docs/en/ibm-mq/9.3?topic=configurations-rdqm-high-availability](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=configurations-rdqm-high-availability)
* [https://community.ibm.com/community/user/integration/blogs/prema-laxmanachar1/2022/08/10/detailed-procedure-of-migrating-regular-ibm-mq-que](https://community.ibm.com/community/user/integration/blogs/prema-laxmanachar1/2022/08/10/detailed-procedure-of-migrating-regular-ibm-mq-que)
* [https://www.ibm.com/docs/en/ibm-mq/9.3?topic=availability-requirements-rdqm-ha-solution](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=availability-requirements-rdqm-ha-solution)
* [https://www.redhat.com/sysadmin/create-physical-volume](https://www.redhat.com/sysadmin/create-physical-volume)

##General Commands that were of use during my attempts to install

```
yum upgrade 
yum update
yum update kernel
hostnamectl  <-- Verify Kernel version matches on all 3 machines.
```

##Installing RDQM


[Documentation](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=multiplatforms-installing-rdqm-replicated-data-queue-managers)


**1. Provision 3 (2CPU x 16GB mem) machines in VSphere**
	
* Uncheck the "SECURE BOOT" option for all 3 VM's
	
* Minimum requirements are 2CPU x 16GB of Mem
	
* Add an extra 100GB disk
	 

**2. Install packages (on all 3 boxes)**

``` R
sudo yum -y install libxslt net-snmp-libs nfs-utils nfs-utils-coreos perl-TimeDate python3-lxml python-unversioned-command
```

**3. SCP the install file (to all three servers)**

``` R
scp <file>@<ipaddress of target>:<location on target to place file>
```

 EXAMPLE: 

 `scp ./IBM_MQ_9.3.0.2_LINUX_X86-64.tar.gz bastion@10.67.42.177:/home/bastion/`

**4. Untar the file (on all 3 servers)**

``` R
tar -xvf IBM_MQ_9.3.0.2_LINUX_X86-64.tar.gz
```

**5. Install kernal** 

**NOTE:** *I ran into issues when trying to use the drbd kernel that is provided with the IBM MQ 9.3.0.2 download. I had to download a NEWER one because the RHEL OS was at a higher version than what was expected.* 

Look on this page for a download for RHEL 9.2 Kernal to match the OS

**Interim kernel module releases**

* [https://www.ibm.com/support/pages/ibm-mq-replicated-data-queue-manager-kernel-modules#LTS9_2](https://www.ibm.com/support/pages/ibm-mq-replicated-data-queue-manager-kernel-modules#LTS9_2)
* [https://www.ibm.com/support/fixcentral/swg/downloadFixes?parent=ibm%2FWebSphere&product=ibm/WebSphere/WebSphere+MQ&release=All&platform=All&function=fixId&fixids=9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14&includeRequisites=1&includeSupersedes=0&downloadMethod=http&source=SAR](https://www.ibm.com/support/fixcentral/swg/downloadFixes?parent=ibm%2FWebSphere&product=ibm/WebSphere/WebSphere+MQ&release=All&platform=All&function=fixId&fixids=9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14&includeRequisites=1&includeSupersedes=0&downloadMethod=http&source=SAR)

	**THIS IS THE FILE I USED:** interim fix: 9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14

	**Steps to install (On all 3 machines)**

``` R
wget https://ak-delivery04-mul.dhe.ibm.com/sdfdl/v2/sar/CM/WS/0bfrk/0/Xa.2/Xb.jusyLTSp44S03o2r0ALI9rdnHzZDQ4Pdhenqod7cCfzE79MnOWh_uumEiKA/Xc.CM/WS/0bfrk/0/9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14.tgz/Xd./Xf.LPR.D1VK/Xg.12320491/Xi.habanero/XY.habanero/XZ.toSiALXjCZMNaORuZis7fBS2qXvKsM_3/9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14.tgz
```

``` R
tar -xvf 9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14.tgz
```

``` R
cd 9-IBM-MQ-LAIT43724-kmod-drbd-9.1.14
```

``` R
yum install ./yum install ./kmod-drbd-9.1.14+ptf.2_5.14.0_284.11.1-1.x86_64.rpm
```

**6. Install DRBD Utils**

``` R
yum install /home/bastion/MQServer/Advanced/RDQM/PreReqs/el9/drbd-utils-9/*
```

**7. Install Pacemaker**

``` R
yum install /home/bastion/MQServer/Advanced/RDQM/PreReqs/el9/pacemaker-2/*
```

**8. Accept the license**

``` R
/home/bastion/MQServer/mqlicense.sh
```

**9. Install MQ**

``` R
cd /home/bastion/MQServer
yum install MQSeriesGSKit* MQSeriesServer* MQSeriesRuntime*
```

**10. Install RDQM**

``` R
cd /home/bastion/MQServer
yum install Advanced/RDQM/MQSeriesRDQM*
```

##Preparing VM’s for setup of RDQM

**Useful Commands:**

* pvscan
* pvs
* pvcreate
* pvdisplay
* cfdisk
* lvmdiskscan

**Setup the disk volume group for DRBD**

Do this on all 3 VM’s 

Find the disk device.. In my case it was /dev/sbd

``` R
ls /dev/sd*
```

Create the PV

``` R
pvcreate /dev/sdb
```

Create the Volume Group

``` R
vgcreate drbdpool /dev/sdb
```

##Setup Passwordless SSH Login on all 3 VM’s

[https://www.ibm.com/docs/en/ibm-mq/9.2?topic=solution-setting-up-passwordless-ssh](https://www.ibm.com/docs/en/ibm-mq/9.2?topic=solution-setting-up-passwordless-ssh)

``` R
usermod -d /home/mqm mqm
```

``` R
mkhomedir_helper mqm
```

Set the password

``` R
passwd mqm
```

``` R
su mqm
```

``` R
ssh-keygen -t rsa -f /home/mqm/.ssh/id_rsa -N ''
```

Copy Keys to all 3 VM's

``` R
ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub <ip address VM1>
ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub <ip address VM2>
ssh-copy-id -i /home/mqm/.ssh/id_rsa.pub <ip address VM3>
```

verify.. On each VM you can access without password

``` R
ssh <ip address VM1>uname -n
ssh <ip address VM2>uname -n
ssh <ip address VM3>uname -n
```

**NOTE**: *You may be prompted for fingerprint the first time, so you NEED to TEST.*

Do on all machines

Exit out of mqm user

``` R
exit
```

Switch to root user

``` R
su
```

``` R
passwd -d mqm
passwd -l mqm
```

##Add mqm user to sudo file 

Run this command on all three servers and make the following edits.

```	 R
visudo  
```
**ADD THE FOLLLOWING LINE BELOW THIS COMMENT**
  
`## Allows people in group wheel to run all commands`

```	 R
#%mqm    ALL=(ALL)       ALL
```

**ADD THE FOLLLOWING LINE BELOW THIS COMMENT**    

`## Same thing without a password`

```	 R
%mqm            ALL=(ALL)       NOPASSWD: ALL
```

##Configure SELINUX Security

**NOTE**: *Run these commands on all machines as ROOT*

``` R
semanage permissive -a drbd_t
```

``` R
/opt/mqm/samp/rdqm/firewalld/configure.sh
```

##Setup local dns

**NOTE**: *Run these commands on all machines as ROOT*

``` R
vi /etc/hosts
```

**ADD THIS TO THE FILE**

```
<ip address VM1> qm1
<ip address VM2> qm2
<ip address VM3> qm3
```

##Configure RDMQ INI File

**NOTE**: *Run these commands on all machines as ROOT*

``` R
vi /var/mqm/rdqm.ini
```

**EDIT FILE LIKE THIS**

```
	Node:
	  Name=qm1
  	     HA_Replication=10.67.42.177
      	  HA_Primary=10.67.42.177
      	  #  HA_Alternate=
          #  DR_Replication=10.67.42.177
    Node:
      Name=qm2
      	 HA_Replication=10.67.42.155
        HA_Primary=10.67.42.155
      	 #  HA_Alternate=
      	 #  DR_Replication=10.67.42.155
    Node:
      Name=qm3
        HA_Replication=10.67.42.153
        HA_Primary=10.67.42.153
        #  HA_Alternate=
        #  DR_Replication=10.67.42.153
```

##Configure Pacemaker group

``` R
/opt/mqm/bin/rdqmadm -c
```

##Configure NEW RDQM QueueManager
 
``` R
/opt/mqm/bin/crtmqm -sx qmgrdk3

/opt/mqm/bin/crtmqm -sxs -fs 3072M qmgrdk1
```

##Disable Secure boot

[https://access.redhat.com/solutions/6955734](https://access.redhat.com/solutions/6955734)

``` R
/usr/bin/mokutil --disable-validation
```

**NOTE:**  *Take note of the password you set*

``` R
shutdown -h now
```

**Modify the settings on the VM in VSphere** 
*Uncheck the secure boot check box in the boot options.* 

**Validate that is't not on.**

```
/usr/bin/mokutil --sb-state
```

##Configure Floating IP Address

[https://www.ibm.com/docs/en/ibm-mq/9.3?topic=availability-creating-deleting-floating-ip-address](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=availability-creating-deleting-floating-ip-address)

**NOTE:** *You will need to to have the network card id. You can find that by issuing the following command.*

``` R
ifconfig
```


``` R
/opt/mqm/bin/rdqmint -m qmgrdk3 -a  -f <Floating IP Address> -l ens192
```