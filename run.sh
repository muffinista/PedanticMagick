#!/bin/bash

NAME=$(basename $PWD | tr '[:upper:]' '[:lower:]')
echo $NAME
#docker build -t $NAME . &&
docker run --rm $NAME
