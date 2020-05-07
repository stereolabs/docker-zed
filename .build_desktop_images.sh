push_images=false
build_latest_only_images=false

ubuntu_release_year=(
  16
  18
)

cuda_version=(
  "9.0"
  "10.0"
  "10.2"
)

zed_major_versions=(
  3
)

zed_minor_versions=(
  0
  1
  2
)

docker_image_variant=(
  devel
  gl-devel
  ros-devel
  runtime
)

pwd_path=$(pwd)

for ZED_SDK_MAJOR in "${zed_major_versions[@]}" ; do
    for ZED_SDK_MINOR in "${zed_minor_versions[@]}" ; do
        for CUDA_VERSION in "${cuda_version[@]}" ; do
            for UBUNTU_RELEASE_YEAR in "${ubuntu_release_year[@]}" ; do
                for IMAGE_VARIANT in "${docker_image_variant[@]}" ; do

                    if $build_latest_only_images; then
                        if [ ${ZED_SDK_MINOR} -ne ${zed_minor_versions[-1]} ] ; then
                            continue
                        fi
                    fi

                    CUDA_MAJOR_VERSION=$(echo $CUDA_VERSION | cut -f 1 -d '.')
                    CUDA_MINOR_VERSION=$(echo $CUDA_VERSION | cut -f 2 -d '.')

                    if [ ${UBUNTU_RELEASE_YEAR} == "16" ] ; then
                        ROS_DISTRO_ARG="kinetic"
                    elif [ ${UBUNTU_RELEASE_YEAR} == "18" ] ; then
                        ROS_DISTRO_ARG="melodic"
                        
                        # Not compatible with CUDA <= 9
                        if [ ${CUDA_MAJOR_VERSION} -le "9" ] ; then
                            continue
                        fi
                    fi

                    TAG_VERSION="${ZED_SDK_MAJOR}.${ZED_SDK_MINOR}-${IMAGE_VARIANT}-cuda${CUDA_MAJOR}.${CUDA_MINOR}-ubuntu${UBUNTU_RELEASE_YEAR}.04"
                    IMAGE_PATH="${ZED_SDK_MAJOR}.X/ubuntu/${IMAGE_VARIANT}"

                    cd "${IMAGE_PATH}"

                    echo "Building 'stereolabs/zed:${TAG_VERSION}'"

                    docker build --build-arg UBUNTU_RELEASE_YEAR=${UBUNTU_RELEASE_YEAR} \
                        --build-arg ZED_SDK_MAJOR=${ZED_SDK_MAJOR} \
                        --build-arg ZED_SDK_MINOR=${ZED_SDK_MINOR} \
                        --build-arg ROS_DISTRO_ARG=${ROS_DISTRO_ARG} \
                        --build-arg CUDA_MAJOR=${CUDA_MAJOR_VERSION} \
                        --build-arg CUDA_MINOR=${CUDA_MINOR_VERSION} \
                        -t "stereolabs/zed:${TAG_VERSION}" .

                    if $push_images; then
                        docker push "stereolabs/zed:${TAG_VERSION}"
                    fi

                    cd "${pwd_path}"
                    
                done
            done
        done
    done
done