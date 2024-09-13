#!/usr/bin/env python3

import PySimpleGUI as sg
import subprocess


sg.theme('DarkBlue13')
sg.set_options(font=("Cousine", 16))

layout = [[sg.Text('Введите параметры для ввода клиента в домен')],
          [sg.Text('Имя хоста:', size=(16, 1)), sg.Input()],
          [sg.Text('Имя домена:', size=(16, 1)), sg.Input("ald.test")],
          [sg.Text('IP-адрес:', size=(16, 1)), sg.Input()],
          [sg.Text('Сетевой префикс:', size=(16, 1)), sg.Input("24")],
          [sg.Text('Шлюз:', size=(16, 1)), sg.Input()],
          [sg.Text('DNS-сервер:', size=(16, 1)), sg.Input()],
          [sg.Text('Пароль admin:', size=(16, 1)), sg.Input("P@ssw0rd")],
          [sg.Submit('Отправить'), sg.Cancel('Отменить')]]

window = sg.Window('Параметры клиента', layout)

while True:
    event, values = window.read()

    if event in (sg.WINDOW_CLOSED, 'Отменить'):
        exit(1)

    if event == 'Отправить':
        if values[0] == "" or values[2] == "" or values[4] == "" or values[5] == "": 
            sg.Popup('Поля для ввода не могут быть пустыми')
        else:
            break

bash_script = '/home/sa/client.sh'
subprocess.call([bash_script, values[0], values[1], values[2], values[3], values[5], values[4], values[6]])

