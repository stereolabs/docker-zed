#https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base
ARG ZED_SDK_MAJOR
ARG ZED_SDK_MINOR
ARG JETPACK_MAJOR
ARG JETPACK_MINOR

FROM stereolabs/zed:${ZED_SDK_MAJOR}.${ZED_SDK_MINOR}-devel-jetson-jp${JETPACK_MAJOR}.${JETPACK_MINOR}

ARG ROS2_DISTRO_ARG
ARG L4T_MINOR_VERSION

ENV LOGNAME root
ENV ROS2_DISTRO ${ROS2_DISTRO_ARG}
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Setup ROS
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install ros-$ROS2_DISTRO-ros-base python3-colcon-common-extensions python3-rosinstall python3-rosdep python3-rosinstall-generator python3-wstool build-essential nano \
        cmake usbutils git -y --allow-unauthenticated && \
    rm -rf /var/lib/apt/lists/*

# setup ros env
ENV ROS2_WS /opt/ros2_ws

RUN rosdep init && \
  rosdep update --rosdistro $ROS2_DISTRO && \
  mkdir -p $ROS2_WS/src

WORKDIR $ROS2_WS

RUN cd src ; git clone https://github.com/stereolabs/zed-ros2-wrapper.git && \
    cd .. ; apt-get update -y && \
    . /opt/ros/$ROS2_DISTRO/setup.sh && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --symlink-install --cmake-args " -DCMAKE_BUILD_TYPE=Release" " -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs" " -DCUDA_CUDART_LIBRARY=/usr/local/cuda/lib64/stubs" " -DCMAKE_CXX_FLAGS='-Wl,--allow-shlib-undefined'"


# setup entrypoint
COPY ./ros2_entrypoint.sh /

ENTRYPOINT ["/ros2_entrypoint.sh"]
CMD ["bash"]