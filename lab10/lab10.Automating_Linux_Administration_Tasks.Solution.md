LAB 10. Automating Linux Administration Tasks. Solution.

1. Создайте и запустите в группе хостов **webservers** playbook, который настраивает внутренний репозиторий Yum, расположенный по адресу http://materials.example.com/yum/repository, и устанавливает пакет **example-motd**, доступный в этом репозитории. Все пакеты RPM подписаны организационной парой ключей GPG. Открытый ключ GPG доступен по адресу http://materials.example.com/yum/repository/RPM-GPG-KEY-example
1.1. Как пользователь **student** на **workstation** перейдите в рабочий каталог **/home/student/system-review**.
``` console
[student@workstation ~]$ cd ~/system-review
[student@workstation system-review]$
```
1.2. Создайте **repo_playbook.yml** playbook, который запускается на управляемых хостах в группе хостов **webservers**. Добавьте задачу, которая использует модуль **yum_repository** для обеспечения конфигурации внутреннего хранилища yum на удаленном хосте. Убедитесь, что:
- Конфигурация репозитория хранится в файле **/etc/yum.repos.d/example.repo**
- ID репозитория **example-internal**
- URL-адрес репозитория http://materials.example.com/yum/repository
- Репозиторий настроен на проверку подписей RPM GPG
- Описание репозитория - **Example Inc. Internal YUM repo**

Playbook содержит следующее:   
``` yaml
---
- name: Repository Configuration
  hosts: webservers
  tasks:
    - name: Ensure Example Repo exists
      yum_repository:
        name: example-internal
        description: Example Inc. Internal YUM repo
        file: example
        baseurl: http://materials.example.com/yum/repository/
        gpgcheck: yes
```

1.3. Добавьте в play вторую задачу, которая использует модуль **rpm_key**, чтобы убедиться, что открытый ключ хранилища присутствует на удаленном хосте. URL-адрес открытого ключа репозитория является http://materials.example.com/yum/repository/RPM-GPG-KEY-example .
Вторая задача выглядит следующим образом:
``` yaml
    - name: Ensure Repo RPM key is Installed
      rpm_key:
        key: http://materials.example.com/yum/repository/RPM-GPG-KEY-example
        state: present
```
1.4. Добавьте третью задачу для установки пакета **example-motd**, доступного во внутреннем репозитории **Yum**.
Третья задача выглядит следующим образом:
``` yaml
    - name: Install Example motd package
      yum:
        name: example-motd
        state: present
```
1.5. Запустите playbook:
``` console
[student@workstation system-review]$ ansible-playbook repo_playbook.yml

PLAY [Repository Configuration] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [serverb.lab.example.com]

TASK [Ensure Example Repo exists] **********************************************
changed: [serverb.lab.example.com]

TASK [Ensure Repo RPM Key is Installed] ****************************************
changed: [serverb.lab.example.com]

TASK [Install Example motd package] ********************************************
changed: [serverb.lab.example.com]

PLAY RECAP *********************************************************************
serverb.lab.example.com : ok=4 changed=3 unreachable=0 failed=0
```

2. Создайте и запустите в группе хостов **webservers** playbook, который создает группу пользователей **webadmin**, и добавьте в эту группу двух пользователей, **ops1** и **ops2**.

2.1. Создайте файл переменных **vars/users_vars.yml**, который определяет двух пользователей, **ops1** и **ops2**, которые принадлежат к группе пользователей **webadmin**. Возможно, вам потребуется создать подкаталог **vars**

``` console
[student@workstation system-review]$ mkdir vars
[student@workstation system-review]$ vi vars/users_vars.yml
---
users:
  - username: ops1
    groups: webadmin
  - username: ops2
    groups: webadmin
```

