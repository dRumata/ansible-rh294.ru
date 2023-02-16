LAB 2. Deploying Ansible.

1. Убедитесь, что пакет **ansible** установлен на узле управления, и запустите команду `ansible --version`.

1.1. Убедитесь, что пакет **ansible** установлен  
```console
[student@workstation ~]$ dnf list installed ansible
Installed Packages
ansible.noarch 2.8.0-1.el8ae @rhel-8-server-ansible-2.8-rpms
```

1.2. Запустите команду `ansible –version`, чтобы подтвердить установленную версию Ansible.
```console
[student@workstation ~]$ ansible --version
ansible 2.8.0
config file = /etc/ansible/ansible.cfg
configured module search path = ['/home/student/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
ansible python module location = /usr/lib/python3.6/site-packages/ansible
executable location = /usr/bin/ansible
python version = 3.6.8 (default, Apr 3 2019, 17:26:03) [GCC 8.2.1 20180905 (RedHat 8.2.1-3)]
```

2. В домашней директории пользователя student на **workstation**, **/home/student**, создайте новую директорию с именем **deploy-review**. Перейдите в эту директорию.
```console
[student@workstation ~]$ mkdir ~/deploy-review
[student@workstation ~]$ cd ~/deploy-review
[student@workstation deploy-review]$
```   
3. Создайте файл **ansible.cfg** в каталоге **deploy-review,** который вы будете использовать для установки следующих параметров Ansible по умолчанию:
- Подключайтесь к управляемым хостам как пользователь **devops**.
- Используйте подкаталог **inventory** для хранения файла **inventory**.
- Отключите повышение привилегий по умолчанию. Если повышение привилегий включено из командной строки, настройте параметры по умолчанию, чтобы Ansible использовал метод **sudo** для переключения на учетную запись пользователя **root**. Ansible не должен запрашивать пароль для входа в **devops** или пароль **sudo**

Управляемые хосты были настроены с использованием пользователя **devops**, который может входить в систему с использованием аутентификации на основе ключа SSH и может запускать любую команду от имени **root** с помощью команды **sudo** без пароля.

3.1. Используйте текстовый редактор для создания файла **/home/student/deploy-review/ansible.cfg**. Создайте раздел **[defaults]**. Добавьте директиву **remote_user**, чтобы Ansible использовал пользователя **devops** при подключении к управляемым хостам. Добавьте директиву **inventory**, чтобы настроить Ansible на использование каталога **/home/student/deploy-review/inventory** в качестве местоположения по умолчанию для inventory-файла.

```conf
[defaults]
remote_user = devops
inventory = inventory
```

3.2.  В файле **/home/student/deploy-review/ansible.cfg** создайте раздел **[privilege_escalation]** и добавьте следующие записи, чтобы отключить повышение привилегий. Установите метод повышения привилегий для использования учетной записи **root** с помощью **sudo** без аутентификации по паролю.

```conf
[privilege_escalation]
become = False
become_method = sudo
become_user = root
become_ask_pass = False
```

3.3. Заполненный файл **ansible.cfg** должен выглядеть следующим образом:
```conf
[defaults]
remote_user = devops
inventory = inventory

[privilege_escalation]
become = False
become_method = sudo
become_user = root
become_ask_pass = False
```
Сохраните свою работу и выйдите из редактора.

4. Создайте директорию **/home/student/deploy-review/inventory**.

Скачайте файл  http://materials.example.com/labs/deploy-review/inventory и сохраните его как статический файл inventory с именем **/home/student/deploy-review/inventory/inventory**.

4.1. Создайте каталог **/home/student/deploy-review/inventory**.
```console
[student@workstation deploy-review]$ mkdir inventory
```
4.2. Загрузите файл http://materials.example.com/labs/deploy-review/inventory в каталог **/home/student/deploy-review/inventory**.

```console
[student@workstation deploy-review]$ wget -O inventory/inventory \
> http://materials.example.com/labs/deploy-review/inventory
```
4.3. Проверьте содержимое файла **/home/student/deploy-review/inventory/inventory**


```console
[student@workstation deploy-review]$ cat inventory/inventory
[internetweb]
serverb.lab.example.com

[intranetweb]
servera.lab.example.com
serverc.lab.example.com
serverd.lab.example.com
```

5. Выполните команду **id** как ad hoc команду, предназначенную для группы all host, чтобы убедиться, что **devops** является удаленным пользователем и, что повышение привилегий по умолчанию отключено.

