FROM oracle/database:18.4.0-xe

LABEL maintainer="paul@dziemiela.com"

COPY ./Docker/01_docker_setup.sql /opt/oracle/scripts/setup

RUN mkdir /opt/oracle/scripts/src                       &&\
    chown oracle:oinstall /opt/oracle/scripts/src
    
COPY ./dz_swagger3_deploy.sql            /opt/oracle/scripts/src
COPY ./SampleData/                       /opt/oracle/scripts/src
COPY ./Packages/DZ_SWAGGER3_VALIDATE.pkb /opt/oracle/scripts/src

RUN sed -i "s|c_swagger_badge_url         CONSTANT VARCHAR2(4000 Char) := NULL;|c_swagger_badge_url         CONSTANT VARCHAR2(4000 Char) := 'http://dz_badge:8080/validator/debug';|g" /opt/oracle/scripts/src/DZ_SWAGGER3_VALIDATE.pkb
