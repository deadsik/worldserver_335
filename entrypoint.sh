#!/bin/bash
set -e

file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo "Both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

# Loads various settings that are used elsewhere in the script
docker_setup_env() {
    # Initialize values that might be stored in a file
    file_env 'WORLDSERVER_WORLDSERVERPORT' $DEFAULT_WORLDSERVER_WORLDSERVERPORT
    file_env 'WORLDSERVER_BINDIP' $DEFAULT_WORLDSERVER_BINDIP
    file_env 'WORLDSERVER_RATES' $DEFAULT_WORLDSERVER_RATES
    file_env 'WORLDSERVER_NAME' $DEFAULT_WORLDSERVER_NAME
    file_env 'WORLDSERVER_REALMID' $DEFAULT_WORLDSERVER_REALMID
    file_env 'WORLDSERVER_SOAP_PORT' $DEFAULT_WORLDSERVER_SOAP_PORT
    file_env 'WORLDSERVER_SOAP_ENABLED' $DEFAULT_WORLDSERVER_SOAP_ENABLED
    file_env 'WORLDSERVER_SOAP_IP' $DEFAULT_WORLDSERVER_SOAP_IP
    file_env 'WORLDSERVER_CONSOLE_ENABLE' $DEFAULT_WORLDSERVER_CONSOLE_ENABLE
    file_env 'WORLDSERVER_RA_ENABLE' $DEFAULT_WORLDSERVER_RA_ENABLE
    file_env 'WORLDSERVER_RA_IP' $DEFAULT_WORLDSERVER_RA_IP
    file_env 'WORLDSERVER_RA_PORT' $DEFAULT_WORLDSERVER_RA_PORT
    file_env 'WORLDSERVER_RA_MINLEVEL' $DEFAULT_WORLDSERVER_RA_MINLEVEL
    file_env 'WORLDSERVER_MYSQL_AUTOCONF' $DEFAULT_WORLDSERVER_MYSQL_AUTOCONF

    file_env 'AUTHSERVER_MYSQL_HOST' $DEFAULT_AUTHSERVER_MYSQL_HOST
    file_env 'AUTHSERVER_MYSQL_PORT' $DEFAULT_AUTHSERVER_MYSQL_PORT
    file_env 'AUTHSERVER_MYSQL_USER' $DEFAULT_AUTHSERVER_MYSQL_USER
    file_env 'AUTHSERVER_MYSQL_PASSWORD' $DEFAULT_AUTHSERVER_MYSQL_PASSWORD
    file_env 'AUTHSERVER_MYSQL_DB' $DEFAULT_AUTHSERVER_MYSQL_DB

    file_env 'WORLDSERVER_MYSQL_HOST' $DEFAULT_WORLDSERVER_MYSQL_HOST
    file_env 'WORLDSERVER_MYSQL_PORT' $DEFAULT_WORLDSERVER_MYSQL_PORT
    file_env 'WORLDSERVER_MYSQL_USER' $DEFAULT_WORLDSERVER_MYSQL_USER
    file_env 'WORLDSERVER_MYSQL_PASSWORD' $DEFAULT_WORLDSERVER_MYSQL_PASSWORD
    file_env 'WORLDSERVER_MYSQL_DB' $DEFAULT_WORLDSERVER_MYSQL_DB

    file_env 'CHARACTERSSERVER_MYSQL_HOST' $DEFAULT_CHARACTERSSERVER_MYSQL_HOST
    file_env 'CHARACTERSSERVER_MYSQL_PORT' $DEFAULT_CHARACTERSSERVER_MYSQL_PORT
    file_env 'CHARACTERSSERVER_MYSQL_USER' $DEFAULT_CHARACTERSSERVER_MYSQL_USER
    file_env 'CHARACTERSSERVER_MYSQL_PASSWORD' $DEFAULT_CHARACTERSSERVER_MYSQL_PASSWORD
    file_env 'CHARACTERSSERVER_MYSQL_DB' $DEFAULT_CHARACTERSSERVER_MYSQL_DB
}

docker_setup_env


