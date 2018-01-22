#!/bin/bash
curl -s https://api.github.com/meta|jq '.hooks|{data:join(",")}'
