FROM eclipse-mosquitto:1.6.7

COPY ./config/aclfile /mosquitto/config/aclfile
COPY ./config/mosquitto.conf /mosquitto/config/mosquitto.conf
