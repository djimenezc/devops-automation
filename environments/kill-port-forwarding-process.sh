#!/usr/bin/env bash

kill $(ps aux | grep 'kubectl port-forward*' | awk '{print $2}')
