#!/bin/bash

curl -s http://checkip.dyndns.org/ | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}'
