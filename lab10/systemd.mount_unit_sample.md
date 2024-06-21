Для создания и управления `systemd` монтированием (unit file для монтирования) в Ansible используется модуль `ansible.builtin.systemd`. Этот модуль позволяет управлять различными типами unit-файлов, включая монтирование (`.mount` units).

Пример плейбука, который создает и активирует `systemd.mount` unit:

```yaml
- name: Ensure systemd mount unit is present
  hosts: all
  tasks:
    - name: Create systemd mount unit file
      ansible.builtin.copy:
        dest: /etc/systemd/system/mnt-data.mount
        content: |
          [Unit]
          Description=Mount Data Directory
          After=network.target

          [Mount]
          What=/dev/sdb1
          Where=/mnt/data
          Type=ext4
          Options=defaults

          [Install]
          WantedBy=multi-user.target
      notify:
        - Reload systemd
        - Enable mnt-data.mount
        - Start mnt-data.mount

  handlers:
    - name: Reload systemd
      ansible.builtin.command:
        cmd: systemctl daemon-reload
      become: yes

    - name: Enable mnt-data.mount
      ansible.builtin.systemd:
        name: mnt-data.mount
        enabled: yes
      become: yes

    - name: Start mnt-data.mount
      ansible.builtin.systemd:
        name: mnt-data.mount
        state: started
      become: yes
```

Разбор плейбука:
- **Создание unit-файла**: Задача с модулем `ansible.builtin.copy` создает unit-файл `/etc/systemd/system/mnt-data.mount`.
- **Обработчики (handlers)**: После создания unit-файла вызываются обработчики для перезагрузки конфигурации systemd, включения и запуска нового монтирования.
  - `Reload systemd`: Перезагружает демона systemd для применения новых конфигураций.
  - `Enable mnt-data.mount`: Включает монтирование, чтобы оно запускалось автоматически при загрузке системы.
  - `Start mnt-data.mount`: Запускает монтирование.

Эти шаги обеспечивают правильное создание, включение и запуск systemd unit-файла для монтирования.