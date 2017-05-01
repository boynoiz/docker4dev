# Docker4Dev

This project are still under experimental. There's a problem about pass through env to Dockerfile and I working on it.

---

> Inspiration from [Dockerized by kasperisager](https://github.com/kasperisager/php-dockerized) PHP development stack: Nginx, MariaDB, MongoDB, PHP-FPM, HHVM, Memcached, Redis, Elasticsearch and RabbitMQ

---

Docker Web Server Stack for Laravel Framework and Web Development on Windows 10

## What's inside

* [Nginx](http://nginx.org/)
* [MySQL](http://www.mysql.org/)
* [MongoDB](http://www.mongodb.org/)
* [PHP 7.1](http://php-fpm.org/)

> apcu bcmath bz2 cgi cli common curl fpm gmagick gd geoip intl igbinary imagick json mbstring mcrypt memcached mongodb msgpack mysql odbc opcache pear pspell readline recode redis sqlite3 sqlsrv tidy xml uuid xdebug yaml zip

* [Memcached](http://memcached.org/)
* [Redis](http://redis.io/)
* [Elasticsearch](http://www.elasticsearch.org/)
* [RabbitMQ](https://www.rabbitmq.com/)

## Requirements

* [Docker Engine](https://docs.docker.com/docker-for-windows/install/)
* [Windows Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)

## Configuration

Change variable in .env file
```
APP_PROJECT_NAME=app
APP_SITE_URL=yoursitename.dev

APP_SSH_USER_NAME=docker
APP_SSH_USER_PASSWORD=docker

APP_MYSQL_VERSION=5.7
APP_MYSQL_ROOT_PASSWORD=r00tp@$$w0rd
APP_MYSQL_DATABASE=docker4dev
APP_MYSQL_USER=docker4dev
APP_MYSQL_PASSWORD=docker4dev
```

## Running

Set up a Docker and then run:

```sh
$ docker-compose up
```

After build finished then you can login to workspace container via ssh.

```sh
HOST = 127.0.0.1 
PORT = 2222
USER = docker
PASSWORD = docker
```

Because we working on root permission so you just run command ```sudo passwd``` to change root password and run ``` su``` and type your root password that you changed.

Your workspace is ```webroot``` on Windows host and ``` /var/www/APP_PROJECT_NAME ``` on Docker container.

That's it!

## License

Copyright &copy; 2017 [Pathompong Pechkongtong](https://github.com/boynoiz). Licensed under the terms of the [MIT license](LICENSE.md).