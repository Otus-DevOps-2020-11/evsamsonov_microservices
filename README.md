# evsamsonov_microservices
evsamsonov microservices repository

## Docker 2

Что сделано?

- Установлен docker-machine. Docker и docker-compose уже были в системе
- Создана ВМ в Yandex Cloud
- Создана докер хост система на ВМ в YC
- Создан Docker образ с Reddit App
- Образ запушен в Docker hub

## Docker 3

Что сделано?

- Создана ВМ в Yandex Cloud с докер хост системой
- Добавлены каталоги из архива reddit-microservices
- Созданы Dockerfile для микросервисов post-py, comment, ui
- Создана docker bridge-сеть, созданы и запущены контейнеры микросервисов
- Проверена работоспособность приложения
- Улучшен образ микросервиса ui
- Создан docker volume для mongodb  

## Docker 4

Что сделано?

- Создана ВМ в Yandex Cloud с докер хост системой (старая была утеряна)
- Запущен контейнер с joffotron/docker-net-tools и изучен вывод ifconfig
- Запущен контейнер с joffotron/docker-net-tools в сетевом пространстве docker-хоста
- Посмотрел, как меняется список namespaces при запуске с разными драйверами сети
- Запустил проект reddit с использованием bridge сети
- Запустил проект reddit с использованием нескольких отдельных сетей
- Запустил проект reddit с использованием параметризированного docker-compose с 2 сетями

**Кроме localhost в выводе ifconfig был eth0 и можно было контактировать с внешним миром**
```bash
evgeny@MacBook-Air-Evgeny evsamsonov_microservices (docker-4) $ docker run --rm -it joffotron/docker-net-tools
Unable to find image 'joffotron/docker-net-tools:latest' locally
latest: Pulling from joffotron/docker-net-tools
3690ec4760f9: Pull complete 
0905b79e95dc: Pull complete 
Digest: sha256:5752abdc4351a75e9daec681c1a6babfec03b317b273fc56f953592e6218d5b5
Status: Downloaded newer image for joffotron/docker-net-tools:latest
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:02  
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1032 (1.0 KiB)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

**В сетевом пространсве docker хоста есть еще сеть docker0**
```bash
4: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:60:13:cf:52 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:60ff:fe13:cf52/64 scope link 
       valid_lft forever preferred_lft forever
```

**Каков результат? Что выдал docker ps? Как думаете почему?**
Запущен только 1 контейнер с nginx. Второй появляется в списке, но почти сразу пропадает. Нельзя запустить несколько одинаковых контейнеров в режиме хоста, потому что они не смогут поделить порты)?


**Просмотр сетевого стека Linux**
```bash
yc-user@docker-host:~$ sudo docker network ls
NETWORK ID     NAME        DRIVER    SCOPE
1de014a2008f   back_net    bridge    local
d5cb9079a24e   bridge      bridge    local
aa840450ea29   front_net   bridge    local
68ae4cdc5824   host        host      local
fd04fb993de7   none        null      local
474ed1452fdb   reddit      bridge    local
yc-user@docker-host:~$ ifconfig | grep br
br-1de014a2008f: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.1  netmask 255.255.255.0  broadcast 10.0.2.255
br-474ed1452fdb: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
br-aa840450ea29: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.1.1  netmask 255.255.255.0  broadcast 10.0.1.255
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet 10.130.0.13  netmask 255.255.255.0  broadcast 10.130.0.255

yc-user@docker-host:~$ brctl show br-1de014a2008f
bridge name     bridge id               STP enabled     interfaces
br-1de014a2008f         8000.024284360ca3       no              veth16d0b22
                                                        vethabadd70
                                                        vethfb50af9
yc-user@docker-host:~$ sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0           
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0           
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0           
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0           
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination         
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
yc-user@docker-host:~$ ps ax | grep docker-proxy
23804 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
23811 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip :: -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
26616 pts/0    S+     0:00 grep --color=auto docker-proxy
```

**Узнайте как образуется базовое имя проекта. Можно ли его задать? Если можно то как?**
Префикс имени это название каталога. Чтобы его переопределить, нужно определить переменную окружения COMPOSE_PROJECT_NAME

## Gitlab CI 1

Что сделано?

- Создана ВМ в Yandex Cloud с докер хост системой
- Установлен Gitlab на ВМ
- Добавлен gitlab ci файл
- Запущен gitlab раннер
- Добавлен проект Reddit
- Добавлены тесты в pipeline
- Добавлены окружения dev, beta, production
- Добавлено динамическое создание окружений на каждую запушенную ветку

## Monitoring 1

Что сделано?

- Создан образ c prometheus c конфигом на мониторинг reddit app
- Запуск прометея добавлен в docker-compose reddit app
- Добавлен запуск node exprter в docker-compose reddit app
- Требуемые для reddit app образы запущены в Docker hub https://hub.docker.com/u/evsamsonov

## Monitoring 2

Что сделано?

- Добавлен отдельный docker-compose файл для мониторинга
- Добавлен cAdvisor для мониоторинга docker контейнеров
- Добавлена Grafana и настроена на получение данных с прометея
- В Grafana импортирован дашборд Docker and system monitoring 
- Создан дашборд UI_Service_Monitoring
- Создан дашборд Business_Logic_Monitoring 
- Добавлен alertmanager, настроена интеграция с Prometheous 
- Добавлен алерт в slack на падение сервиса 
- Образы запушены в Docker hub https://hub.docker.com/u/evsamsonov

## Logging 1

Что сделано?

- Обновлена версия кода reddit app
- Пересобраны образы reddit app
- Создана ВМ и docker machine на ней
- Описан docker compose EFK стэка
- Создан Docker образ для Fluentd
- Добавлены фильтры логов для reddit app в Fluentd
- Добавлен трейсер Zipkin
