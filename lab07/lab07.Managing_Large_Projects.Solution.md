LAB 6. Deploying Files to Managed Hosts. Solution. 

1. Создайте файл инвентаризации с именем **inventory** в каталоге **/home/student/filereview**. Этот файл инвентаризации определяет группу **servers**, которая содержит **serverb.lab.example.com** управляемый хост. 
   
  1.1. На **workstation** перейдите в каталог /**home/student/file-review**.
```console
[student@workstation ~]$ cd ~/file-review/
```

  1.2. Создайте файл инвентаризации в текущем каталоге. Этот файл настраивает одну группу, называемую серверами. Включают в себя serverb.lab.example.com система в группе серверов.
```json
[servers]
serverb.lab.example.com
```

2. Определите факты о **serverb.lab.example.com** которые показывают общий объем системной памяти и количество процессоров. 
Используйте модуль **setup**, чтобы получить список всех фактов для **serverb.lab.example.com** управляемый хост. Факты **ansible_processor_count** и **ansible_memtotal_mb** предоставляют информацию об ограничениях ресурсов управляемого хоста.
```console
[student@workstation file-review]$ ansible serverb.lab.example.com -m setup
serverb.lab.example.com | SUCCESS => {
    "ansible_facts": {
...output omitted...
  "ansible_processor_count": 1,
...output omitted...
  "ansible_memtotal_mb": 821,
...output omitted...
    },
    "changed": false
}
```

3. Создайте шаблон для Message of the Day, с именем **motd.j2** в текущем каталоге. Когда пользователь **devops** входит в **serverb.lab.example.com** , должно появиться сообщение, показывающее общее количество системной памяти и процессора. Используйте факты **ansible_facts['memtotal_mb']** и **ansible_facts['processor_count']**, чтобы предоставить информацию о системных ресурсах для сообщения. 
```jinja
System total memory: {{ ansible_facts['memtotal_mb'] }} MiB.
System processor count: {{ ansible_facts['processor_count'] }}
```

4. Создайте новый файл playbook с именем **motd.yml** в текущем каталоге. Используя модуль шаблонов, настройте ранее созданный файл шаблона **motd.j2** Jinja2 для сопоставления с файлом **/etc/motd** на управляемых хостах. У этого файла есть пользователь **root** в качестве владельца и группы, а его разрешения - 0644. Используя модули **stat** и **debug**, создайте задачи для проверки того, что **/etc/motd** существует на управляемых хостах, и отобразите информацию о файле для **/etc/motd**. Используйте модуль **copy** для размещения **files/issue** в каталог **/etc/** на управляемом хосте, используйте те же права владения и разрешения, что и **/etc/motd**. Используйте модуль **file**, чтобы убедиться, что **/etc/issue.net** - это символическая ссылка на **/etc/issue** на управляемом хосте. Настройте playbook таким образом, чтобы он использовал пользователя **devops**, и установите параметру **become** значение **true**.
```yaml
---
- name: Configure system
  hosts: all
  remote_user: devops
  become: true
  tasks:
    - name: Configure a custom /etc/motd
      template:
        src: motd.j2
        dest: /etc/motd
        owner: root
        group: root
        mode: 0644

    - name: Check file exists
      stat:
        path: /etc/motd
      register: motd

    - name: Display stat results
      debug:
        var: motd

    - name: COpy custom /etc/issue file
      copy:
        src: files/issue
        dest: /etc/issue
        owner: root
        group: root
        mode: 0644

    - name: Ensure /etc/issue.net is a symlink to /etc/issue
      file:
        src: /etc/issue
        dest: /etc/issue.net
        state: link
        owner: root
        group: root
        force: yes
```

5. Запустите playbook, включенный в файл **motd.yml**.

  5.1. Перед запуском playbook используйте команду `ansible-playbook --syntax-check` для проверки его синтаксиса. Если он сообщает о каких-либо ошибках, исправьте их, прежде чем переходить к следующему шагу. Вы должны увидеть вывод, подобный следующему:
```console
[student@workstation file-review]$ ansible-playbook --syntax-check motd.yml

playbook: motd.yml
```
  5.2. Запустите playbook, включенный в файл **motd.yml**.
```console
[student@workstation file-review]$ ansible-playbook motd.yml

PLAY [Configure system] ****************************************************

TASK [Gathering Facts] *****************************************************
ok: [serverb.lab.example.com]

TASK [Configure a custom /etc/motd] ****************************************
changed: [serverb.lab.example.com]

TASK [Check file exists] ***************************************************
ok: [serverb.lab.example.com]

TASK [Display stat results] ************************************************
ok: [serverb.lab.example.com] => {
    "motd": {
        "changed": false,
        "failed": false,
...output omitted...

TASK [Copy custom /etc/issue file] *****************************************
changed: [serverb.lab.example.com]

TASK [Ensure /etc/issue.net is a symlink to /etc/issue] ********************
changed: [serverb.lab.example.com]

PLAY RECAP *****************************************************************
serverb.lab.example.com : ok=6 changed=3 unreachable=0 failed=0
```

6. Убедитесь, что playbook, включенный в файл **motd.yml**, был выполнен правильно.
Войдите в **serverb.lab.example.com** под пользователем **devops** и убедитесь, что содержимое **/etc/motd** и **/etc/issue** отображается при входе в систему. Выйдите из системы, когда закончите.
```console
[student@workstation file-review]$ ssh devops@serverb.lab.example.com
*------------------------------- PRIVATE SYSTEM -----------------------------*
* Access to this computer system is restricted to authorised users only.     *
*                                                                            *
* Customer information is confidential and must not be disclosed.            *
*----------------------------------------------------------------------------*
System total memory: 821 MiB.
System processor count: 1
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Thu Apr 25 22:09:33 2019 from 172.25.250.9
[devops@serverb ~]$ logout
```
