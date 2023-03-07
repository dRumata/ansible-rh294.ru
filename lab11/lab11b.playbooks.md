#Creating Playbooks

Создайте статический файл инвентаризации в **review-playbooks/inventory** с **serverc.lab.example.com** в группе **ftpclients**, и **serverb.lab.example.com** и **serverd.lab.example.com** в группе **ftpservers**. Создайте файл **review-playbooks/ansible.cfg**, который настраивает ваш Ansible-проект для использования этого инвентаризационного файла. Возможно, вам будет полезно заглянуть в системный файл **/etc/ansible/ansible.cfg** для получения справки по синтаксису.

Настройте свой проект Ansible для подключения к узлам в inventory с использованием удаленного пользователя,
**devops** и метода **sudo** для повышения привилегий. У вас есть SSH-ключи для входа в систему, поскольку
**devops** уже настроен. Пользователю **devops** не нужен пароль для
повышения привилегий с помощью sudo.
Создайте сценарий (playbook) с именем **ftpclients.yml** в каталоге **review-playbooks**, который содержит операцию (play), ориентированную на хосты в инвентарной группе ftpclients. Playbook должен убедиться, что установлен пакет lftp.

Создайте второй сценарий с именем ansible-vsftpd.yml в каталоге review-playbooks, который содержит операцию, ориентированную на хосты в инвентарной группе ftpservers. Он должен соответствовать следующим требованиям:

- У вас есть файл конфигурации для vsftpd, созданный на основе шаблона Jinja2. Создайте каталог для шаблонов review-playbooks/templates и скопируйте в него предоставленный файл vsftpd.conf.j2. Создайте каталог review-playbooks/vars. Скопируйте предоставленный файл defaults-template.yml, который содержит настройки переменных по умолчанию, используемые для завершения этого шаблона при его развертывании, в каталог review-playbooks/vars
- Создайте файл переменных review-playbooks/vars/vars.yml, который задает три переменные:
| Variable | Value |
|:--|:--|
| vsftpd_package | vsftpd |
| vsftpd_service | vsftpd |
| sftpd_config_file | /etc/vsftpd/vsftpd.conf |