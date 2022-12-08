#!/bin/bash
/opt/chaosmonkey/bin/chaosmonkey terminate "$@" >> /var/log/chaosmonkey-terminate.log 2>&1
