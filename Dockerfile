FROM python:2.7.18-buster
MAINTAINER Fanch
ARG UID=222

RUN mkdir -p /odoo 

COPY ./base_requirements.txt /odoo


# build and dev packages
ENV BUILD_PACKAGE \
    build-essential \
    gcc \
    libevent-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt1-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    git

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
# wkhtml-buster is kept as in official image, no deb available for bullseye
RUN apt-get update -o Acquire::AllowInsecureRepositories=true \
    && apt-get install -y --no-install-recommends \
    python-dateutil \
    python-docutils \
    python-feedparser \
    python-jinja2 \
    python-ldap \
    python-libxslt1 \
    python-lxml \
    python-mako \
    python-mock \
    python-openid \
    python-psycopg2 \
    python-psutil \
    python-babel \
    python-pychart \
    python-pydot \
    python-pyparsing \
    python-reportlab \
    python-simplejson \
    python-tz \
    python-unittest2 \
    python-vatnumber \
    python-vobject \
    python-webdav \
    python-werkzeug \
    python-xlwt \
    python-yaml \
    python-zsi \
    poppler-utils \
    python-pip \
    python-pypdf2 \
    python-passlib \
    python-decorator \
    gcc \
    python-dev \
    mc \
    bzr \
    python-setuptools \
    python-markupsafe \
    python-reportlab-accel \
    python-zsi \
    python-yaml \
    python-argparse \
    python-openssl \
    python-egenix-mxdatetime \
    python-usb \
    python-serial \
    lptools \
    make \
    python-pydot \
    python-psutil \
    python-paramiko \
    poppler-utils \
    python-pdftools \
    antiword \
    python-requests \
    python-xlsxwriter \
    python-suds \
    python-psycogreen \
    python-ofxparse \
    python-gevent \
    npm \
    git

RUN npm install -g less less-plugin-clean-css
  

RUN  echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list \ 
       &&  curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \ 
       &&  apt-get update \
       &&  apt-get install -y --no-install-recommends postgresql-client libpq-dev \
       &&  apt-get -y install -f --no-install-recommends 

RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb

RUN apt-get install -y --no-install-recommends \
    libsasl2-dev \
    python-dev \
    libldap2-dev \
    libssl-dev \
    unixodbc \
    unixodbc-dev \
    libnode-dev \
    nodejs \
    node-gyp \
    node-less \
    npm

RUN npm install -g less@3.0.4 less-plugin-clean-css

RUN     python2.7 -m pip install --force-reinstall pip "setuptools<58" \
        && pip install -r /odoo/base_requirements.txt --ignore-installed 

RUN  apt-get remove -y $BUILD_PACKAGE libpq-dev \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $PURGE_PACKAGE \
        && rm -rf /var/lib/apt/lists/* /root/.cache/pip/* \
        && rm -rf /odoo/base_requirements.txt 

RUN adduser --disabled-password -u $UID --gecos '' odoo
RUN chown -R odoo:odoo /odoo
RUN usermod odoo --home /odoo


USER odoo
# Expose Odoo services
EXPOSE 8069 8072

WORKDIR /odoo

CMD ["python"]
