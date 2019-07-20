FROM ubuntu:disco

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install wget tar apache2 libapache2-mod-php php-xml php-mbstring

RUN a2enmod rewrite

RUN cd /var/www && \
    wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz && \
    tar xvf dokuwiki-stable.tgz && \
    mv dokuwiki-*/ dokuwiki && \
    chown -R www-data:www-data /var/www/dokuwiki && \
    rm -rf dokuwiki/data && \
    rm -rf dokuwiki/conf && \
    rm -rf dokuwiki/install.php

COPY apache2.conf /etc/apache2/apache2.conf
COPY htaccess /var/www/dokuwiki/.htaccess

RUN service apache2 restart

RUN sed -i s%/var/www/html%/var/www/dokuwiki%g /etc/apache2/sites-enabled/000-default.conf
RUN echo '<?php \n\
// DO NOT use a closing php tag. This causes a problem with the feeds, \n\
// among other things. For more information on this issue, please see: \n\
// http://www.dokuwiki.org/devel:coding_style#php_closing_tags \n\
\n\
define('"'"'DOKU_CONF'"'"','"'"'/wiki/conf/'"'"');' > /var/www/dokuwiki/inc/preload.php 

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