if $WORLDSERVER_MYSQL_AUTOCONF ; then
# Set MYSQL Credentials in worldserver.conf
  sed -r -i 's/^LoginDatabaseInfo     = .*$/LoginDatabaseInfo     = "'${AUTHSERVER_MYSQL_HOST}';'${AUTHSERVER_MYSQL_PORT}';'${AUTHSERVER_MYSQL_USER}';'${AUTHSERVER_MYSQL_PASSWORD}';'${AUTHSERVER_MYSQL_DB}'"/' /home/server/wow/etc/worldserver.conf
  sed -r -i 's/^WorldDatabaseInfo     = .*$/WorldDatabaseInfo     = "'${WORLDSERVER_MYSQL_HOST}';'${WORLDSERVER_MYSQL_PORT}';'${WORLDSERVER_MYSQL_USER}';'${WORLDSERVER_MYSQL_PASSWORD}';'${WORLDSERVER_MYSQL_DB}'"/' /home/server/wow/etc/worldserver.conf
  sed -r -i 's/^CharacterDatabaseInfo = .*$/CharacterDatabaseInfo = "'${CHARACTERSSERVER_MYSQL_HOST}';'${CHARACTERSSERVER_MYSQL_PORT}';'${CHARACTERSSERVER_MYSQL_USER}';'${CHARACTERSSERVER_MYSQL_PASSWORD}';'${CHARACTERSSERVER_MYSQL_DB}'"/' /home/server/wow/etc/worldserver.conf

  unset -v AUTHSERVER_MYSQL_PASSWORD
  unset -v WORLDSERVER_MYSQL_PASSWORD
  unset -v CHARACTERSSERVER_MYSQL_PASSWORD
fi

sed -r -i 's/^WorldServerPort = .*$/WorldServerPort = '${WORLDSERVER_WORLDSERVERPORT}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^BindIP = .*$/BindIP = '${WORLDSERVER_BINDIP}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^RealmID = .*$/RealmID = '${WORLDSERVER_REALMID}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^SOAP.Port = .*$/SOAP.Port = '${WORLDSERVER_SOAP_PORT}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^SOAP.Enabled = .*$/SOAP.Enabled = '${WORLDSERVER_SOAP_ENABLED}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^SOAP.IP = .*$/SOAP.IP = '${WORLDSERVER_SOAP_IP}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Console.Enable = .*$/Console.Enable = '${WORLDSERVER_CONSOLE_ENABLE}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Ra.Enable = .*$/Ra.Enable = '${WORLDSERVER_RA_ENABLE}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Ra.IP = .*$/Ra.IP = '${WORLDSERVER_RA_IP}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Ra.Port = .*$/Ra.Port = '${WORLDSERVER_RA_PORT}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Ra.MinLevel = .*$/Ra.MinLevel = '${WORLDSERVER_RA_MINLEVEL}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Motd = .*$/Motd = "Welcome to '${WORLDSERVER_NAME}' x'${WORLDSERVER_RATES}' server."/' /home/server/wow/etc/worldserver.conf

sed -r -i 's/^Rate.Health            = .*$/Rate.Health            = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Mana              = .*$/Rate.Mana              = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Rage.Income       = .*$/Rate.Rage.Income       = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Rage.Loss         = .*$/Rate.Rage.Loss         = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.RunicPower.Income = .*$/Rate.RunicPower.Income = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Rage.Loss         = .*$/Rate.Rage.Loss         = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.RunicPower.Income = .*$/Rate.RunicPower.Income = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.RunicPower.Loss   = .*$/Rate.RunicPower.Loss   = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Focus             = .*$/Rate.Focus             = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Energy            = .*$/Rate.Energy            = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Loyalty           = .*$/Rate.Loyalty           = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Poor             = .*$/Rate.Drop.Item.Poor             = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Normal           = .*$/Rate.Drop.Item.Normal           = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Uncommon         = .*$/Rate.Drop.Item.Uncommon         = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Rare             = .*$/Rate.Drop.Item.Rare             = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Epic             = .*$/Rate.Drop.Item.Epic             = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Legendary        = .*$/Rate.Drop.Item.Legendary        = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Artifact         = .*$/Rate.Drop.Item.Artifact         = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.Referenced       = .*$/Rate.Drop.Item.Referenced       = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Money                 = .*$/Rate.Drop.Money                 = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.Drop.Item.ReferencedAmount = .*$/Rate.Drop.Item.ReferencedAmount = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.XP.Kill    = .*$/Rate.XP.Kill    = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.XP.Quest   = .*$/Rate.XP.Quest   = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf
sed -r -i 's/^Rate.XP.Explore = .*$/Rate.XP.Explore = '${WORLDSERVER_RATES}'/' /home/server/wow/etc/worldserver.conf

# Run worldserver
sudo -H -u server bash -c "cd /home/server/wow/bin/ && ./worldserver"
exec "$@"
