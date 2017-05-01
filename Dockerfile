################################################################################
# Base image
################################################################################

FROM nginx:latest

ARG PROJECT_NAME
ARG SITE_URL
ARG SSH_USER_NAME
ARG SSH_USER_PASSWORD

ENV PROJECT_NAME ${PROJECT_NAME}
ENV SITE_URL ${SITE_URL}
ENV SSH_USER_NAME ${SSH_USER_NAME}
ENV SSH_USER_PASSWORD ${SSH_USER_PASSWORD}

RUN usermod -u 1000 www-data

# Copy our nginx config

RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
mkdir -p /etc/nginx/sites-enabled/ && \
mkdir -p /etc/nginx/ssl/private/ && \
mkdir -p /etc/nginx/ssl/certs/ && \
rm -Rf /var/www/* && \
mkdir -p /var/www/html/ && \
mkdir -p /var/www/tmp && \
chown -R www-data:www-data /var/www/ && \
chmod a+x /var/www/

ADD conf/nginx/sites-available/default.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx/sites-available/workspace.conf /etc/nginx/sites-available/${PROJECT_NAME}.conf
RUN sed -i \
        -e "s/yoursitename.dev/${SITE_URL}/g" /etc/nginx/sites-available/${PROJECT_NAME}.conf

RUN ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

################################################################################
# Build instructions
################################################################################

# Add custom repository

RUN rm /etc/apt/sources.list
ADD conf/apt/sources.list /etc/apt/sources.list

RUN echo 'Acquire::Queue-Mode "host";' > /etc/apt/apt.conf

RUN apt-get update && \
  apt-get clean && apt-get autoclean && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq \
  build-essential \
  python-dev \
  sudo \
  curl \
  wget \
  apt-transport-https \
  lsb-release \
  ca-certificates \
  dialog \
  apt-utils

# Add all dependencies's repository

RUN wget -O- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub |  apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo 'deb https://deb.nodesource.com/node_7.x jessie main' > /etc/apt/sources.list.d/nodesource.list

# Start build

RUN apt-get clean && apt-get autoclean && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq \
  htop \
  python-pip \
  openssh-server \
  git \
  nano \
  vim \
  locales \
  supervisor \
  automake \
  libtool \
  libssl-dev \
  libgss3 \
  libmagickwand-dev \
  openssl

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq \
  php7.1 \
  php7.1-dev \
  php7.1-bcmath \
  php7.1-bz2 \
  php7.1-cgi \
  php7.1-cli \
  php7.1-common \
  php7.1-curl \
  php7.1-fpm \
  php7.1-gd \
  php7.1-intl \
  php7.1-json \
  php7.1-mbstring \
  php7.1-mcrypt \
  php7.1-mysql \
  php7.1-odbc \
  php7.1-opcache \
  php7.1-pspell \
  php7.1-readline \
  php7.1-recode \
  php7.1-sqlite3 \
  php7.1-tidy \
  php7.1-xml \
  php7.1-zip \
  php-apcu \
  php-geoip \
  php-gmagick \
  php-igbinary \
  php-imagick \
  php-memcached \
  php-mongodb \
  php-msgpack \
  php-pear \
  php-redis \
  php-uuid \
  php-xdebug \
  php-yaml

# Tweak default php-fpm config

RUN sed -i \
        -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" \
        -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" \
        -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" \
        -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" \
        -e "s/;date.timezone =.*/date.timezone = Asia\/Bangkok/g" \
        /etc/php/7.1/fpm/php.ini && \
    sed -i \
        -e "s/;daemonize\s*=\s*yes/daemonize = no/g" \
        /etc/php/7.1/fpm/php-fpm.conf && \
    sed -i \
        -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 4/pm.max_children = 4/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
        -e "s/pm.max_requests = 500/pm.max_requests = 200/g" \
        -e "s/user = nobody/user = www-data/g" \
        -e "s/group = nobody/group = www-data/g" \
        -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
        -e "s/;listen.owner = nobody/listen.owner = www-data/g" \
        -e "s/;listen.group = nobody/listen.group = www-data/g" \
        -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php7.1-fpm.sock/g" \
        -e "s/listen = \/run\/php\/php7.1-fpm.sock/listen = \/var\/run\/php7.1-fpm.sock/g" \
        -e "s/^;clear_env = no$/clear_env = no/g" \
        /etc/php/7.1/fpm/pool.d/www.conf

ADD conf/php-fpm/xdebug.ini /etc/php/7.1/mods-available/
ADD conf/php-fpm/pool.d/www.conf /etc/php/7.1/fpm/pool.d/${PROJECT_NAME}.conf

RUN sed -i \
        -e "s/yoursitename.dev/${SITE_URL}/g" /etc/php/7.1/fpm/pool.d/${PROJECT_NAME}.conf

# Add PHP MSSQL Driver Extension

