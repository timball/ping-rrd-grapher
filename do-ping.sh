#!/bin/bash

source settings.sh

ping -n ${PING_HOST} | ts | tee ping.out
