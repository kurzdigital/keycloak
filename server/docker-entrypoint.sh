#!/bin/bash

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

if [ "$KEYCLOAK_REVERSE_PROXY" = "true" ]; then
    "$JBOSS_HOME/bin/jboss-cli.sh" << EOF
embed-server --server-config=standalone.xml
batch
/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=443)
/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)
/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)
run-batch
stop-embedded-server
embed-server --server-config=standalone-ha.xml
batch
/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=443)
/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)
/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)
run-batch
stop-embedded-server
EOF

fi

exec /opt/jboss/keycloak/bin/standalone.sh $@

exit $?
