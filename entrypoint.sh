#!/bin/sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto
mkdir /log
touch /log/mosquitto.log
chmod o+w /log/mosquitto.log
chown mosquitto:mosquitto -R /log/mosquitto.log

# Replace HOST and PORT in the configuration file
OPT_HOST="auth_opt_http_ip .*$/auth_opt_http_ip $MQTT_ACCESS_CONTROL_API_HOST"
OPT_PORT="auth_opt_http_port .*$/auth_opt_http_port $MQTT_ACCESS_CONTROL_API_PORT"

sed -i 's/'"$OPT_HOST"'/' /etc/mosquitto/config/mosquitto.conf
sed -i 's/'"$OPT_PORT"'/' /etc/mosquitto/config/mosquitto.conf

echo "MQTT Broker: Waiting for Access Control API"
while ! nc -z $MQTT_ACCESS_CONTROL_API_HOST $MQTT_ACCESS_CONTROL_API_PORT; do
  sleep 0.1
done
echo "MQTT Broker: Access Control API is Up"

# Start Mosquitto
exec /usr/local/sbin/mosquitto -c /etc/mosquitto/config/mosquitto.conf

exec "$@"
