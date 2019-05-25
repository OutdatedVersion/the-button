#!/bin/bash

rsync --delete \
      -Pav \
      -e "ssh -i ~/.ssh/pi" \
       ./build/ \
       ${BUTTON_SSH_USER}@${BUTTON_SSH_HOST}:${BUTTON_STORAGE_PATH}