RUN curl ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.1.tar.gz --create-dirs -o /usr/src/phpmssql/unixODBC-2.3.1.tar.gz
RUN tar -zxf /usr/src/phpmssql/unixODBC-2.3.1.tar.gz -C /usr/src/phpmssql/
RUN sudo -i export CPPFLAGS="-DSIZEOF_LONG_INT=8"
RUN echo "Configuring the unixODBC 2.3.1 Driver Manager"
RUN cd /usr/src/phpmssql/unixODBC-2.3.1 && ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --disable-gui --disable-drivers --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE
RUN echo "Building and Installing the unixODBC 2.3.1 Driver Manager"
RUN cd /usr/src/phpmssql/unixODBC-2.3.1 && sudo make && sudo make install
RUN echo "Downloading the Microsoft ODBC Driver 13 for SQL Server"
RUN curl "https://meetsstorenew.blob.core.windows.net/contianerhd/Ubuntu%2013.0%20Tar/msodbcsql-13.0.0.0.tar.gz?st=2016-10-18T17%3A29%3A00Z&se=2022-10-19T17%3A29%3A00Z&sp=rl&sv=2015-04-05&sr=b&sig=cDwPfrouVeIQf0vi%2BnKt%2BzX8Z8caIYvRCmicDL5oknY%3D" --create-dirs -o /usr/src/phpmssql/msodbcsql-13.0.0.0.tar.gz
RUN tar -zxf /usr/src/phpmssql/msodbcsql-13.0.0.0.tar.gz -C /usr/src/phpmssql/
RUN sudo ldd /usr/src/phpmssql/msodbcsql-13.0.0.0/lib64/libmsodbcsql-13.0.so.0.0
RUN sudo echo "/usr/lib64" >> /etc/ld.so.conf
RUN sudo ldconfig
RUN echo "Installing the Microsoft ODBC Driver 13 for SQL Server"
RUN chmod +x /usr/src/phpmssql/msodbcsql-13.0.0.0/install.sh
RUN cd /usr/src/phpmssql/msodbcsql-13.0.0.0 && ./install.sh install --force --accept-license
RUN pecl install sqlsrv-4.1.8preview && pecl install pdo_sqlsrv-4.1.8preview
RUN touch /etc/php/7.1/mods-available/sqlsrv.ini && echo "extension=sqlsrv.so" > /etc/php/7.1/mods-available/sqlsrv.ini
RUN touch /etc/php/7.1/mods-available/pdo_sqlsrv.ini && echo "extension=pdo_sqlsrv.so" > /etc/php/7.1/mods-available/pdo_sqlsrv.ini
RUN phpenmod pdo_sqlsrv sqlsrv
RUN echo "Cleaning up"
RUN cd / && rm -rf /usr/src/phpmssql


# Get Composer

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
composer global require phpunit/phpunit phpunit/dbunit phing/phing sebastian/phpcpd phploc/phploc phpmd/phpmd squizlabs/php_codesniffer

# Install ChromeDriver for Laravel Dusk testing

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y google-chrome-stable
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xvfb gtk2-engines-pixbuf
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y imagemagick x11-apps

# Make sure that Xvfb starts everytime the box/vm is booted:
RUN echo "Starting X virtual framebuffer (Xvfb) in background..."
RUN Xvfb -ac :99 -screen 0 1280x1024x16 &
RUN export DISPLAY=:99

# Config timezone and Localization

RUN echo Asia/Bangkok > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN echo 'en_US ISO-8859-1\n\
en_US.ISO-8859-15 ISO-8859-15\n\
en_US.UTF-8 UTF-8\n\
th_TH.UTF-8 UTF-8\n'\
>> /etc/locale.gen &&  \
/usr/sbin/locale-gen

# Start php-fpm service

RUN /etc/init.d/php7.1-fpm start

# Installation Redis-CLI

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq redis-tools

# Installation Nodejs

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq nodejs

# Installation yarn

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -yqq yarn

# Add supervisor configuration files

ADD conf/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add user for ssh
RUN adduser --quiet --disabled-password --shell /bin/bash --home /home/${SSH_USER_NAME} --gecos "Docker ToolBox" ${SSH_USER_NAME} && \
echo "${SSH_USER_NAME}:${SSH_USER_PASSWORD}" | chpasswd &&\
echo "${SSH_USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Config openssd-server 

RUN mkdir -p /var/run/sshd

# Add Bash-it
RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git /root/.bash_it && ~/.bash_it/install.sh --silent
RUN sed -i \
  -e "s/export BASH_IT_THEME='bobby'/export BASH_IT_THEME='powerline'/g" \
  /root/.bashrc



################################################################################
# Volumes
################################################################################

VOLUME ["/var/www"]

################################################################################
# Ports
################################################################################

EXPOSE 22 80 443 9000

################################################################################
# Entrypoint
################################################################################
CMD []
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
