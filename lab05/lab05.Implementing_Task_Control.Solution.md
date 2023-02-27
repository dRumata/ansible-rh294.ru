LAB 5. Implementing Task Control. Solution. 

1. На рабочей станции перейдите в каталог проекта **/home/student/control-review**.
```console
[student@workstation ~]$ cd ~/control-review
[student@workstation control-review]$
```
2. Каталог проекта содержит частично заполненный playbook, **playbook.yml**. Используя текстовый редактор, добавьте задачу, использующую модуль fail после комментария **#Fail Fast Message**.
Обязательно укажите подходящее название для задачи. Эта задача должна выполняться только в том случае, если удаленная система не соответствует минимальным требованиям.
Минимальные требования к удаленному хосту перечислены ниже:
- Имеет по крайней мере объем оперативной памяти, указанный переменной **min_ram_mb**. Переменная **min_ram_mb** определена в файле **vars.yml** и имеет значение **256**.
- Работает под управлением Red Hat Enterprise Linux.
```yaml
  tasks:
    #Fail Fast Message
    - name: Show Failed System Requirements Message
      fail:
        msg: "The {{ inventory_hostname }} did not meet minimum reqs"
      when:
        ansible_memtotal_mb < min_ram_mb or
        ansible_distribution != "RedHat"
```

3. Добавьте одну задачу в playbook под комментарием **#Install all Packages**, чтобы установить последнюю версию всех отсутствующих пакетов. Требуемые пакеты задаются переменной **packages**, которая определена в файле **vars.yml**. Название задачи должно быть **Ensure required packages are present**.
```yaml
    #Install all Packages
    - name: Ensure required packages are present
      yum:
        name: "{{ packages }}"
        state: latest
```

4. Добавьте одну задачу в playbook под комментарием **#Enable and start services**, чтобы запустить все службы. Все службы, указанные переменной **services**, которая определена в файле **vars.yml**, должны быть запущены и включены. Обязательно укажите подходящее название для задачи.
```yaml
    #Enable and start services
    - name: Ensure services are started and enabled
      service:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop: "{{ services }}"
```

5. Добавьте блок задач в playbook под комментарием **#Block of config tasks**. Этот блок содержит две задачи:
- Задача убедиться, что каталог, указанный переменной **ssl_cert_dir**, существует на удаленном хосте. В этом каталоге хранятся сертификаты веб-сервера.
- Задача скопировать все файлы, указанные переменной **web_config_files**, на удаленный хост. Изучите структуру переменной **web_config_files** в файле **vars.yml**. Настройте задачу на копирование каждого файла в правильное место назначения на удаленном хосте.
Эта задача должна вызвать обработчик **restart web service**, если какой-либо из этих файлов будет изменен на удаленном сервере.

Кроме того, задача отладки выполняется, если любая из двух вышеперечисленных задач завершается неудачей. В этом случае задача выводит сообщение: **One or more of the configuration changes failed,
but the web service is still active..**
Обязательно укажите подходящее название для всех задач.
```yaml
    #Block of config tasks
    - name: Setting up the SSL cert directory and config files
      block:
      - name: Create SSL cert directory
        file:
          path: "{{ ssl_cert_dir }}"
          state: directory

      - name: Copy Config Files
        copy:
          src: "{{ item.src }}"
          dest: "{{ item.dest }}"
        loop: "{{ web_config_files }}"
        notify: restart web service

      rescue: 
        - name: Configuration Error Message
          debug:
            msg: >
              One or more of the configuration
              changes failed, but the web service
              is still active.
 ```

6. Playbook настраивает удаленный хост на прослушивание стандартных запросов HTTPS. Добавьте одну задачу в playbook под комментарием **#Configure the firewall**, чтобы настроить **firewalld**.
Эта задача должна гарантировать, что удаленный хост допускает стандартные соединения HTTP и HTTPS. Эти изменения конфигурации должны вступить в силу немедленно и сохраняться после перезагрузки системы. Обязательно укажите подходящее название для задачи.
```yaml
    #Configure the firewall
    - name: ensure web server ports are open
      firewalld:
        service: "{{ item }}"
        immediate: true
        permanent: true
        state: enabled
      loop:
        - http
        - https
```

7. Определите обработчик **restart web service**.
При запуске эта задача должна перезапустить веб-службу, определенную переменной **web_service**, определенной в файле **vars.yml**.
```yaml
  #Add handlers
  handlers:
    - name: restart web service
      service:
        name: "{{ web_service }}"
        state: restarted
```

8. Из каталога проекта, **~/control-review**, запустите **playbook.yml** playbook. Playbook должен выполняться без ошибок и инициировать выполнение задачи обработчика.
```console
[student@workstation control-review]$ ansible-playbook playbook.yml

PLAY [Playbook Control Lab] **************************************************

TASK [Gathering Facts] *******************************************************
ok: [serverb.lab.example.com]

TASK [Show Failed System Requirements Message] *******************************
skipping: [serverb.lab.example.com]

TASK [Ensure required packages are present] **********************************
changed: [serverb.lab.example.com]

TASK [Ensure services are started and enabled] *******************************
changed: [serverb.lab.example.com] => (item=httpd)
ok: [serverb.lab.example.com] => (item=firewalld)

TASK [Create SSL cert directory] *********************************************
changed: [serverb.lab.example.com]

TASK [Copy Config Files] *****************************************************
changed: [serverb.lab.example.com] => (item={'src': 'server.key', 'dest': '/etc/httpd/conf.d/ssl'})
changed: [serverb.lab.example.com] => (item={'src': 'server.crt', 'dest': '/etc/httpd/conf.d/ssl'})
changed: [serverb.lab.example.com] => (item={'src': 'ssl.conf', 'dest': '/etc/httpd/conf.d'})
changed: [serverb.lab.example.com] => (item={'src': 'index.html', 'dest': '/var/www/html'})

TASK [ensure web server ports are open] **************************************
changed: [serverb.lab.example.com] => (item=http)
changed: [serverb.lab.example.com] => (item=https)

RUNNING HANDLER [restart web service] ****************************************
changed: [serverb.lab.example.com]

PLAY RECAP *******************************************************************
serverb.lab.example.com : ok=7 changed=6 unreachable=0 failed=0
```
9. Убедитесь, что веб-сервер теперь отвечает на запросы HTTPS, используя самозаверяющий пользовательский сертификат для шифрования соединения. Ответ веб-сервера должен соответствовать строке
**Configured for both HTTP and HTTPS.**
```console
[student@workstation control-review]$ curl -k -vvv https://serverb.lab.example.com
* About to connect() to serverb.lab.example.com port 443 (#0)
* Trying 172.25.250.11...
* Connected to serverb.lab.example.com (172.25.250.11) port 443 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
* skipping SSL peer certificate verification
* SSL connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
* Server certificate:
...output omitted...
* start date: Nov 13 15:52:18 2018 GMT
* expire date: Aug 09 15:52:18 2021 GMT
* common name: serverb.lab.example.com
...output omitted...
< Accept-Ranges: bytes
< Content-Length: 36
< Content-Type: text/html; charset=UTF-8
<
Configured for both HTTP and HTTPS.
* Connection #0 to host serverb.lab.example.com left intact
```