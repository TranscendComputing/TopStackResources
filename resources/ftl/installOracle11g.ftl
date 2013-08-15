#!/bin/bash

#InstallOracle11g.ftl
# input config, ac, instance, dbinstance, engine. dbname, dbinstanceid, masteruser, masterpassword, avzone
# return none

export EC2_ACCESS_KEY=${account.accessKey}
export EC2_SECRET_KEY=${account.secretKey}
export S3_URL=${configuration("S3_URL", avzone)}
export EC2_URL=${configuration("EC2_URL", avzone)}
export EC2_JVM_ARGS=${configuration("EC2_JVM_ARGS", avzone)}
export EC2_USER_ID=${configuration("EC2_USER_ID", avzone)}

#Install Oracle 11g

#Create Oracle response file for silent-mode install
cat << EORF > ${config.tmpDir}/db.rsp

oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0

oracle.install.option=INSTALL_DB_AND_CONFIG

ORACLE_HOSTNAME=localhost

UNIX_GROUP_NAME=oinstall

INVENTORY_LOCATION=${config.ORACLE_BASE}/oraInventory

SELECTED_LANGUAGES=en

ORACLE_HOME=${config.ORACLE_BASE}/product/11.2.0/dbhome_1

ORACLE_BASE=${config.ORACLE_BASE}

oracle.install.db.InstallEdition=${engine}

oracle.install.db.isCustomInstall=false

oracle.install.db.customComponents=

oracle.install.db.DBA_GROUP=dba

oracle.install.db.OPER_GROUP=dba

oracle.install.db.CLUSTER_NODES=

oracle.install.db.config.starterdb.type=GENERAL_PURPOSE

oracle.install.db.config.starterdb.globalDBName=${dbname}.${dbinstanceid}.oracledb.com

oracle.install.db.config.starterdb.SID=${dbname}

oracle.install.db.config.starterdb.characterSet=WE8MSWIN1252

oracle.install.db.config.starterdb.memoryLimit=256

oracle.install.db.config.starterdb.memoryOption=true

oracle.install.db.config.starterdb.installExampleSchemas=true

oracle.install.db.config.starterdb.enableSecuritySettings=true

oracle.install.db.config.starterdb.password.ALL=${masterpassword}

oracle.install.db.config.starterdb.password.SYS=${masterpassword}

oracle.install.db.config.starterdb.password.SYSTEM=${masterpassword}

oracle.install.db.config.starterdb.password.SYSMAN=${masterpassword}

oracle.install.db.config.starterdb.password.DBSNMP=${masterpassword}

oracle.install.db.config.starterdb.control=DB_CONTROL

oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=

oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false

oracle.install.db.config.starterdb.dbcontrol.emailAddress=

oracle.install.db.config.starterdb.dbcontrol.SMTPServer=

oracle.install.db.config.starterdb.automatedBackup.enable=false

oracle.install.db.config.starterdb.automatedBackup.osuid=

oracle.install.db.config.starterdb.automatedBackup.ospwd=

oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE

oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/mnt/data/oradata

oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=/mnt/data/orarecovery

oracle.install.db.config.asm.diskGroup=

oracle.install.db.config.asm.ASMSNMPPassword=

MYORACLESUPPORT_USERNAME=

MYORACLESUPPORT_PASSWORD=

SECURITY_UPDATES_VIA_MYORACLESUPPORT=false

DECLINE_SECURITY_UPDATES=true

PROXY_HOST=

PROXY_PORT=

EORF

#Create sql script to add master user/password

cat << EOSQL > ${config.tmpDir}/${instance.instanceId}.SQL
create user ${masteruser} profile default identified by ${masterpassword}
default tablespace users
temporary tablespace temp
account unlock;
grant resource to ${masteruser} with admin option;
grant ctxapp to ${masteruser} with admin option;
grant connect to ${masteruser} with admin option;
grant dba to ${masteruser} with admin option;
exit

EOSQL




#Create shell script for instance
cat << EOSH > ${config.tmpDir}/${instance.instanceId}.sh

# add the appropriate users
groupadd -g 502 dba
groupadd oinstall
useradd -g oinstall -u 502 -m -s /bin/bash -c "Oracle Software Owner" -G dba -p oracle oracle


#Add line to '/etc/hosts file' for reference to local repository
echo "127.0.0.1					localhost" >/etc/hosts
echo "${config.YUMHOST}		${config.YUMHOST_REP}" >>/etc/hosts


# configure kernel communication parameters consistent with Oracle's needs
echo "kernel.shmall=2097152" >> /etc/sysctl.conf
echo "kernel.shmmax=536870912" >> /etc/sysctl.conf
echo "kernel.shmmni=4096" >> /etc/sysctl.conf
echo "kernel.sem=250 32000 100 128" >> /etc/sysctl.conf
echo "fs.file-max=6815744" >> /etc/sysctl.conf
echo "fs.aio-max-nr=1048576" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range=9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default=4194304" >> /etc/sysctl.conf
echo "net.core.rmem_max=4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default=262144" >> /etc/sysctl.conf
echo "net.core.wmem_max=1048576" >> /etc/sysctl.conf

echo "2097152" >/proc/sys/kernel/shmall
echo "536870912" >/proc/sys/kernel/shmmax
echo "4096" >/proc/sys/kernel/shmmni
echo "250 32000 100 128" >/proc/sys/kernel/sem
echo "6815744" > /proc/sys/fs/file-max
echo "1048576" > /proc/sys/fs/aio-max-nr
echo "9000 65500" > /proc/sys/net/ipv4/ip_local_port_range
echo "4194304" > /proc/sys/net/core/rmem_default
echo "4194304" > /proc/sys/net/core/rmem_max
echo "262144" > /proc/sys/net/core/wmem_default
echo "1048576" > /proc/sys/net/core/wmem_max

