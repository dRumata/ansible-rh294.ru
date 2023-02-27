LAB 4. Managing Variables and Facts. Solution.

1. В рабочем каталоге создайте **playbook.yml** playbook и добавьте группу узлов веб-сервера в качестве управляемого узла. Определите следующие переменные воспроизведения:

| Variable | Values |
|:--|:--|
| firewall_pkg | firewalld |
| firewall_svc | firewalld |
| web_pkg | httpd |
| web_svc | httpd |
| ssl_pkg | mod_ssl |
| httpdconf_src | files/httpd.conf |
| httpdconf_dest | /etc/httpd/conf/httpd.conf |
| htaccess_src | files/.htaccess |
| secrets_dir | /etc/httpd/secrets |
| secrets_src | files/htpasswd |
| secrets_dest | "{{ secrets_dir }}/htpasswd" |
| web_root | /var/www/html |

  1.1. Перейдите в рабочий каталог **/home/student/data-review**.
```console
[student@workstation ~]$ cd ~/data-review
[student@workstation data-review]$
```  
  1.2 Создайте файл **playbook.yml** playbook и отредактируйте его в текстовом редакторе. Начало файла должно выглядеть следующим образом:
```yaml
---
- name: install and configure webserver with basic auth
  hosts: webserver
  vars:
    firewall_pkg: firewalld
    firewall_svc: firewalld
    web_pkg: httpd
    web_svc: httpd
    ssl_pkg: mod_ssl
    httpdconf_src: files/httpd.conf
    httpdconf_dest: /etc/httpd/conf/httpd.conf
    htaccess_src: files/.htaccess
    secrets_dir: /etc/httpd/secrets
    secrets_src: files/htpasswd
    secrets_dest: "{{ secrets_dir }}/htpasswd"
    web_root: /var/www/html
```  
2. Добавьте раздел задач в игру. Напишите задачу, которая гарантирует установку последней версии необходимых пакетов. Эти пакеты определяются переменными **firewall_pkg**, **web_pkg** и **ssl_pkg**.

2.1. Определите начало раздела **tasks**, добавив в playbook следующую строку:
```yaml
  tasks:
```
2.2. Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **yum** для установки необходимых пакетов.
```yaml
    - name: latest version of necessary packages installed
      yum:
        name:
          - "{{ firewall_pkg }}"
          - "{{ web_pkg }}"
          - "{{ ssl_pkg }}"
        state: latest
```

3. Добавьте в playbook вторую задачу, которая гарантирует, что файл, указанный переменной **httpdconf_src**, был скопирован (с помощью модуля **copy**) в местоположение, указанное переменной **httpdconf_dest** на управляемом хосте. Файл должен принадлежать пользователю **root** и группе **root**. Также установите **0644** в качестве прав доступа к файлу.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **copy** для копирования
содержимого файла, определенного переменной **httpdconf_src**, в местоположение, указанное переменной **httpdconf_dest**.
```yaml
    - name: configure web service
      copy:
        src: "{{ httpdconf_src }}"
        dest: "{{ httpdconf_dest }}"
        owner: root
        group: root
        mode: 0644
```
4. Добавьте третью задачу, которая использует модуль **file** для создания каталога, указанного переменной **secrets_dir** на управляемом хосте. В этом каталоге хранятся файлы паролей, используемые для базовой аутентификации веб-служб. Файл должен принадлежать пользователю **apache** и группе **apache**. Установите **0500** в качестве прав доступа к файлам.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **file** для создания
каталога, определенного переменной **secrets_dir**.
```yaml
    - name: secrets directory exists
      file:
        path: "{{ secrets_dir }}"
        state: directory
        owner: apache
        group: apache
        mode: 0500
```

5. Добавьте четвертую задачу, которая использует модуль **copy** для размещения файла **htpasswd**, используемого для базовой аутентификации веб-пользователей. Источник должен быть определен переменной **secrets_src**. Пункт назначения должен быть определен переменной **secrets_dest**. Файл должен принадлежать пользователю и группе **apache**. Установите **0400** в качестве прав доступа к файлам.
```yaml
    - name: htpasswd file exists
      copy:
        src: "{{ secrets_src }}"
        dest: "{{ secrets_dest }}"
        owner: apache
        group: apache
        mode: 0400
```

