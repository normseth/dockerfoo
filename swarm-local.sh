#!/bin/bash

set -e

# Docker Machine Setup
docker-machine create \
    -d virtualbox \
    demo-dependencies

docker $(docker-machine config demo-dependencies) run -d \
    -p "5000:5000" \
    -h "registry" \
    registry:2

docker $(docker-machine config demo-dependencies) run -d \
    -p "8500:8500" \
    -h "consul" \
    localhost:5000/consul -server -bootstrap

docker-machine create \
    -d virtualbox \
    --virtualbox-disk-size 100000 \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip demo-dependencies):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip demo-dependencies):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    demo01

docker-machine create \
    -d virtualbox \
    --virtualbox-disk-size 100000 \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip demo-dependencies):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip demo-dependencies):8500" \
    --engine-opt="cluster-advertise=eth1:0" \
    demo02
