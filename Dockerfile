FROM ubuntu:20.04 
MAINTAINER admin <evgeniy@kolesnyk.ru> 

ENV WORLDSERVER_TZ="Etc/UTC" \
    WORLDSERVER_SYSTEM_CORES="8" \
    WORLDSERVER_SYSTEM_USER="server" \
    DEFAULT_WORLDSERVER_WORLDSERVERPORT="8085" \
    DEFAULT_WORLDSERVER_BINDIP="0.0.0.0" \
    DEFAULT_WORLDSERVER_REALMID="1" \
    DEFAULT_WORLDSERVER_SOAP_PORT="7878" \
    DEFAULT_WORLDSERVER_SOAP_ENABLED="0" \
    DEFAULT_WORLDSERVER_SOAP_IP="127.0.0.1" \
    DEFAULT_WORLDSERVER_CONSOLE_ENABLE="1" \
    DEFAULT_WORLDSERVER_RA_ENABLE="0" \
    DEFAULT_WORLDSERVER_RA_IP="0.0.0.0" \
    DEFAULT_WORLDSERVER_RA_PORT="3443" \
    DEFAULT_WORLDSERVER_RA_MINLEVEL="3" \
    DEFAULT_WORLDSERVER_RATES="1" \
    DEFAULT_WORLDSERVER_NAME="Trinity" \
    DEFAULT_WORLDSERVER_MYSQL_AUTOCONF=true \
    DEFAULT_AUTHSERVER_MYSQL_HOST="127.0.0.1" \
    DEFAULT_AUTHSERVER_MYSQL_PORT="3306" \
    DEFAULT_AUTHSERVER_MYSQL_USER="trinity" \
    DEFAULT_AUTHSERVER_MYSQL_PASSWORD="trinity" \
    DEFAULT_AUTHSERVER_MYSQL_DB="auth" \
    DEFAULT_WORLDSERVER_MYSQL_HOST="127.0.0.1" \
    DEFAULT_WORLDSERVER_MYSQL_PORT="3306" \
    DEFAULT_WORLDSERVER_MYSQL_USER="trinity" \
    DEFAULT_WORLDSERVER_MYSQL_PASSWORD="trinity" \
    DEFAULT_WORLDSERVER_MYSQL_DB="world" \
    DEFAULT_CHARACTERSSERVER_MYSQL_HOST="127.0.0.1" \
    DEFAULT_CHARACTERSSERVER_MYSQL_PORT="3306" \
    DEFAULT_CHARACTERSSERVER_MYSQL_USER="trinity" \
    DEFAULT_CHARACTERSSERVER_MYSQL_PASSWORD="trinity" \
    DEFAULT_CHARACTERSSERVER_MYSQL_DB="characters"

ARG DEBIAN_FRONTEND=noninteractive

RUN ln -snf /usr/share/zoneinfo/$WORLDSERVER_TZ /etc/localtime && echo $WORLDSERVER_TZ > /etc/timezone && \
    apt-get update && apt-get install -y apt-utils && \
    apt-get upgrade -y && \
    apt-get install build-essential autoconf libtool gcc g++ make git-core wget p7zip-full libncurses5-dev zlib1g-dev libbz2-dev openssl libssl-dev libreadline6-dev libboost-dev libboost-thread-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-iostreams-dev libzmq3-dev libmysqlclient-dev libmysql++-dev curl mysql-client sudo -y

RUN curl -o /root/cmake-3.23.0-rc2.tar.gz https://cmake.org/files/v3.23/cmake-3.23.0-rc2.tar.gz && \
    cd /root && tar xzf cmake-3.23.0-rc2.tar.gz && \
    cd cmake-3.23.0-rc2 && \
    ./configure && \
    make -j $WORLDSERVER_SYSTEM_CORES && \
    make install && \
    rm -rf /root/cmake-3.23.0-rc2 && \
    rm -f /root/cmake-3.23.0-rc2.tar.gz

RUN useradd -ms /bin/bash $WORLDSERVER_SYSTEM_USER && \
    mkdir -p /home/$WORLDSERVER_SYSTEM_USER/wow && \
    mkdir -p /home/$WORLDSERVER_SYSTEM_USER/source && \
    cd /home/$WORLDSERVER_SYSTEM_USER/source && \
    git clone https://github.com/TrinityCore/TrinityCore.git && \
    mkdir -p /home/$WORLDSERVER_SYSTEM_USER/source/TrinityCore/build && \
    cd /home/$WORLDSERVER_SYSTEM_USER/source/TrinityCore && \
    git checkout -b 3.3.5 origin/3.3.5 && \
    cd /home/$WORLDSERVER_SYSTEM_USER/source/TrinityCore/build && \
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/$WORLDSERVER_SYSTEM_USER/wow && \
    make -j $WORLDSERVER_SYSTEM_CORES && \
    make install

RUN cd /home/$WORLDSERVER_SYSTEM_USER/wow/bin/ && rm -f mapextractor mmaps_generator vmap4assembler vmap4extractor authserver && \
    rm -f /home/$WORLDSERVER_SYSTEM_USER/wow/etc/authserver.conf.dist && \
    mv /home/$WORLDSERVER_SYSTEM_USER/wow/etc/worldserver.conf.dist /home/$WORLDSERVER_SYSTEM_USER/wow/etc/worldserver.conf && \
    curl -o /home/$WORLDSERVER_SYSTEM_USER/wow/bin/maps.tar.gz https://download.piratewow.com/servers/wow335a/maps.tar.gz && \
    cd /home/$WORLDSERVER_SYSTEM_USER/wow/bin/ && tar xzf maps.tar.gz && rm -f maps.tar.gz && \
    chown -R $WORLDSERVER_SYSTEM_USER:$WORLDSERVER_SYSTEM_USER /home/$WORLDSERVER_SYSTEM_USER/

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
