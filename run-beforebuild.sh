#!/bin/sh


ssh-keygen -t rsa -b 2048 -v -m pem -f id_rsa
cp id_rsa ec/id_rsa
cp id_rsa.pub controller/id_rsa.pub
cp id_rsa.pub ec/id_rsa.pub
cp id_rsa.pub eum/id_rsa.pub
cp id_rsa.pub event/id_rsa.pub
