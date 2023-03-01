LAB 9. Troubleshooting Ansible. Solution.

1. В каталоге **~/troubleshoot-review** проверьте сценария **secure-web.yml**. Этот сценарий содержит один play, который настраивает Apache HTTPD с использованием TLS/SSL для хостов в группе **webservers**. Устраните проблему, о которой сообщается. 
1.1. On workstation, change to the /home/student/troubleshoot-review project
directory.
```console
[student@workstation ~]$ cd ~/troubleshoot-review/
```
1.2. Check the syntax of the secure-web.yml playbook. This playbook sets up Apache
HTTPD with TLS/SSL for hosts in the webservers group when everything is correct.
```console
[student@workstation troubleshoot-review]$ ansible-playbook --syntax-check \
> secure-web.yml
ERROR! Syntax Error while loading YAML.
mapping values are not allowed in this context
The error appears to have been in '/home/student/Ansible-course/troubleshootreview/
secure-web.yml': line 7, column 30, but may
be elsewhere in the file depending on the exact syntax problem.
The offending line appears to be:
vars:
random_var: This is colon: test
^ here
```
1.3. Correct the syntax issue in the definition of the random_var variable by adding double
quotes to the This is colon: test string. The resulting change should appear as
follows:
```
...output omitted...
vars:
random_var: "This is colon: test"
...output omitted...
```
2. Еще раз проверьте синтаксис сценария **secure-web.yml**. Устраните проблему, о которой сообщается
2.1. Check the syntax of secure-web.yml using ansible-playbook --syntaxcheck
again.
```
[student@workstation troubleshoot-review]$ ansible-playbook --syntax-check \
> secure-web.yml
ERROR! Syntax Error while loading YAML.
did not find expected '-' indicator
The error appears to have been in '/home/student/Ansible-course/troubleshootreview/
secure-web.yml': line 38, column 10, but may
be elsewhere in the file depending on the exact syntax problem.
The offending line appears to be:
- name: start and enable web services
^ here
```
2.2. Correct any syntax issues in the indentation. Remove the extra space at the beginning
of the start and enable web services task elements. The resulting change should appear
as follows:
```
...output omitted...
args:
creates: /etc/pki/tls/certs/serverb.lab.example.com.crt
- name: start and enable web services
service:
name: httpd
state: started
enabled: yes
- name: deliver content
copy:
dest: /var/www/vhosts/serverb-secure
src: html/
...output omitted...
```
3. Проверьте синтаксис сценария **secure-web.yml** в третий раз. Устраните проблему, о которой сообщается. 
3.1. Check the syntax of the secure-web.yml playbook.
```
[student@workstation troubleshoot-review]$ ansible-playbook --syntax-check \
> secure-web.yml
ERROR! Syntax Error while loading YAML.
found unacceptable key (unhashable type: 'AnsibleMapping')
The error appears to have been in '/home/student/Ansible-course/troubleshootreview/
secure-web.yml': line 13, column 20, but may
be elsewhere in the file depending on the exact syntax problem.
The offending line appears to be:
yum:
name: {{ item }}
^ here
We could be wrong, but this one looks like it might be an issue with
missing quotes. Always quote template expression brackets when they
start a value. For instance:
with_items:
- {{ foo }}
Should be written as:
with_items:
- "{{ foo }}"
```
3.2. Correct the item variable in the install web server packages task. Add double
quotes to {{ item }}. The resulting change should appear as follows:
```
...output omitted...
- name: install web server packages
yum:
name: "{{ item }}"
state: latest
notify:
- restart services
loop:
- httpd
- mod_ssl
...output omitted...
```
4. Проверьте синтаксис сценария **secure-web.yml** в четвертый раз. Он не должен показывать никаких синтаксических ошибок. 
4.1. Review the syntax of the secure-web.yml playbook. It should not show any syntax
errors.
```[student@workstation troubleshoot-review]$ ansible-playbook --syntax-check \
> secure-web.yml
playbook: secure-web.yml
```
5. Запустите **secure-web.yml** playbook. Ansible не может подключиться к **serverb.lab.example.com** . Устраните эту проблему. 
5.1. Run the secure-web.yml playbook. This will fail with an error.
```
[student@workstation troubleshoot-review]$ ansible-playbook secure-web.yml
PLAY [create secure web service] ***********************************************
TASK [Gathering Facts] *********************************************************
fatal: [serverb.lab.example.com]: UNREACHABLE! => {"changed": false, "msg":
"Failed to connect to the host via ssh: students@serverc.lab.example.com:
Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).",
"unreachable": true}
PLAY RECAP *********************************************************************
serverb.lab.example.com : ok=0 changed=0 unreachable=1 failed=0
```
5.2. Run the secure-web.yml playbook again, adding the -vvvv parameter to increase
the verbosity of the output.
Notice that Ansible appears to be connecting to serverc.lab.example.com instead
of serverb.lab.example.com.
```
[student@workstation troubleshoot-review]$ ansible-playbook secure-web.yml -vvvv
...output omitted...
TASK [Gathering Facts] *********************************************************
task path: /home/student/troubleshoot-review/secure-web.yml:3
<serverc.lab.example.com> ESTABLISH SSH CONNECTION FOR USER: students
<serverc.lab.example.com> SSH: EXEC ssh -vvv -C -o ControlMaster=auto
-o ControlPersist=60s -o KbdInteractiveAuthentication=no -o
PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o
PasswordAuthentication=no -o User=students -o ConnectTimeout=10 -o ControlPath=/
home/student/.ansible/cp/bc0c05136a serverc.lab.example.com '/bin/sh -c '"'"'echo
~students && sleep 0'"'"''
...output omitted...
```
5.3. Correct the line in the inventory-lab file. Delete the ansible_host host variable
so the file appears as shown below:
```
[webservers]
serverb.lab.example.com
```
6. Снова запустите **secure-web.yml** playbook. Ansible должен пройти аутентификацию как удаленный пользователь **devops** на управляемом хосте. Исправьте эту проблему. 
6.1. Run the secure-web.yml playbook.
```
[student@workstation troubleshoot-review]$ ansible-playbook secure-web.yml -vvvv
...output omitted...
TASK [Gathering Facts] *********************************************************
task path: /home/student/troubleshoot-review/secure-web.yml:3
<serverb.lab.example.com> ESTABLISH SSH CONNECTION FOR USER: students
<serverb.lab.example.com> EXEC ssh -C -vvv -o ControlMaster=auto
-o ControlPersist=60s -o Port=22 -o KbdInteractiveAuthentication=no
-o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey
-o PasswordAuthentication=no -o User=students -o ConnectTimeout=10
-o ControlPath=/home/student/.ansible/cp/ansible-ssh-%C -tt
serverb.lab.example.com '/bin/sh -c '"'"'( umask 22 && mkdir -p "`
echo $HOME/.ansible/tmp/ansible-tmp-1460241127.16-3182613343880 `" &&
echo "` echo $HOME/.ansible/tmp/ansible-tmp-1460241127.16-3182613343880
`" )'"'"''
...output omitted...
fatal: [serverb.lab.example.com]: UNREACHABLE! => {
...output omitted...
```
6.2. Edit the secure-web.yml playbook to make sure devops is the remote_user for
the play. The first lines of the playbook should appear as follows:
```
---
# start of secure web server playbook
- name: create secure web service
hosts: webservers
remote_user: devops
...output omitted...
```
7. Запустите **secure-web.yml** playbook в третий раз. Устраните проблему, о которой сообщается. 
7.1. Run the secure-web.yml playbook.
```
[student@workstation troubleshoot-review]$ ansible-playbook secure-web.yml -vvvv
...output omitted...
failed: [serverb.lab.example.com] (item=mod_ssl) => {
"ansible_loop_var": "item",
"changed": false,
"invocation": {
"module_args": {
"allow_downgrade": false,
"autoremove": false,
...output omitted...
"validate_certs": true
}
},
"item": "mod_ssl",
"msg": "This command has to be run under the root user.",
"results": []
}
...output omitted...
```
7.2. Edit the play to make sure that it has become: true or become: yes set. The
resulting change should appear as follows:
```
---
# start of secure web server playbook
- name: create secure web service
hosts: webservers
remote_user: devops
become: true
...output omitted...
```
8. Запустите **secure-web.yml** playbook еще раз. Это должно завершиться успешно. Используйте специальную команду, чтобы убедиться, что служба httpd запущена.
8.1. Run the secure-web.yml playbook.
```
[student@workstation troubleshoot-review]$ ansible-playbook secure-web.yml
PLAY [create secure web service] ***********************************************
...output omitted...
TASK [install web server packages] *********************************************
changed: [serverb.lab.example.com] => (item=httpd)
changed: [serverb.lab.example.com] => (item=mod_ssl)
...output omitted...
TASK [httpd_conf_syntax variable] **********************************************
ok: [serverb.lab.example.com] => {
"msg": "The httpd_conf_syntax variable value is {'stderr_lines': [u'Syntax
OK'], u'changed': True, u'end': u'2018-12-17 23:31:53.191871', 'failed': False,
u'stdout': u'', u'cmd': [u'/sbin/httpd', u'-t'], u'rc': 0, u'start': u'2018-12-17
23:31:53.149759', u'stderr': u'Syntax OK', u'delta': u'0:00:00.042112',
'stdout_lines': [], 'failed_when_result': False}"
}
...output omitted...
RUNNING HANDLER [restart services] *********************************************
changed: [serverb.lab.example.com]
PLAY RECAP *********************************************************************
serverb.lab.example.com : ok=10 changed=7 unreachable=0 failed=0
```
8.2. Use an ad hoc command to determine the state of the httpd service on
serverb.lab.example.com. The httpd service should now be running on
serverb.lab.example.com.
```
[student@workstation troubleshoot-review]$ ansible all -u devops -b \
> -m command -a 'systemctl status httpd'
serverb.lab.example.com | CHANGED | rc=0 >>
● httpd.service - The Apache HTTP Server
Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset:
disabled)
Active: active (running) since Thu 2019-04-11 03:22:34 EDT; 28s ago
...output omitted...
```