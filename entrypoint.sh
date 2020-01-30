#!/bin/sh -l

config= <<EOF
[https://www.transifex.com]
api_hostname = https://api.transifex.com
hostname = https://www.transifex.com
password = $TX_TOKEN
username = api
)
EOF

echo $config > ~/.transifexrc

tx push -s
