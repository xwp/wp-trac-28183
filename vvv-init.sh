#!/bin/bash

cd "$(dirname $0)"

printf "Setting up: %s\n" $(basename $(pwd))

sudo su - vagrant -c "$(pwd)/reset.sh"