2.2. Создайте playbook **users.yml**. Определите отдельный play, предназначенный для группы хостов **webservers**. Добавьте предложение **vars_files**, которое определяет местоположение имени файла **vars/users_vars.yml**. Добавьте задачу, которая использует модуль **group** для создания группы пользователей **webadmin** на удаленном хосте.
``` yaml
---
- name: Create multiple local users
  hosts: webservers
  vars_files:
    - vars/users_vars.yml
  tasks:
    - name: Add webadmin group
      group:
        name: webadmin
        state: present
```
2.3. Добавьте вторую задачу в playbook, которая использует модуль **user** для создания пользователей. Добавьте предложение **loop: "{{ users }}"** к задаче для перебора файла переменных для каждого имени пользователя, найденного в файле **vars/users_vars.yml**. В качестве **name:** для пользователей используйте **item.username** в качестве имени переменной. Таким образом, файл переменной может содержать дополнительную информацию, которая может быть полезна для создания пользователей, например, группы, к которым пользователи должны принадлежать. Вторая задача содержит следующее:
``` yaml
    - name: Create user accounts
      user:
        name: "{{ item.username }}"
        groups: webadmin
      loop: "{{ users }}"
```
2.4. Выполните playbook:
``` console
[student@workstation system-review]$ ansible-playbook users.yml

PLAY [Create multiple local users]
****************************************************

TASK [Gathering Facts]
****************************************************************
ok: [serverb.lab.example.com]

TASK [Add webadmin group]
*************************************************************
changed: [serverb.lab.example.com]

TASK [Create user accounts]
***********************************************************
changed: [serverb.lab.example.com] => (item={'username': 'ops1', 'groups':
 'webadmin'})
changed: [serverb.lab.example.com] => (item={'username': 'ops2', 'groups':
 'webadmin'})

PLAY RECAP
****************************************************************************
serverb.lab.example.com : ok=3 changed=2 unreachable=0 failed=0
```
3. Создайте и запустите в группе хостов **webservers** playbook, который использует устройство **/dev/vdb** для создания группы томов с именем apache-vg. Этот сборник также создает два логических тома с именами **content-lv** и **logs-lv**, оба поддерживаются группой томов **apache-vg**. Наконец, он создает файловую систему XFS на каждом логическом томе и монтирует логический том **content-lv** в **/var/www** и логический том **logs-lv** в **/var/log/httpd**.
Лабораторный скрипт заполняет два файла в **~/system-review**, **storage.yml**, который предоставляет начальный каркас для playbook, и **storage_vars.xml** который предоставляет значения для всех переменных, требуемых различными модулями.
3.1. Просмотрите файл переменных **storage_vars.yml**.
``` console
[student@workstation system-review]$ cat storage_vars.yml
---
partitions:
  - number: 1
    start: 1MiB
    end: 257MiB

volume_groups:
  - name: apache-vg
    devices: /dev/vdb1

logical_volumes:
  - name: content-lv
    size: 64M
    vgroup: apache-vg
    mount_path: /var/www

  - name: logs-lv
    size: 128M
    vgroup: apache-vg
    mount_path: /var/log/httpd
```
Этот файл описывает предполагаемую структуру разделов, групп томов и логических
томов на каждом веб-сервере. Первый раздел начинается со смещения в 1 мбайт от
начала устройства **/dev/vdb** и заканчивается смещением в 257 Мбайт, при общем размере
256 Мбайт.
Каждый веб-сервер имеет одну группу томов с именем **apache-vg**, содержащую первый
раздел устройства **/dev/vdb**.
Каждый веб-сервер имеет два логических тома. Первый логический том называется **contentlv**, имеет размер 64 Мбайт, присоединен к группе томов **apache-vg** и смонтирован по адресу **/var/www**. Второй логический том называется **content-lv**, размером 128 Мбайт, присоединен к группе томов **apache-vg** и смонтирован по адресу **/var/log/httpd**.
>Note
> Группа томов **apache-vg** имеет емкость 256 Мбайт, поскольку она поддерживается разделом **/dev/vdb1**. Он обеспечивает достаточную емкость для обоих логических томов.

3.2. Измените первую задачу в **storage.yml** playbook, чтобы использовать модуль **parted** для настройки раздела для каждого элемента цикла. Каждый элемент описывает предполагаемый раздел устройства **/dev/vdb** на каждом веб-сервере:

number
    Номер раздела. Используйте это в качестве значения ключевого слова **number** для модуля **parted**.

start
    Начало раздела, как смещение от начала блочного устройства. Используйте это как значение ключевого слова **part_start** для модуля **parted**.

end
    Конец раздела, как смещение от начала блочного устройства. Используйте это как значение ключевого слова **part_end** для модуля **parted**.

Содержание первого задания должно быть:
``` yaml
    - name: Correct partitions exist on /dev/vdb
      parted:
        device: /dev/vdb
        state: present
        number: "{{ item.number }}"
        part_start: "{{ item.start }}"
        part_end: "{{ item.end }}"
      loop: "{{ partitions }}"
```
3.3. Измените вторую задачу, чтобы использовать модуль **lvg** для настройки группы томов
для каждого элемента цикла. Каждый элемент переменной **volume_groups** описывает
группу томов, которая должна существовать на каждом веб-сервере:

name
    Название группы томов. Используйте это в качестве значения ключевого слова **vg** для модуля **lvg**.

devices
    Разделенный запятыми список устройств или разделов, которые образуют группу томов. Используйте это в качестве значения ключевого слова **pvs** для модуля **lvg**.

Содержание второго задания должно быть:
``` yaml
    - name: Ensure Volume Groups Exist
      lvg:
        vg: "{{ item.name }}"
        pvs: "{{ item.devices }}"
      loop: "{{  volume_groups }}"
```

3.4. Измените третью задачу на использование модуля **lvol**. Задайте название группы томов, имя логического тома и размер логического тома, используя ключевые слова каждого элемента. Содержание третьего задания теперь:
``` yaml
    - name: Create each Logical Volume (LV) if needed
      lvol:
        vg: "{{ item.vgroup }}"
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
      loop: "{{ logical_volumes }}"
```

3.5. Измените четвертую задачу на использование модуля **filesystem**. Настройте задачу таким образом, чтобы каждый логический том был отформатирован как файловая система XFS. Напомним, что логический том связан с логическим устройством `/dev/<volumegroupname>/<logicalvolumename>`.
Содержание четвертого задания должно быть:
``` yaml
    - name: Ensure XFS Filesystem exists on each LV
      filesystem:
        dev: "/dev/{{ item.vgroup }}/{{ item.name }}"
        fstype: xfs
      loop: "{{ logical_volumes }}"
```
3.6. Настройте пятую задачу, чтобы убедиться, что каждый логический том имеет надлежащий объем хранилища. Если емкость логического тома увеличивается, обязательно принудительно расширьте файловую систему тома.
>Warning
> Если логическому тому необходимо уменьшить емкость, эта задача завершится неудачей, поскольку файловая система XFS не поддерживает уменьшение емкости. 

Содержание пятого задания должно быть:
``` yaml
    - name: Ensure the correct capacity for each LV
      lvol:
        vg: "{{ item.vgroup }}"
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
        resizefs: yes
        force: yes
      loop: "{{ logical_volumes }}"
```