6. Добавьте пятую задачу, которая использует модуль **copy** для создания файла **.htaccess** в корневом каталоге документа веб-сервера. Скопируйте файл, указанный переменной **htaccess_src**, в **{{ web_root }}/.htaccess**. Файл должен принадлежать пользователю **apache** и группе **apache**. Установите **0400** в качестве прав доступа к файлам.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **copy** для создания файла **.htaccess**, используя файл, определенный переменной **htaccess_src**.
```yaml
    - name: .htaccess file installed in docroot
      copy:
        src: "{{ htaccess_src }}"
        dest: "{{ web_root }}/.htaccess"
        owner: apache
        group: apache
        mode: 0400
```
7. Добавьте шестую задачу, которая использует модуль **copy** для создания файла веб-содержимого **index.html** в каталоге, указанном переменной **web_root**. Файл должен содержать сообщение “HOSTNAME (IPADDRESS) было настроено Ansible.”, где **HOSTNAME** - это полное имя хоста управляемого хоста, а **IPADDRESS** - это его IPv4-адрес. Используйте опцию **content** в модуле **copy**, чтобы указать содержимое файла, и Ansible facts, чтобы указать имя хоста и IP-адрес.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **copy** для создания **index.html** файл в каталоге, определенном переменной **web_root**. Заполните файл содержимым, указанным с помощью **ansible_facts['fqdn']** и **ansible_facts['default_ipv4']['address']** Ansible facts получены с управляемого хоста.
```yaml
    - name: create index.html
      copy:
        content: "{{ ansible_facts['fqdn'] }} ({{ ansible_facts['default_ipv4']['address'] }}) has been customized by Ansible.\n"
        dest: "{{ web_root }}/index.html"
```
8. Добавьте седьмую задачу, которая использует модуль **service** для включения и запуска службы брандмауэра на управляемом хосте.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **service** для включения и запуска службы брандмауэра.
```yaml
    - name: firewall service enabled and started
      service:
        name: "{{ firewall_svc }}"
        state: started
        enabled: true
```
9.  Добавьте восьмую задачу, которая использует модуль **firewalld**, чтобы разрешить службу **https**, необходимую пользователям для доступа к веб-службам на управляемом хосте. Это изменение брандмауэра должно быть постоянным и должно произойти немедленно.
Добавьте следующие строки в playbook, чтобы определить задачу, которая использует модуль **firewalld** для открытия HTTPS-порта для веб-службы.
```yaml
    - name: open the port for the web server
      firewalld:
        service: https
        state: enabled
        immediate: true
        permanent: true
```
10. Добавьте заключительную задачу, которая использует модуль **service** для включения и запуска веб-службы на управляемом хосте, чтобы все изменения конфигурации вступили в силу. Имя веб-службы определяется переменной **web_svc**.
```yaml
    - name: web service enabled and started
      service:
        name: "{{ web_svc }}"
        state: started
        enabled: true
```
11. Определите второй сценарий, указывающий на **localhost**, который будет тестировать аутентификацию на веб-сервере. Для этого не требуется повышение привилегий. Определите переменную с именем **web_user** со значением **guest**.
11.1. Добавьте следующую строку, чтобы определить начало второго сценария. Обратите внимание, что отступа нет.
```yaml
- name: Test web server with basic auth
```
11.2. Добавьте следующую строку, чтобы указать, что сценарий применяется к управляемому хосту **localhost**.
```yaml
  hosts: localhost
```
11.3. Добавьте следующую строку, чтобы отключить повышение привилегий.
```yaml
  become: no
```
11.4. Добавьте следующие строки для определения списка переменных и переменной **web_user**.
```yaml
  vars:
    web_user: guest
```

12. Добавьте в play директиву, которая добавляет дополнительные переменные из файла переменных с именем **vars/secret.yml**. Этот файл содержит переменную с именем **web_pass**, которая задает пароль для веб-пользователя. Вы создадите этот файл позже. Определите начало списка задач.
12.1. Используя ключевое слово **vars_files**, добавьте следующие строки в playbook, чтобы проинструктировать Возможность использовать переменные, найденные в файле переменных **vars/secret.yml**.
```yaml
  vars_files:
    vars/secret.yml
```
12.2. Добавьте следующую строку, чтобы определить начало списка задач.
```yaml
  tasks:
```

