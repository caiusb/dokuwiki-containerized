FROM ubuntu:disco

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install wget tar apache2 libapache2-mod-php php-xml php-mbstring php-gd

RUN a2enmod rewrite

RUN cd /var/www && \
    wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz && \
    tar xvf dokuwiki-stable.tgz && \
    mv dokuwiki-*/ dokuwiki && \
    rm -rf dokuwiki-stable.tgz && \
    chown -R www-data:www-data /var/www/dokuwiki && \
    rm -rf dokuwiki/data && \
    rm -rf dokuwiki/conf && \
    rm -rf dokuwiki/install.php

RUN cd /var/www/dokuwiki/lib/plugins && \
    wget -O dw2pdf.tar.gz https://github.com/splitbrain/dokuwiki-plugin-dw2pdf/tarball/master && \
    mkdir dw2pdf && \
    tar xvf dw2pdf.tar.gz -C dw2pdf --strip-components=1 && \
    wget -O secure-login.tar.gz https://github.com/bagley/dokuwiki-securelogin/tarball/master && \ 
    mkdir securelogin && \
    tar xvf secure-login.tar.gz -C securelogin --strip-components=1 && \
    wget -O markdowku.tar.gz https://komkon2.de/markdowku/markdowku.tgz && \
    mkdir markdowku && \
    tar xvf markdowku.tar.gz -C markdowku --strip-components=1 && \
    rm -rf *tar.gz 


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