3.7. Используйте модуль **mount** в шестой задаче, чтобы убедиться, что каждый логический том смонтирован по соответствующему пути монтирования и сохраняется после перезагрузки.
Содержание шестой задачи должно быть:
``` yaml
    - name: Each Logical Volume is mounted
      mount:
        path: "{{ item.mount_path }}"
        src: "/dev/{{ item.vgroup }}/{{ item.name }}"
        fstype: xfs
        state: mounted
      loop: "{{ logical_volumes }}"
```
3.8. Запустите playbook для создания логических томов на удаленном хосте.
``` console
[student@workstation system-review]$ ansible-playbook storage.yml

PLAY [Ensure Apache Storage Configuration]
*************************************************

TASK [Gathering Facts]
*********************************************************************
ok: [serverb.lab.example.com]

TASK [Correct partitions exist on /dev/vdb]
************************************************
changed: [serverb.lab.example.com] => (item={'number': 1, 'start': '1MiB', 'end':
'257MiB'})

TASK [Ensure Volume Groups Exist]
**********************************************************
changed: [serverb.lab.example.com] => (item={'name': 'apache-vg', 'devices': '/
dev/vdb1'})
...output omitted...

TASK [Create each Logical Volume (LV) if needed]
*******************************************
changed: [serverb.lab.example.com] => (item={'name': 'content-lv', 'size': '64M',
'vgroup': 'apache-vg', 'mount_path': '/var/www'})
changed: [serverb.lab.example.com] => (item={'name': 'logs-lv', 'size': '128M',
'vgroup': 'apache-vg', 'mount_path': '/var/log/httpd'})

TASK [Ensure XFS Filesystem exists on each LV]
*********************************************
changed: [serverb.lab.example.com] => (item={'name': 'content-lv', 'size': '64M',
'vgroup': 'apache-vg', 'mount_path': '/var/www'})
changed: [serverb.lab.example.com] => (item={'name': 'logs-lv', 'size': '128M',
'vgroup': 'apache-vg', 'mount_path': '/var/log/httpd'})

TASK [Ensure the correct capacity for each LV]
*********************************************
ok: [serverb.lab.example.com] => (item={'name': 'content-lv', 'size': '64M',
'vgroup': 'apache-vg', 'mount_path': '/var/www'})
ok: [serverb.lab.example.com] => (item={'name': 'logs-lv', 'size': '128M',
'vgroup': 'apache-vg', 'mount_path': '/var/log/httpd'})

TASK [Each Logical Volume is mounted]
******************************************************
changed: [serverb.lab.example.com] => (item={'name': 'content-lv', 'size': '64M',
'vgroup': 'apache-vg', 'mount_path': '/var/www'})
changed: [serverb.lab.example.com] => (item={'name': 'logs-lv', 'size': '128M',
'vgroup': 'apache-vg', 'mount_path': '/var/log/httpd'})

PLAY RECAP
*********************************************************************************
serverb.lab.example.com : ok=7 changed=5 unreachable=0 failed=0
```

4. Создайте и запустите в группе хостов **webservers** playbook, который использует модуль **cron** для создания файла **/etc/cron.d/disk_usage** crontab, который планирует повторяющееся задание **cron**.
Задание должно выполняться от имени пользователя **devops** каждые две минуты с 09:00 до 16:59 c понедельника по пятницу Задание должно добавить текущее использование диска в файл **/home/devops/disk_usage**.

4.1. Create a new playbook, create_crontab_file.yml, and add the lines needed to
start the play. It should target the managed hosts in the webservers group and enable
privilege escalation.
``` yaml
---
- name: Recurring cron job
  hosts: webservers
  become: true
```

4.2. Define a task that uses the cron module to schedule a recurring cron job.
>Note
>The cron module provides a name option to uniquely describe the crontab file entry and to ensure expected results. The description is added to the crontab file.
>For example, the name option is required if you are removing a crontab entry using state=absent. Additionally, when the default state, state=present is set, the name option prevents a new crontab entry from always being created, regardless of existing ones.
``` yaml
  tasks:
    - name: Crontab file exists
      cron:
        name: Add date and time to a file
```

4.3. Configure the job to run every two minutes between 09:00 and 16:59 on Monday
through Friday.
``` yaml
        minute: "*/2"
        hour: 9-16
        weekday: 1-5
```

4.4. Use the cron_file parameter to use the /etc/cron.d/disk_usage crontab file
instead of an individual user's crontab in /var/spool/cron/. A relative path will place
the file in /etc/cron.d directory. If the cron_file parameter is used, you must also
specify the user parameter.
``` yaml
        user: devops
        job: df >> /home/devops/disk_usage
        cron_file: disk_usage
        state: present
```

4.5. When completed, the playbook should appear as follows. Review the playbook for
accuracy.
``` yaml
---
- name: Recurring cron job
  hosts: webservers
  become: true
  tasks:
    - name: Crontab file exists
      cron:
        name: Add date and time to a file
        minute: "*/2"
        hour: 9-16
        weekday: 1-5
        user: devops
        job: df >> /home/devops/disk_usage
        cron_file: disk_usage
        state: present
```

