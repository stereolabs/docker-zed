#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/$ROS2_DISTRO/setup.bash"
source "$ROS2_WS/install/setup.bash"
exec "$@"