```console
[student@workstation deploy-review]$ ansible all -m command -a 'id'
serverb.lab.example.com | CHANGED | rc=0 >>
uid=1001(devops) gid=1001(devops) groups=1001(devops) context=unconfined_u:
unconfined_r:unconfined_t:s0-s0:c0.c1023

serverc.lab.example.com | CHANGED | rc=0 >>
uid=1001(devops) gid=1001(devops) groups=1001(devops) context=unconfined_u:
unconfined_r:unconfined_t:s0-s0:c0.c1023

servera.lab.example.com | CHANGED | rc=0 >>
uid=1001(devops) gid=1001(devops) groups=1001(devops) context=unconfined_u:
unconfined_r:unconfined_t:s0-s0:c0.c1023

serverd.lab.example.com | CHANGED | rc=0 >>
uid=1001(devops) gid=1001(devops) groups=1001(devops) context=unconfined_u:
unconfined_r:unconfined_t:s0-s0:c0.c1023
```
*Ваши результаты могут быть возвращены в другом порядке.*

6. Выполните ad hoc команду, предназначенную для группы хостов **all**, которая использует модуль копирования для изменения содержимого файла **/etc/motd** на всех хостах. 

Используйте опцию **content** модуля **copy,** чтобы убедиться, что файл **/etc/motd** состоит из строки **This server is managed by Ansible. \n** в виде одной строки. (**\n**, используемый с параметром **content**, приводит к тому, что модуль помещает новую строку в конец строки.)

Вы должны запросить повышение привилегий из командной строки, чтобы заставить это работать с вашими текущими значениями по умолчанию **ansible.cfg**.

```console
[student@workstation deploy-review]$ ansible all -m copy \
> -a 'content="This server is managed by Ansible.\n" dest=/etc/motd' --become
serverd.lab.example.com | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "md5sum": "af74293c7b2a783c4f87064374e9417a",
    "mode": "0644",
    "owner": "root",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "src": "/home/devops/.ansible/tmp/ansibletmp-1558954517.7426903-24998924904061/source",
    "state": "file",
    "uid": 0
}
servera.lab.example.com | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "md5sum": "af74293c7b2a783c4f87064374e9417a",
    "mode": "0644",
    "owner": "root",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "src": "/home/devops/.ansible/tmp/ansibletmp-
    1558954517.7165847-103324013882266/source",
    "state": "file",
    "uid": 0
}
serverc.lab.example.com | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "md5sum": "af74293c7b2a783c4f87064374e9417a",
    "mode": "0644",
    "owner": "root",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "src": "/home/devops/.ansible/tmp/ansible-tmp-1558954517.75727-94151722302122/
    source",
    "state": "file",
    "uid": 0
}
serverb.lab.example.com | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "md5sum": "af74293c7b2a783c4f87064374e9417a",
    "mode": "0644",
    "owner": "root",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "src": "/home/devops/.ansible/tmp/ansibletmp-1558954517.6649802-53313238077104/source",
    "state": "file",
    "uid": 0
}
```
7. Если вы снова запустите ту же ad hoc команду, вы должны увидеть, что модуль **copy** определяет, что файлы уже являются правильными, и поэтому они не изменяются. Найдите ad hoc команду для сообщения **SUCCESS** и строку **"changed": false** для каждого управляемого хоста.

```console
[student@workstation deploy-review]$ ansible all -m copy \
> -a 'content="This server is managed by Ansible.\n" dest=/etc/motd' --become
serverb.lab.example.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "path": "/etc/motd",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "state": "file",
    "uid": 0
}
serverc.lab.example.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "path": "/etc/motd",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "state": "file",
    "uid": 0
}
serverd.lab.example.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "path": "/etc/motd",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "state": "file",
    "uid": 0
}
servera.lab.example.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "checksum": "93d304488245bb2769752b95e0180607effc69ad",
    "dest": "/etc/motd",
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "owner": "root",
    "path": "/etc/motd",
    "secontext": "system_u:object_r:etc_t:s0",
    "size": 35,
    "state": "file",
    "uid": 0
}
```
8. Чтобы подтвердить это другим способом, запустите ad hoc команду, предназначенную для группы хостов **all**, используя модуль command для выполнения команды `cat /etc/motd`. Выходные данные команды **ansible** должны отображать строку **This server is managed by Ansible.** для всех хостов. Вам не нужно повышение привилегий для этой специальной команды.

```console
[student@workstation deploy-review]$ ansible all -m command -a 'cat /etc/motd'
serverb.lab.example.com | CHANGED | rc=0 >>
This server is managed by Ansible.

servera.lab.example.com | CHANGED | rc=0 >>
This server is managed by Ansible.

serverd.lab.example.com | CHANGED | rc=0 >>
This server is managed by Ansible.

serverc.lab.example.com | CHANGED | rc=0 >>
This server is managed by Ansible.
```