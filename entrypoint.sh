#!/bin/sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto
mkdir /log
touch /log/mosquitto.log
chmod o+w /log/mosquitto.log
chown mosquitto:mosquitto -R /log/mosquitto.log

# Replace HOST and PORT in the configuration file
OPT_HOST="auth_opt_host .*$/auth_opt_host $SQL_HOST"
OPT_PORT="auth_opt_port .*$/auth_opt_port $SQL_PORT"
OPT_DBNAME="auth_opt_dbname .*$/auth_opt_dbname $SQL_DATABASE"
OPT_DB_USER="auth_opt_user .*$/auth_opt_user $SQL_USER"
OPT_DB_PASS="auth_opt_pass .*$/auth_opt_pass $SQL_PASSWORD"

sed -i 's/'"$OPT_HOST"'/' /etc/mosquitto/config/mosquitto.conf
sed -i 's/'"$OPT_PORT"'/' /etc/mosquitto/config/mosquitto.conf
sed -i 's/'"$OPT_DBNAME"'/' /etc/mosquitto/config/mosquitto.conf
sed -i 's/'"$OPT_DB_USER"'/' /etc/mosquitto/config/mosquitto.conf
sed -i 's/'"$OPT_DB_PASS"'/' /etc/mosquitto/config/mosquitto.conf

# Wait for Postgres to be online before start the mosquitto
echo "Waiting for postgres..."

while ! nc -z $SQL_HOST $SQL_PORT; do
  sleep 0.1
done
echo "PostgreSQL started"

# Start Mosquitto
if [ "$1" = 'mosquitto' ]; then
        exec /usr/local/sbin/mosquitto -c /etc/mosquitto/config/mosquitto.conf
fi

if [ "$1" = 'mosquittoverbose' ]; then
        exec /usr/local/sbin/mosquitto -v -c /etc/mosquitto/config/mosquitto.conf
fi

exec "$@"
