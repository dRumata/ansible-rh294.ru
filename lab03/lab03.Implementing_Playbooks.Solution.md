LAB 3. Implementing Playbooks. Solution.

1. Создайте новый сценарий (playbook), **/home/student/playbook-review/internet.yml**, и добавьте необходимые записи для запуска первого play c именем **Enable internet services** и укажите предполагаемый управляемый хост, **serverb.lab.example.com** . Добавьте запись, чтобы включить повышение привилегий, и одну, чтобы запустить список задач.

1.1. Добавьте следующую запись в начало **/home/student/playbook-review/internet.yml**, чтобы начать формат YAML.
```yaml
---
```
1.2. Добавьте следующую запись для обозначения начала play с названием **Enable internet services**.
```yaml
- name: Enable internet services
```
1.3. Добавьте следующую запись, чтобы указать, что play применяется к хосту **serverb**.
```yaml
hosts: serverb.lab.example.com
```
1.4. Добавьте следующую запись, чтобы включить повышение привилегий.
```yaml
become: yes
```
1.5. Добавьте следующую запись, чтобы определить начало списка задач.
```yaml
tasks:
```

2. Добавьте необходимые записи в файл **/home/student/playbook-review/internet.yml**, чтобы определить задачу, которая устанавливает последние версии пакетов *firewalld, httpd, mariadb-server, php и php-mysqlnd*.
```yaml
    - name: latest version of all required packages installed
      yum:
        name:
          - firewalld
          - httpd
          - mariadb-server
          - php
          - php-mysqlnd
        state: latest
```

3. Добавьте необходимые записи в файл **/home/student/playbook-review/internet.yml**, чтобы определить задачи настройки брандмауэра. Они должны убедиться, что служба **firewalld** включена (**enabled**) и запущена (**runing**), а также что разрешен доступ к службе **httpd**.
```yaml
    - name: firewalld enabled and running
      service:
        name: firewalld
        enabled: true
        state: started

    - name: firewalld permits http service
      firewalld:
        service: http
        permanent: true
        state: enabled
        immediate: yes
```

4. Добавьте необходимые задачи, чтобы убедиться, что службы **httpd** и **mariadb** включены и запущены.
```yaml
    - name: httpd enabled and running
      service:
        name: httpd
        enabled: true
        state: started

    - name: mariadb enabled and running
      service:
        name: mariadb
        enabled: true
        state: started
```

5. Добавьте необходимые записи, чтобы определить конечную задачу по созданию веб-контента для тестирования. Используйте модуль **get_url** для копирования http://materials.example.com/labs/playbook-review/index.php в **/var/www/html/** на управляемом хосте.
```yaml
    - name: test php page is installed
      get_url:
        url: "http://materials.example.com/labs/playbook-review/index.php"
        dest: /var/www/html/index.php
        mode: 0644
```
6. В **/home/student/playbook-review/internet.yml** определите другой play для задачи, которая будет выполняться на узле управления. В этом play будет протестирован доступ к веб-серверу, который должен быть запущен на управляемом сервере **serverb**. Этот play не требует повышения привилегий и будет выполняться на управляемом хосте **localhost**.

6.1. Добавьте следующую запись для обозначения начала второго сценария с именем **Test internet web server**.
```yaml
- name: Test internet web server
```
6.2. Добавьте следующую запись, чтобы указать, что сценарий применяется к управляемому хосту **localhost**.
```yaml
hosts: localhost
```

6.3. Добавьте следующую строку после ключевого слова **hosts**, чтобы отключить повышение привилегий для второго сценария.
```yaml
become: no
```

6.4. Добавьте запись в файл **/home/student/playbook-review/internet.yml**, чтобы определить начало списка задач.
```yaml
tasks:
```

7. Добавьте задачу, которая тестирует веб-службу, запущенную на **serverb**, с узла управления, используя модуль **uri**. Проверьте наличие кода состояния возврата, равного **200**.
```yaml
    - name: connect to internet web server
      uri:
        url: http://serverb.lab.example.com
        status_code: 200
```

8. Проверьте синтаксис сценария **internet.yml**.
```console
[student@workstation playbook-review]$ ansible-playbook --syntax-check internet.yml

playbook: internet.yml
```

9.  Используйте команду ansible-playbook для запуска playbook. Прочитайте сгенерированные выходные данные, чтобы убедиться, что все задачи выполнены успешно.
```console
[student@workstation playbook-review]$ ansible-playbook internet.yml

PLAY [Enable internet services] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [serverb.lab.example.com]

TASK [latest version of all required packages installed] ***********************
changed: [serverb.lab.example.com]

TASK [firewalld enabled and running] *******************************************
ok: [serverb.lab.example.com]

TASK [firewalld permits http service] ******************************************
changed: [serverb.lab.example.com]

TASK [httpd enabled and running] ***********************************************
changed: [serverb.lab.example.com]

TASK [mariadb enabled and running] *********************************************
changed: [serverb.lab.example.com]

TASK [test php page installed] *************************************************
changed: [serverb.lab.example.com]

PLAY [Test internet web server] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

TASK [connect to internet web server] ******************************************
ok: [localhost]

PLAY RECAP *********************************************************************
localhost : ok=2 changed=0 unreachable=0 failed=0
serverb.lab.example.com : ok=7 changed=5 unreachable=0 failed=0
```