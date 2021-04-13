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
