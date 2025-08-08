#!/bin/bash

# Start cron
echo "Starting cron..."
cron

# Keep container running
tail -f /var/log/cron.log
