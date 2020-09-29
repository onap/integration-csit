#!/bin/bash
ip a | grep docker | grep inet | awk '{print $2}' | awk -F'/' '{print $1}'
