FROM python:slim-bullseye
MAINTAINER Pavankumar Panchal (pav19892@gmail.com)
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
    antiword \
    ca-certificates \
    curl \
    dirmngr \
    ghostscript \
    graphviz \
    gnupg2 \
    less \
    nano \
    node-clean-css \
    node-less \
    poppler-utils \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-renderpm \
    python3-wheel \
    libxslt1.1 \
    xfonts-75dpi \
    xfonts-base \
    xz-utils \
    tcl expect \
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


RUN  echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list \ 
       &&  curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \ 
       &&  apt-get update \
       &&  apt-get install -y --no-install-recommends postgresql-client libpq-dev \
       &&  apt-get -y install -f --no-install-recommends 

RUN curl -o kwkhtmltopdf_client -SL https://raw.githubusercontent.com/camptocamp/kwkhtmltopdf/master/client/python/kwkhtmltopdf_client.py \ 
    && echo '8676b798f57c67e3a801caad4c91368929c427ce kwkhtmltopdf_client' | sha1sum -c - \
    && mv kwkhtmltopdf_client /usr/local/bin/wkhtmltopdf \
    && chmod a+x /usr/local/bin/wkhtmltopdf  \
    && sed -i "1 s/python/python3/g" /usr/local/bin/wkhtmltopdf

RUN     python3 -m pip install --force-reinstall pip "setuptools<58" \
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
