#!/bin/sh

exec /sia-nbdserver --sia-daemon $SIA_API_ADDRESS --sia-password-file $SIA_PASSWORD_FILE -u $SERVER_ADDRESS
