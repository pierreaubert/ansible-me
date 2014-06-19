How to use ansible to build a complete server
=============================================
0. some conventions
   - user is *pierre*
   - *host* is a machine you are loggued to with ip *192.168.0.9*
   - *server* is a *ubuntu* machine you want to configure with ip *192.168.0.18*

   of course you need to replace this ip with yours ;)

1. generate a private key on the *host*
```
ssh-keygen -f id_rsa_vm
```

2. add it to ssh-agent
```
ssh-agent
ssh-add id_rsa_vm
```

3. on the server copy id_rsa_vm.pub to $HOME/.ssh/authorized_keys
```
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
scp pierre@192.168.0.9:/users/pierre/.ssh/id_rsa_vm.pub $HOME/.ssh/authorized_keys
chmod 400 $HOME/.ssh/authorized_keys
```

4. add yourself to sudoers
```
sudo visudo
```
add at the end of the file:
```
pierre ALL=(ALL) NOPASSWD: ALL
```

5. check all is working
```
ssh pierre@192.168.0.18
```
should connect you to the server *ubuntu* on account *pierre* without a password

6. create a hosts file for ansible
```
cat > hosts &> EOF
default ansible_ssh_host=192.168.0.18 ansible_ssh_port=22
```

8. make a ping to ansible to check all is ok
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

9. lunch ansible on all receipes
```
ansible-playbook -i hosts mono.yml
```

10. maintenance operation
* do a full backup
```
ansible-playbook -i hosts mono.yml -t do-backup -e maintenance=true
```
* upgrade kibana
```
ansible-playbook -i hosts mono.yml -t kibana -e upgrade=true
```


You are now ready!
