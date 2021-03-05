FROM openshift/base-centos7

LABEL maintainer="Margarita Barvinok <brita@umich.edu>"

ENV R_SHINY_SERVER_VERSION 1.5.3.838

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Shiny is an R package that makes it easy to build interactive web apps straight from R." \
    io.k8s.display-name="Shiny ${R_SHINY_SERVER_VERSION}" \
    io.openshift.expose-services="3838:http" \
    io.openshift.tags="builder,R,shiny,RShiny"

### Install shiny as per instructions at:
### https://www.rstudio.com/products/shiny/download-server/
### note: yum uses http_proxy and https_proxy environment variables to set proxy
RUN yum -y update && yum -y install epel-release wget && yum -y install R && yum -y install openssl-devel && yum -y install cyrus-sasl-devel && yum clean all
# from my Dockerfile
RUN yum -y install \
    libglpk-dev \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmysqlclient-dev \
    libpq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libssh2-1-dev \
    sudo \
    unixodbc-dev \
    vim \
    wget \
    xtail \
    && yum clean all
## Install rquired R Packagees
RUN R -e "install.packages(c('shiny', 'rmarkdown', 'devtools', 'RJDBC', 'packrat', 'digest', 'mongolite', 'jsonlite', 'openxlsx', 'tools', 'dplyr', 'tidyr'), repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('tidyverse', 'formatR', 'remotes', 'selectr', 'caTools'), repos='http://cran.rstudio.com/')"
## Copy and install my own library used by the shiny server
## ADD apeDatabase /opt/app-root/apeDatabase
## RUN R -e "install.packages('/opt/app-root/apeDatabase', repos = NULL, type='source')"

### copy wgetrc configuration file with proxy info
COPY etc/wgetrc /etc/wgetrc
RUN wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-${R_SHINY_SERVER_VERSION}-rh5-x86_64.rpm && \
    yum -y install --nogpgcheck shiny-server-${R_SHINY_SERVER_VERSION}-rh5-x86_64.rpm && yum clean all

# Defines the location of the S2I
# Although this is defined in openshift/base-centos7 image it's repeated here
# to make it clear why the following COPY operation is happening
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i

# custom config which users user 'default' set by openshift
COPY etc/shiny-server.conf /etc/shiny-server/shiny-server.conf

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
RUN mkdir -p /var/lib/shiny-server/bookmarks && \
    chown default:0 /var/lib/shiny-server/bookmarks && \
    chmod g+wrX /var/lib/shiny-server/bookmarks && \
    mkdir -p /var/log/shiny-server && \
    chown default:0 /var/log/shiny-server && \
    chmod g+wrX /var/log/shiny-server 

## Also touch the packrat folder which is backed up and restored between incremental builds (use s2i with --incremental)
RUN id && echo " " && whoami && mkdir -p /opt/app-root/src/packrat/ && \
    chgrp -R 0 /opt/app-root/src/packrat/ && \
    chmod g+wrX /opt/app-root/src/packrat/

## Copy over "hello world" shiny app
ADD test /opt/app-root/src/test
RUN chgrp -R 0 /opt/app-root/src/test/ && \
    chmod g+wrX /opt/app-root/src/test/

## install dditional R packages
RUN mkdir -p /opt/app-root/src/code
COPY packages.R /opt/app-root/src/code/packages.R
# RUN sudo Rscript /opt/app-root/src/code/packages.R
RUN Rscript /opt/app-root/src/code/packages.R

## Copy my shiny app
ADD CZEUM_Interact_Tree /opt/app-root/src/CZEUM_Interact_Tree
RUN chgrp -R 0 /opt/app-root/src/CZEUM_Interact_Tree && \
    chmod g+wrX /opt/app-root/src/CZEUM_Interact_Tree

### Setup user for build execution and application runtime
### https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile.centos7
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd &&\
    chmod -R g+rw /etc/

# openshift best practice is to use a number not a name this is user shiny
USER 1001

ARG USERDB
RUN export USERDB=$USERDB
ENV USERDB $USERDB
ARG DBNAMEDB
RUN export DBNAMEDB=$DBNAMEDB
ENV DBNAMEDB $DBNAMEDB
ARG PASSWORDDB
RUN export PASSWORDDB=$PASSWORDDB
ENV PASSWORDDB $PASSWORDDB
ARG HOSTDB
RUN export HOSTDB=$HOSTDB
ENV HOSTDB $HOSTDB
RUN env | grep -v 'IGNORE' | grep -v -P '^_' | perl -pe 's/^([^=]+)=(.+)$/Sys.setenv($1='"'"'$2'"'"')/' >> /etc/env.R


### Wrapper to allow user name resolution openshift will actually use a random user number so you need group permissions
### https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-arbitrary-uid/Dockerfile.centos7
ENTRYPOINT [ "uid_entrypoint" ]
CMD run