# setup the login modules For CentOS 5, add the following
echo "session required pam_limits.so" >>/etc/pam.d/login

# setup the security limits
echo "oracle soft  nproc  2047" >>/etc/security/limits.conf
echo "oracle hard  nproc  16384" >>/etc/security/limits.conf
echo "oracle soft  nofile  1024" >>/etc/security/limits.conf
echo "oracle hard  nofile  65536" >>/etc/security/limits.conf

# create the Oracle directories
ORACLE_BASE=${config.ORACLE_BASE}
mkdir -p ${config.ORACLE_BASE}
chown -R oracle:oinstall ${config.ORACLE_BASE}
chmod -R 775 ${config.ORACLE_BASE}
TMP=/mnt/oracle/tmp
mkdir -p /mnt/oracle/tmp
chown -R oracle:oinstall /mnt/oracle/tmp
chmod a+wr /mnt/oracle/tmp
TMPDIR=/mnt/oracle/tmp
chmod -R 777 /mnt/data

# setup environment
echo "TMP=/mnt/oracle/tmp" >>~oracle/.bash_profile
echo "TMPDIR=/mnt/oracle/tmp" >>~oracle/.bash_profile
echo "ulimit -u 16384 -n 65536" >>~oracle/.bash_profile
echo "ORACLE_BASE=${config.ORACLE_BASE}" >>~oracle/.bash_profile
echo "ORACLE_HOME=${config.ORACLE_BASE}/product/11.2.0/dbhome_1" >>~oracle/.bash_profile
echo "ORACLE_SID=${dbname}" >>~oracle/.bash_profileset 
echo "LD_LIBRARY_PATH=${config.ORACLE_BASE}/product/11.2.0/dbhome_1/lib" >>~oracle/.bash_profile
echo "PATH=$PATH:${config.ORACLE_BASE}/product/11.2.0/dbhome_1/bin" >>~oracle/.bash_profile
echo "export ORACLE_BASE ORACLE_HOME ORACLE_SID LD_LIBRARY_PATH PATH TMP TMPDIR" >>~oracle/.bash_profile 

#Create oraInst.loc file for silent mode installation
echo "inventory_loc=${config.ORACLE_BASE}/oraInventory inst_group=oinstall" >> /etc/oraInst.loc
chown oracle:oinstall /etc/oraInst.loc
chmod 664 /etc/oraInst.loc

#Change cache storage location
pushd /var
mv cache /mnt
ln -s /mnt/cache
popd

# add the necessary packages
yum update -y yum
yum install -y binutils compat-db control-center.x86_64 gcc gcc-c++ glibc glibc-common gnome-libs libstdc++ libstdc++-devel make pdksh sysstat xscreensaver libaio openmotif21 libaio-devel-0.3.106 compat-libstdc++-33 unixODBC-2.2.11 unixODBC-devel-2.2.11 elfutils-libelf-devel pam.x86_64 pam-devel.x86_64

#The Oracle installer requires X11, so make a VNC capable setup
yum install -y vnc-server vnc xterm xhost twm unzip make

# Change the size of the shared memory file system
umount /dev/shm
mount -t tmpfs shmfs -o size=2048m /dev/shm

#Download, unpack, and delete the .zip install files from repository
curl http://${config.YUMHOST_REP}/Oracle/11GR2/linux.x64_11gR2_database_1of2.zip > /mnt/oracle/linux.x64_11gR2_database_1of2.zip
curl http://${config.YUMHOST_REP}/Oracle/11GR2/linux.x64_11gR2_database_2of2.zip > /mnt/oracle/linux.x64_11gR2_database_2of2.zip
unzip /mnt/oracle/'*.zip' -d /mnt/oracle
rm /mnt/oracle/*.zip

#Increase swap file space
dd if=/dev/zero of=/mnt/extraswap bs=1M count=256
mkswap /mnt/extraswap
swapon /mnt/extraswap


#Chmod on response file
chmod 777 /tmp/db.rsp

#Get VM IP address, set domain name, echoroc/sys/kernel/sem
echo "6815744" > /proc/sys/f into hosts
echo "\$(ip addr show dev eth0 | sed -e's/^.*inet \([^ ]*\)\/.*$/\1/;t;d')      ${dbname}.${dbinstanceid}.oracledb.com" >>/etc/hosts

#Set hostname
hostname ${dbname}.${dbinstanceid}.oracledb.com

#Change to install user, cd to /mnt/oracle/database, run ./runInstaller
su - oracle -c "/mnt/oracle/database/./runInstaller -silent \ -responseFile /tmp/db.rsp"
sleep 30

#Run root.sh to complete install
pid=\`ps -ef | grep [O]raInstall | awk '{print \$2}'\`
while ps -p \$pid > /dev/null; do sleep 1; done 
sh ${config.ORACLE_BASE}/product/11.2.0/dbhome_1/root.sh

su - oracle -c "sqlplus SYS@${dbname}/${masterpassword} as SYSDBA @/tmp/${instance.instanceId}.SQL"

EOSH

<#if config.useIpforInstances == "yes" >
  <#assign ip=instance.ipAddress />
<#else>
  <#assign ip=instance.dns />	
</#if>

scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.sh root@${ip}:/root
scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/${instance.instanceId}.SQL root@${ip}:/tmp
scp -i ${config.keysDir}/${account.defKeyName}.pem -o StrictHostKeyChecking=false ${config.tmpDir}/db.rsp root@${ip}:/tmp
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "chmod +x /root/${instance.instanceId}.sh"
ssh -i ${config.keysDir}/${account.defKeyName}.pem root@${ip} -o StrictHostKeyChecking=false "/root/${instance.instanceId}.sh"

