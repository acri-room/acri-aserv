#!/usr/bin/env bash
lxc ls -f json | jq -rj ".[] | select(.name == \"staging\") | .state | .network | .eth0 | .addresses[] | select(.family == \"inet\") | .address"

