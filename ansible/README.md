
```
eval $(ssh-agent) ; ssh-add ~/.ssh/id_rsa
ansible-playbook -i fserv9 ./roles/vivado.yml
```
