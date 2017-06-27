#! /bin/sh

. dist/ansi_color.sh
disable_color

# Stop in case of error
set -e

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--color"|"-color")         set -- "$@" "-c";;
    "--grab"|"-grab")           set -- "$@" "-g";;
	"--img_build"|"-img_build") set -- "$@" "-i";;
	"--img_run"|"-img_run")     set -- "$@" "-r";;
	"--build"|"-build")         set -- "$@" "-b";;
	"--file"|"-file")           set -- "$@" "-f";;
	"--taskid"|"-taskid")       set -- "$@" "-t";;
    *) set -- "$@" "$arg"
  esac
done
# Parse args
while getopts ":i:b:f:t:r:cg" opt; do
  case $opt in
    c) enable_color;;
    g) GRAB_SRCS=1;;
    i) DOCKER_IMG_BUILD=$OPTARG;;
	r) DOCKER_IMG_RUN=$OPTARG;;
    b) BLD=$OPTARG ;;
    f) PKG_FILE=$OPTARG;;
    t) TASK=$OPTARG;;
    \?) printf "$ANSI_RED[BUILD-IN-DOCKER] Invalid option: -$OPTARG $ANSI_NOCOLOR\n" >&2; exit 1 ;;
    :)  printf "$ANSI_RED[BUILD-IN-DOCKER] Option -$OPTARG requires an argument $ANSI_NOCOLOR\n" >&2; exit 1 ;;
  esac
done

#---

build_runner() {
  mkdir runtmp && cd runtmp
  cp "../$PKG_FILE" "./ghdl.tgz"
  cp ../dist/linux/docker/runner--debian--stretch-slim ./Dockerfile
  docker build -t "$DOCKER_IMG_RUN" .
  cd .. && rm -rf runtmp
}

#---

if [ -n "$GRAB_SRCS" ]; then

  printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Grab sources$ANSI_NOCOLOR\n"

  p="curl -L https://github.com/tgingold/ghdl/archive/master.tar.gz | tar xz"
  p="$p && mv ghdl-master/* ./ && rm -rf ghdl-master"

  printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Docker build $BLD in $DOCKER_IMG_BUILD to $PKG_FILE $ANSI_NOCOLOR\n"
  
  set +e
  
  docker run -t \
    --name ghdl_cmp \
	-w="/work" \
    "$DOCKER_IMG_BUILD" sh -c "$p && ./dist/linux/build.sh $ENABLECOLOR-t $TASK -b $BLD -f $PKG_FILE"

  rc=$?; if [ $rc -eq 0 ]; then
    docker cp "ghdl_cmp:/work/log.log" "./log.log"
    docker cp "ghdl_cmp:/work/$PKG_FILE" ./
    printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Docker build image $DOCKER_IMG_RUN $ANSI_NOCOLOR\n"
	build_runner "$DOCKER_IMG_RUN"
  fi
  
  docker rm ghdl_cmp
  
  set -e
  
else

  printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Docker build $BLD in $DOCKER_IMG_BUILD to $PKG_FILE $ANSI_NOCOLOR\n"

  set +e
  
  docker run --rm -t \
    -v /$(pwd):/work \
    -w="/work" \
    "$DOCKER_IMG_BUILD" sh -c "./dist/linux/build.sh $ENABLECOLOR-t $TASK -b $BLD -f $PKG_FILE"

  rc=$?; if [ $rc -eq 0 ]; then
    set -e
    `command -v sudo` chown -R $USER:$USER ./
    printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Docker build image $DOCKER_IMG_RUN $ANSI_NOCOLOR\n"
    build_runner 1>> ./imglog.log 2>&1
    printf "$ANSI_YELLOW[$TASK| BUILD-IN-DOCKER] Docker run testsuite in $DOCKER_IMG_RUN $ANSI_NOCOLOR\n"
	set +e
	docker run --rm -t \
      -v /$(pwd)/testsuite:/work \
      -w="/work" \
      "$DOCKER_IMG_RUN" sh -c "ENABLECOLOR=$ENABLECOLOR TASK=$TASK GHDL=ghdl ./testsuite.sh"
	set -e
	cat testsuite/log.log >> log.log
  fi
  
  set -e
  
  if [ "$DOCKER_IMG_BUILD" = "debian--stretch-slim" ]; then
    docker tag "$DOCKER_IMG_BUILD" "ghdl/builder:latest"
    docker tag "$DOCKER_IMG_RUN" "ghdl/runner:latest-$BLD"
  fi
  
fi

#---

# Do not remove this line, and don't write anything below, since it is used to identify successful runs
echo "[$TASK|SUCCESSFUL]" 1>> log.log 2>&1