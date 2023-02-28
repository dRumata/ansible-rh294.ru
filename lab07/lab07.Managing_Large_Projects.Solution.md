LAB 7. Managing Large Projects. Solution.

Внесите следующие изменения в файл **playbook.yml**, чтобы им было проще управлять, и настройте его таким образом, чтобы при будущих запусках использовались текущие обновления для предотвращения одновременной недоступности всех четырех веб-серверов.

1. Упростите список управляемых хостов в playbook, используя шаблон хоста с wildecard паттернами. Используйте inventory/inventory.py сценарий динамической инвентаризации для проверки шаблона узла с wildecard паттернами.
  
  1.1. Измените каталог на рабочий каталог /home/student/projects-review. Просмотрите конфигурационный файл ansible.cfg, чтобы определить местоположение файла инвентаризации. Инвентарь определяется как подкаталог inventory, и этот подкаталог содержит inventory.py сценарий динамической инвентаризации.
```console
[student@workstation ~]$ cd ~/projects-review
[student@workstation projects-review]$ cat ansible.cfg
[defaults]
inventory = inventory
...output omitted...
[student@workstation projects-review]$ ll
total 16
-rw-rw-r--. 1 student student 33 Dec 19 00:48 ansible.cfg
drwxrwxr-x. 2 student student 4096 Dec 18 22:35 files
drwxrwxr-x. 2 student student 4096 Dec 19 01:18 inventory
-rw-rw-r--. 1 student student 959 Dec 18 23:48 playbook.yml
[student@workstation projects-review]$ ll inventory/
total 4
-rwxrwxr-x. 1 student student 612 Dec 19 01:18 inventory.py
```
  1.2. Сделайте так, чтобы inventory/inventory.py исполняемый файл сценария динамической инвентаризации, а затем запустите сценарий динамической инвентаризации с параметром --list, чтобы отобразить полный список узлов в инвентаре.
```console
[student@workstation projects-review]$ chmod 755 inventory/inventory.py
[student@workstation projects-review]$ inventory/inventory.py --list
{"all": {"hosts": ["servera.lab.example.com", "serverb.lab.example.com",
 "serverc.lab.example.com", "serverd.lab.example.com",
 "workstation.lab.example.com"], "vars": { }}}
```
  1.3. Убедитесь, что сервер шаблонов хоста*.lab.example.com правильно идентифицирует четыре управляемых хоста, на которые нацелен playbook.yml playbook.
```console
[student@workstation projects-review]$ ansible server*.lab.example.com \
> --list-hosts
  hosts (4):
    serverb.lab.example.com
    serverd.lab.example.com
    servera.lab.example.com
    serverc.lab.example.com
```
  1.4. Замените список хостов в playbook.yml playbook на сервер*.lab.example.com шаблон хоста.
```yaml
---
- name: Install and configure web service
  hosts: server*.lab.example.com
...output omitted...
```

2. Реструктурируйте playbook таким образом, чтобы первые три задачи в playbook хранились во внешнем файле задач, расположенном по адресу **tasks/web_tasks.yml**. Используйте функцию **import_tasks**, чтобы включить этот файл задачи в playbook.
   
  2.1. Создайте подкаталог **tasks**.
```console
[student@workstation projects-review]$ mkdir tasks
```

  2.2. Поместите содержимое первых трех заданий из **playbook.yml** в **tasks/web_tasks.yml**. Файл задачи должен содержать следующее содержимое:
```yaml
---
- name: Install httpd
  yum:
    name: httpd
    state: latest

- name: Enable and start httpd
  service:
    name: httpd
    enabled: true
    state: started

- name: Tuning configuration installed
  copy:
    src: files/tune.conf
    dest: /etc/httpd/conf.d/tune.conf
    owner: root
    group: root
    mode: 0644
  notify:
    - restart httpd
```
  2.3. Удалите первые три задачи из **playbook.yml** и поместите на их место следующие строки, чтобы импортировать tasks/web_tasks.yml файл задачи.
```yaml
- name: Import the web_tasks.yml task file
  import_tasks: tasks/web_tasks.yml
```
3. Реструктурируйте playbook таким образом, чтобы четвертая, пятая и шестая задачи в playbook хранились во внешнем файле задач, расположенном по адресу **tasks/firewall_tasks.yml**. Используйте функцию **import_tasks**, чтобы включить этот файл задачи в playbook.
  3.1. Поместите содержимое трех оставшихся заданий в **playbook.yml** в **tasks/firewall_tasks.yml**. Файл задачи должен содержать следующее содержимое.
```yaml
---
- name: Install firewalld
  yum:
    name: firewalld
    state: latest

- name: Enable and start the firewall
  service:
    name: firewalld
    enabled: true
    state: started

- name: Open the port for http
  firewalld:
    service: http
    immediate: true
    permanent: true
    state: enabled
```
  3.2. Удалите оставшиеся три задачи из **playbook.yml** и поместите на их место следующие строки, чтобы импортировать **tasks/firewall_tasks.yml**.
```yaml
- name: Import the firewall_tasks.yml task file
  import_tasks: tasks/firewall_tasks.yml
```

