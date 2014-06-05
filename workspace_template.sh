#!/bin/bash
# Workspace: _{workspace}_

# Start workspace services
function start {
  echo "Starting _{workspace}_ services"
  echo "Done"
}

# Stop workspace services
function stop {
  echo "Stopping _{workspace}_ services"
  echo "Done"
}

case $1 in
  "start") start ;;
  "stop") stop ;;
esac
