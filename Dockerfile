FROM ubuntu:noble

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install wget tar apache2 libapache2-mod-php php-xml php-mbstring php-gd

RUN a2enmod rewrite && \
    a2enmod ssl

RUN cd /var/www && \
    wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz && \
    tar xvf dokuwiki-stable.tgz && \
    mv dokuwiki-*/ dokuwiki && \
    rm -rf dokuwiki-stable.tgz && \
    chown -R www-data:www-data /var/www/dokuwiki

RUN cd /var/www/dokuwiki/lib/plugins && \
    wget -O dw2pdf.tar.gz https://github.com/splitbrain/dokuwiki-plugin-dw2pdf/tarball/master && \
    mkdir dw2pdf && \
    tar xvf dw2pdf.tar.gz -C dw2pdf --strip-components=1 && \
    wget -O secure-login.tar.gz https://github.com/bagley/dokuwiki-securelogin/tarball/master && \ 
    mkdir securelogin && \
    tar xvf secure-login.tar.gz -C securelogin --strip-components=1 && \
    wget -O meta.tar.gz https://github.com/dokufreaks/plugin-meta/tarball/master && \
    mkdir meta && \
    tar xvf meta.tar.gz -C meta --strip-components=1 && \
    rm -rf *tar.gz && \
    chown -R www-data:www-data . 

COPY apache2.conf /etc/apache2/apache2.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY htaccess /var/www/dokuwiki/.htaccess

RUN echo '<?php \n\
// DO NOT use a closing php tag. This causes a problem with the feeds, \n\
// among other things. For more information on this issue, please see: \n\
// http://www.dokuwiki.org/devel:coding_style#php_closing_tags \n\
\n\
define('"'"'DOKU_CONF'"'"','"'"'/var/www/dokuwiki/conf/'"'"');' > /var/www/dokuwiki/inc/preload.php 

EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
