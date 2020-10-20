FROM rocker/shiny:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
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
    && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools \
    && rm -rf /tmp/downloaded_packages

#    libmariadbd-dev \
#    libmariadbclient-dev \
#    BiocManager \

# Download and install shiny server
#RUN wget https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
#    VERSION=$(cat version.txt)  
#RUN  wget "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb 
RUN  wget "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.7.902-amd64.deb" -O ss-latest.deb 
#RUN    gdebi -n ss-latest.deb 
#RUN  rm -f version.txt ss-latest.deb && \
#    . /etc/environment 
#RUN cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ 
RUN mkdir -p /code
COPY packages.R /code/packages.R
#COPY .env /var/check.Renviron
RUN sudo Rscript /code/packages.R
COPY mountpoints/apps /srv/shiny-server
#RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')"
RUN chown shiny:shiny /var/lib/shiny-server
ARG USERDB
RUN export USERDB=$USERDB
ARG DBNAMEDB
RUN export DBNAMEDB=$DBNAMEDB
ARG PASSWORDDB
RUN export PASSWORDDB=$PASSWORDDB
ARG HOSTDB
RUN export HOSTDB=$HOSTDB
RUN env | grep -v 'IGNORE' | grep -v -P '^_' | perl -pe 's/^([^=]+)=(.+)$/Sys.setenv($1='"'"'$2'"'"')/' >> /etc/env.R

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