4. Существует некоторое дублирование задач между **tasks/web_tasks.yml** и **tasks/firewall_tasks.yml**. Переместите задачи, которые устанавливают пакеты и включают службы, в новый файл с именем **tasks/install_and_enable.yml** и обновите их, чтобы использовать переменные.
Замените исходные задачи операторами **import_tasks**, передав соответствующие значения переменных.
  
  4.1. Скопируйте задачи yum и service из **tasks/web_tasks.yml** в новый файл с именем **tasks/install_and_enable.yml**.
```yaml
---
- name: Install httpd
  yum:
    name: httpd
    state: latest

- name: Enable and start httpd
  service:
    name: httpd
    enabled: true
    state: started
```
  4.2. Замените имена пакетов и служб в **tasks/install_and_enable.yml** с переменными **package** и **service**.
```yaml
---
- name: Install {{ package }}
  yum:
    name: "{{ package }}"
    state: latest

- name: Enable and start {{ service }}
  service:
    name: "{{ service }}"
    enabled: true
    state: started
```
  4.3. Замените задачи yum и service в **tasks/web_tasks.yml** и **tasks/firewall_tasks.yml**  инструкциями **import_tasks**.
```yaml
---
- name: Install and start httpd
  import_tasks: install_and_enable.yml
  vars:
    package: httpd
    service: httpd
```
```yaml
---
- name: Install and start firewalld
  import_tasks: install_and_enable.yml
  vars:
    package: firewalld
    service: firewalld
```
5. Поскольку обработчик для перезапуска службы httpd может быть запущен, если в будущем будут внесены изменения в файл **files/tune.conf**, реализуйте функцию rolling update в **playbook.yml** и установите rolling update размер пакета на два хоста.
  
  5.1. Добавьте параметр **serial** в **playbook.yml**.
```yaml
---
- name: Install and configure web service
  hosts: server*.lab.example.com
  serial: 2
 ...output omitted...
 ```
 6. Убедитесь, что изменения в **playbook.yml** были внесены правильно, а затем запустите playbook.
  6.1. Убедитесь, что **playbook.yml** содержит следующее содержимое.
```yaml
---
- name: Install and configure web service
  hosts: server*.lab.example.com
  serial: 2
  tasks:
    - name: Import the web_tasks.yml task file
      import_tasks: tasks/web_tasks.yml

    - name: Import the firewall_tasks.yml task file
      import_tasks: tasks/firewall_tasks.yml

  handlers:
    - name: restart httpd
      service:
        name: httpd
        state: restarted
```

  6.2. Запустите playbook с помощью `ansible-playbook --syntax-check`, чтобы убедиться, что playbook не содержит синтаксических ошибок. Если присутствуют ошибки, исправьте их.
```console
[student@workstation projects-review]$ ansible-playbook playbook.yml --syntax-check
playbook: playbook.yml
```

  6.3. Execute the playbook. The playbook should execute against the host as a rolling update with a batch size of two managed hosts.
```console
[student@workstation projects-review]$ ansible-playbook playbook.yml

PLAY [Install and configure web service] ***********************************

TASK [Gathering Facts] *****************************************************
ok: [serverd.lab.example.com]
ok: [serverb.lab.example.com]

TASK [Install httpd] *******************************************************
changed: [serverd.lab.example.com]
changed: [serverb.lab.example.com]

TASK [Enable and start httpd] **********************************************
changed: [serverd.lab.example.com]
changed: [serverb.lab.example.com]

TASK [Tuning configuration installed] **************************************
changed: [serverb.lab.example.com]
changed: [serverd.lab.example.com]

TASK [Install firewalld] ***************************************************
ok: [serverb.lab.example.com]
ok: [serverd.lab.example.com]

TASK [Enable and start firewalld] ******************************************
ok: [serverd.lab.example.com]
ok: [serverb.lab.example.com]

TASK [Open the port for http] **********************************************
changed: [serverd.lab.example.com]
changed: [serverb.lab.example.com]

RUNNING HANDLER [restart httpd] ********************************************
changed: [serverb.lab.example.com]
changed: [serverd.lab.example.com]

PLAY [Install and configure web service] ***********************************

TASK [Gathering Facts] *****************************************************
ok: [serverc.lab.example.com]
ok: [servera.lab.example.com]

TASK [Install httpd] *******************************************************
changed: [serverc.lab.example.com]
changed: [servera.lab.example.com]

TASK [Enable and start httpd] **********************************************
changed: [serverc.lab.example.com]
changed: [servera.lab.example.com]

TASK [Tuning configuration installed] **************************************
changed: [servera.lab.example.com]
changed: [serverc.lab.example.com]

TASK [Install firewalld] ***************************************************
ok: [servera.lab.example.com]
ok: [serverc.lab.example.com]

TASK [Enable and start firewalld] ******************************************
ok: [servera.lab.example.com]
ok: [serverc.lab.example.com]

TASK [Open the port for http] **********************************************
changed: [servera.lab.example.com]
changed: [serverc.lab.example.com]

RUNNING HANDLER [restart httpd] ********************************************
changed: [serverc.lab.example.com]
changed: [servera.lab.example.com]

PLAY RECAP *****************************************************************
servera.lab.example.com : ok=8 changed=2 unreachable=0 failed=0
serverb.lab.example.com : ok=8 changed=5 unreachable=0 failed=0
serverc.lab.example.com : ok=8 changed=5 unreachable=0 failed=0
serverd.lab.example.com : ok=8 changed=5 unreachable=0 failed=0
```