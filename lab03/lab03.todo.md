/etc/hosts
192.168.7.191 servera servera.lab.example.com
192.168.7.199 serverb serverb.lab.example.com
192.168.7.193 serverc serverc.lab.example.com
192.168.7.197 serverd serverd.lab.example.com
192.168.7.198 workstation workstation.lab.example.com



sudo adduser devops
sudo usermod -aG wheel devops
sudo passwd devops

# todo
user newbie uid=4000
ssh-keygen
ssh-copy-id devops@server[a:c]
ssh-copy-id student@localhost devops@localhost

playbook-basic
playbook-multi

index.php -> https://gist.github.com/dRumata/e092d6a42ad250ed28561a670a1004a9


/etc/hosts 192.168.7.185 materials materials.example.com

подготовить файл
url: "http://materials.example.com/labs/playbook-review/index.php"