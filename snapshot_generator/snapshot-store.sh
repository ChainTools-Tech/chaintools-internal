#! /bin/bash

# Terminal color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initializes snapshot storer

function check_for_snapshot() {
        echo -e "${RED}= STARTING SCAN FOR BACKUPS =${NC}"
        #checkk for dir list file
        if [  ! -s "/.juno/data/snapshots" ] 
        then 
                echo "Please check statesync is on. Ya FUD"
        fi
    }