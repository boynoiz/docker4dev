# Docker Web Server Stack for Laravel Framework and Web Development

---

> Inspiration from [Dockerized by kasperisager](https://github.com/kasperisager/php-dockerized) PHP development stack: Nginx, MariaDB, MongoDB, PHP-FPM, HHVM, Memcached, Redis, Elasticsearch and RabbitMQ

---

I made Docker4Dev for Laravel Framework and php web development on Windows 10

## What's inside

* [Nginx](http://nginx.org/)
* [MySQL 5.7](http://www.mysql.org/)
* [MongoDB](http://www.mongodb.org/)
* [PHP-FPM 7.1](http://php-fpm.org/)
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
APP_NAME=app
SITE_NAME=yoursitename.dev
SSH_USER_NAME=docker
SSH_USER_PASSWORD=docker
MYSQL_VERSION=5.7
MYSQL_ROOT_PASSWORD=r00tp@$$w0rd
MYSQL_DATABASE=docker4dev
MYSQL_USER=docker4dev
MYSQL_PASSWORD=docker4dev
```

## Running

Set up a Docker and then run:

```sh
$ docker-compose up
```

After build finished then you can login to workspace container via ssh.

Because we working on root permission so you just run command ```sudo passwd``` to change root password and run ``` su``` and type your root password that you changed.

Your workspace will store in ```webroot``` directory.

That's it!

## License

Copyright &copy; 2014-2016 [Kasper Kronborg Isager](http://github.com/kasperisager). Licensed under the terms of the [MIT license](LICENSE.md).

Copyright &copy; 2017 [Pathompong Pechkongtong](https://github.com/boynoiz). Licensed under the terms of the [MIT license](LICENSE.md).
