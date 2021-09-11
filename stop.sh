#!/bin/bash
container=$(docker ps | grep metaplex-docker:latest | awk '{print $1}')
docker stop ${container}