4.6. Run the playbook.
``` console
[student@workstation system-review]$ ansible-playbook create_crontab_file.yml

PLAY [Recurring cron job]
*********************************************************************

TASK [Gathering Facts]
************************************************************************
ok: [serverb.lab.example.com]

TASK [Crontab file exists]
********************************************************************
changed: [serverb.lab.example.com]

PLAY RECAP
*********************************************************************************
***
serverb.lab.example.com : ok=2 changed=1 unreachable=0 failed=0
```

5. Создайте и запустите в группе хостов **webservers** учебное пособие, которое использует роль **linuxsystem-roles.network** для настройки резервного сетевого интерфейса **ens4** c IP-адресом **172.25.250.40/24**.

5.1. Use ansible-galaxy to verify that system roles are available. If not, you need to
install the rhel-system-roles package.
``` console
[student@workstation system-review]$ ansible-galaxy list
# /usr/share/ansible/roles
- linux-system-roles.kdump, (unknown version)
- linux-system-roles.network, (unknown version)
- linux-system-roles.postfix, (unknown version)
- linux-system-roles.selinux, (unknown version)
- linux-system-roles.timesync, (unknown version)
- rhel-system-roles.kdump, (unknown version)
- rhel-system-roles.network, (unknown version)
- rhel-system-roles.postfix, (unknown version)
- rhel-system-roles.selinux, (unknown version)
- rhel-system-roles.timesync, (unknown version)
# /etc/ansible/roles
[WARNING]: - the configured path /home/student/.ansible/roles does not exist.
```

5.2. Create a playbook, network_playbook.yml, with one play that targets the
webservers host group. Include the rhel-system-roles.network role in the
roles section of the play.
``` yaml
---
- name: NIC Configuration
  hosts: webservers
  roles:
    - rhel-system-roles.network
```

5.3. Create the group_vars/webservers subdirectory.
``` console
[student@workstation system-review]$ mkdir -pv group_vars/webservers
mkdir: created directory 'group_vars'
mkdir: created directory 'group_vars/webservers'
```

5.4. Create a new file network.yml to define role variables. Because these variable values
apply to the hosts on the webservers host group, you need to create that file in
the group_vars/webservers directory. Add variable definitions to support the
configuration of the ens4 network interface. The file now contains:
``` console
[student@workstation system-review]$ vi group_vars/webservers/network.yml
---
network_connections:
- name: ens4
type: ethernet
ip:
address:
- 172.25.250.40/24
```

5.5. Run the playbook to configure the secondary network interface.
``` console
[student@workstation system-review]$ ansible-playbook network_playbook.yml

PLAY [NIC Configuration]
*******************************************************************

TASK [Gathering Facts]
*********************************************************************
ok: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Check which services are running]
************************
ok: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Check which packages are installed]
**********************
ok: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Print network provider]
**********************************
ok: [serverb.lab.example.com] => {
"msg": "Using network provider: nm"
}

TASK [rhel-system-roles.network : Install packages]
****************************************
skipping: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Enable network service]
**********************************
ok: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Configure networking connection profiles]
****************

[WARNING]: [002] <info> #0, state:None persistent_state:present, 'ens4': add
connection
ens4, 38d63afd-e610-4929-ba1b-1d38413219fb
changed: [serverb.lab.example.com]

TASK [rhel-system-roles.network : Re-test connectivity]
************************************
ok: [serverb.lab.example.com]

PLAY RECAP
*********************************************************************************
serverb.lab.example.com : ok=7 changed=1 unreachable=0 failed=0
```

5.6. Verify that the ens4 network interface uses the 172.25.250.40 IP address. It may
take up to a minute to configure the IP address.
``` console
[student@workstation system-review]$ ansible webservers -m setup -a 'filter=ansible_ens4'
serverb.lab.example.com | SUCCESS => {
"ansible_facts": {
"ansible_ens4": {
...output omitted...
"ipv4": {
"address": "172.25.250.40",
"broadcast": "172.25.250.255",
"netmask": "255.255.255.0",
"network": "172.25.250.0"
},
...output omitted...
```