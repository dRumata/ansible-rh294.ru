1. Скопировать id_rsa ключ от пользователя sa на машине ws в каталог ~/.ssh/
2. В ../.ssh/config добавить

```
Host 172.16.195.*
  IdentityFile ~/.ssh/ansible270125_rsa
  UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
```

> Здесь 172.16.195.* - адреса всех ws; ansible270125_rsa имя скопированого id_rsa

3. Заполнить inventory адресами машин ws слушателей
4. 3апустить prep.yml