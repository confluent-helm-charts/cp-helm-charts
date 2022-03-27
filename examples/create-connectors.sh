#!/usr/bin/env sh
## A script similar to this can be used to create connectors making sure the endpoints are ready

# TODO: change this to use https://github.com/kcctl/kcctl
echo "Waiting for Kafka Connect to start listening on kafka-connect  "
while :; do
    # Check if the connector endpoint is ready
    # If not check again

    # shellcheck disable=SC1083
    curl_status=$(curl -s -o /dev/null -w %{http_code} http://localhost:{{ .Values.servicePort }}/connectors)
    # shellcheck disable=SC2039
    # shellcheck disable=SC2046
    # shellcheck disable=SC3037
    echo -e $(date) "Kafka Connect listener HTTP state: $curl_status (waiting for 200)"
    # shellcheck disable=SC2086

    if [ $curl_status -eq 200 ]; then
        break
    fi
    sleep 5
done

echo "======> Creating connectors"
# Send a simple POST request to create the connector
curl -X POST \
    -H "Content-Type: application/json" \
    --data '{
    "name": "sample-connector",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
        "tasks.max": 1,
        "connection.url": "jdbc:mysql://123.4.5.67:3306/test_db?user=root&password=pass",
        "mode": "incrementing",
        "incrementing.column.name": "id",
        "timestamp.column.name": "modified",
        "topic.prefix": "sample-connector-",
        "poll.interval.ms": 1000
        }
    }' http://"$CONNECT_REST_ADVERTISED_HOST_NAME":8083/connectors
