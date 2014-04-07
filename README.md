How to use ansible to build a complete VM
=========================================


On the host
-----------

1/ generate a private key

```
ssh-keygen -f id_rsa_vm
```

2/ add it to ssh-agent

```
ssh-agent
ssh-add id_rsa_vm
```

3/ connection setup between the host and the vm

with virtualbox we will setup the first vm with both a nat interface and a hostonly interface
```
VBoxManage add
```

for some reason, my mac do not route automatically to vboxnet3 thus i added a route manually
```
sudo route -nv add -net 192.168.2 -interface vboxnet3
```

4/ edit /etc/hosts to simplify connection to vm
```
#
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
fe80::1%lo0     localhost
# my mac
192.168.0.9     imac-pierre.home
# web
192.168.2.11    web1.7pi.local
192.168.2.12    web2.7pi.local
192.168.2.13    web3.7pi.local
192.168.2.14    web4.7pi.local
192.168.2.15    web5.7pi.local
192.168.2.16    web6.7pi.local
192.168.2.17    web7.7pi.local
192.168.2.18    web8.7pi.local
192.168.2.19    web9.7pi.local
# db
192.168.2.20    db-master.7pi.local
192.168.2.21    db-slave1.7pi.local
192.168.2.22    db-slave2.7pi.local
192.168.2.23    db-slave3.7pi.local
# lb
192.168.2.31    lb1.7pi.local
192.168.2.32    lb2.7pi.local
192.168.2.33    lb3.7pi.local
# queue
192.168.2.41    queue1.7pi.local
192.168.2.42    queue2.7pi.local
192.168.2.43    queue3.7pi.local
# redis
192.168.2.51    redis1.7pi.local
192.168.2.52    redis2.7pi.local
192.168.2.53    redis3.7pi.local
# cassandra
192.168.2.61    cass1.7pi.local
192.168.2.62    cass2.7pi.local
192.168.2.63    cass3.7pi.local
# admin vm
192.168.2.97    backup.7pi.local
192.168.2.98    admin-fallback.7pi.local
192.168.2.99    admin.7pi.local
```


In the vm
---------

3/ activate port forwarding from host to vm

for me host ip is *192.168.0.9* and vm ip is *10.0.3.15*

thus in virtualbox interface add:

```
192.168.0.9 2200 to 10.0.3.14 22
```

4/ in the vm copy id_rsa_vm.pub to $HOME/.ssh/authorized_keys

```
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
scp pierre@192.168.0.9:/users/pierre/.ssh/id_rsa_vm.pub $HOME/.ssh/authorized_keys
chmod 400 $HOME/.ssh/authorized_keys
```

5/ add pierre in the sudoers
```
sudo visudo
```
add at the end of the file:
```
pierre ALL=(ALL) NOPASSWD: ALL
```

On the host
-----------

Clone all needed vm from the working one
```
for vm in web1 web2 redis1 db-master db-slave1 admin; do
    VBoxManage clonevm "ubuntu-13.10-base" --snapshot snap-base-clone --mode machine --options link --name ${vm}.7pi.local --groups "/7pi.local" --register
done
```


5/ check all is working
```
ssh pierre@192.168.0.9 -p 2222
```

should connect you to the vm on pierre account without a password

6/ create a hosts file for ansible

```
cat > hosts &> EOF
default ansible_ssh_host=192.168.0.9 ansible_ssh_port=2200
```

7/ make a ping to ansible to check all is ok
```
ansible default -i hosts -m ping
```
you should see something like
```
default | success >> {
    "changed": false,
    "ping": "pong"
}
```
You are now ready!

8/ configure certificates for logstash
```
openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout logstash-forwarder.key -out logstash-forwarder.crt

```
and copy them into roles/admin/files
```
mv logstash-forwarder.* roles/admin/files
```

9/ configure certificates for shinken
```
openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout shinken.key -out shinken.crt

```
and copy them into roles/admin/files
```
mv shinken.* roles/admin/files
```