13. Добавьте два задания ко второму сценарию. Первый использует модуль **uri** для запроса содержимого с **https://serverb.lab.example.com** используя базовую аутентификацию. Используйте переменные **web_user** и **web_pass** для аутентификации на веб-сервере. Обратите внимание, что сертификат, представленный **serverb**, не будет надежным, поэтому вам нужно будет избегать проверки сертификата. Задача должна проверить возвращаемый код состояния HTTP, равный **200**. Настройте задачу таким образом, чтобы возвращаемое содержимое помещалось в переменную результатов задачи. Зарегистрируйте результат задачи в переменной. Вторая задача использует модуль **debug** для печати содержимого, возвращенного с веб-сервера.
13.1. Добавьте следующие строки, чтобы создать задачу для проверки веб-службы с узла управления. Обязательно сделайте отступ в первой строке с четырьмя пробелами.
```yaml
    - name: connect to web server with basic auth
      uri:
        url: https://serverb.lab.example.com
        validate_certs: no
        force_basic_auth: yes
        user: "{{ web_user }}"
        password: "{{ web_pass }}"
        return_content: yes
        status_code: 200
      register: auth_test
```
13.2. Создайте вторую задачу с помощью модуля **debug**. Содержимое, возвращаемое с веб-сервера, добавляется к зарегистрированной переменной в качестве ключевого содержимого.
```yaml
    - debug:
        var: auth_test.content
```
13.3. Заполненный playbook должен выглядеть следующим образом: смотрите файл в директории лабораторной работы.

14. Создайте файл, зашифрованный с помощью Ansible Vault, с именем **vars/secret.yml**. Используйте пароль **redhat** для его шифрования. Он должен установить для переменной **web_pass** значение **redhat**, которое будет паролем веб-пользователя.
14.1. Создайте подкаталог с именем **vars** в рабочем каталоге.
```console
[student@workstation data-review]$ mkdir vars
```
14.2. Создайте зашифрованный файл переменных, **vars/secret.yml**, используя Ansible Vault. Установите пароль **redhat** для зашифрованного файла.
```console
[student@workstation data-review]$ ansible-vault create vars/secret.yml
New Vault password: redhat
Confirm New Vault password: redhat
```
14.3. Добавьте в файл следующее определение переменной.
```yaml
web_pass: redhat
```
15. Запустите **playbook.yml** playbook. Убедитесь, что содержимое успешно возвращено с веб-сервера и что оно соответствует тому, что было настроено в предыдущей задаче.
15.1. Перед запуском playbook убедитесь в правильности его синтаксиса, запустив `ansibleplaybook --syntax-check` Используйте **--ask-vault-pass**, чтобы получить запрос на ввод пароля хранилища. Введите redhat, когда вам будет предложено ввести пароль. Если он сообщает о каких-либо ошибках, исправьте их, прежде чем переходить к следующему шагу. Вы должны увидеть вывод, подобный следующему:
```console
[student@workstation data-review]$ ansible-playbook --syntax-check --ask-vault-pass playbook.yml
Vault password: redhat
playbook: playbook.yml
```
15.2. Используя команду **ansible-playbook**, запустите playbook с параметром **--ask-vaultpass**. Введите **redhat**, когда вам будет предложено ввести пароль.
```console
[student@workstation data-review]$ ansible-playbook playbook.yml --ask-vault-pass
Vault password: redhat
PLAY [Install and configure webserver with basic auth] *********************

...output omitted...

TASK [connect to web server with basic auth] ***********************************
ok: [localhost]

TASK [debug] *******************************************************************
ok: [localhost] => {
    "auth_test.content": "serverb.lab.example.com (172.25.250.11) has been customized by Ansible.\n"
}

PLAY RECAP *********************************************************************
localhost : ok=3 changed=0 unreachable=0 failed=0
serverb.lab.example.com : ok=10 changed=8 unreachable=0 failed=0
```