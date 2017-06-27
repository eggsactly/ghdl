#! /bin/sh
# This script is executed in a ci environment.

# Defaults
images=("ghdl/ghdl-tools:ubuntu-mcode" "ghdl/ghdl-tools:ubuntu1404-llvm" "ghdl/ghdl-tools:ubuntu1204-llvm" "ghdl/ghdl-tools:fedora-llvm-mcode" "ghdl/builder:debian--sid-slim" "ghdl/builder:debian--stretch-slim")

#task format: <image index> + <tartag> + <compiler>

#regular="0+ubuntu+mcode 3+fedora+llvm"
regular="5+debian-stretch+llvm 5+debian-stretch+mcode" # 4+debian+llvm"
nightly="1+ubuntu1404+llvm-3.5 2+ubuntu1204+llvm-3.8 3+fedora+mcode"
#release=()

tasks=regular

#---

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--images"|"-images")   set -- "$@" "-i";;
	"--tasks"|"-tasks") set -- "$@" "-t";;
    *) set -- "$@" "$arg"
  esac
done
# Parse args
while getopts ":i:b:f:t:cg" opt; do
  case $opt in
    i) images=$OPTARG;;
    t) tasks=$OPTARG;;
    \?) printf "$ANSI_RED[BUILD-IN-DOCKER] Invalid option: -$OPTARG $ANSI_NOCOLOR\n" >&2; exit 1 ;;
    :)  printf "$ANSI_RED[BUILD-IN-DOCKER] Option -$OPTARG requires an argument $ANSI_NOCOLOR\n" >&2; exit 1 ;;
  esac
done

#---
. dist/ansi_color.sh
#disable_color

#---
# USAGE: get_builder <REPOSITORY>/<IMAGE>:<TAG>
get_builder() {
  repo=$(echo "$1" | cut -d "/" -f 1)
  tag=$(echo "$1" | cut -d "/" -f 2)
  img=$(echo "$tag" | cut -d ":" -f 1)
  tag=$(echo "$tag" | cut -d ":" -f 2)
  
  # Is it locally available?
  if [ -z "$(docker images -q $1 2> /dev/null)" ]; then
    islocal="";
	echo "Image $1 not available locally";
  else
    islocal="true";
  fi

  # Is it available on the docker hub?
  ishub=$(wget -S -qO- http://registry.hub.docker.com/v2/repositories/$repo/$img/tags 2>&1 | grep 'HTTP/1.1 200 OK')
  if [ -z "$ishub" ]; then 
	ishub=""
	echo "Image $1 not available on the hub"
  else
    ishub=$(wget -qO- http://registry.hub.docker.com/v2/repositories/$repo/$img/tags)
	if [ -z "$(echo $ishub | grep $tag)" ]; then
	  echo "Tag $repo/$img:$tag not available on the hub"
	  ishub=""
	fi
  fi

  if [ -z "$islocal" ]; then
    if [ -z "$ishub" ]; then
	  file="dist/linux/docker/$img--$tag"
	  if [ -f "$file" ]; then
	    echo "Building image $repo/$img:$tag"
        mkdir tmp && cd tmp
        cp "../$file" ./Dockerfile
        docker build -t "$repo/$img:$tag" . 1>> ../imglog.log 2>&1
        cd .. && rm -rf tmp
      else
	    echo "$file not found."
		EXITCODE="$file"
      fi
	else
	  docker pull $1
	fi
  else
    if [ -z "$ishub" ]; then
	  echo "Using local image $1"
	#else
	  #TODO: parse $ishub (JSON) to get the version (or date of last update)
      #      compare local and remote, and pull the remote if newer
	  #docker pull $1	
	fi
  fi
}

#---
# USAGE: task <TASK_NUMBER> <DOCKER_IMAGE> <COMPILER> <TARBALL_TAG>
task() {
  thisworkdir="../wrk-$1"
  cp -r ./ "$thisworkdir" && cd "$thisworkdir"
  
  (
  ./dist/linux/buildtest-in-docker.sh \
    -t "$1" \
    -i "$2" \
	-r "$(echo "$2" | sed -e 's/builder/runner/g')--$3" \
    -b "$3" \
    -f "ghdl-$PKG_VER-$3-$PKG_TAG-$4-$PKG_SHORTCOMMIT.tgz" \
    $ENABLECOLOR
  )
   
  rc=$?;
  if [ $rc -ne 0 ]; then
    EXITCODE="$1"
  else
    cp ghdl-*.tgz "$cloned/"
  fi
  
  cp log.log "$cloned/log_$1.log"
  cp imglog.log "$cloned/imglog_$1.log"
  cd .. && rm -rf "$thisworkdir"
}

#---

EXITCODE=0;
PKG_SHORTCOMMIT="$(printf "%s" $FACTORY_COMMIT | cut -c1-10)"
PKG_VER=`grep Ghdl_Ver src/version.in | sed -e 's/.*"\(.*\)";/\1/'`
PKG_TAG="$FACTORY_TAG"
if [ -z "$FACTORY_TAG" ]; then PKG_TAG=`date -u +%Y%m%d`; fi

cloned=$(pwd)

printf "$ANSI_YELLOW[FACTORY] Running matrix $tasks $ANSI_NOCOLOR\n"
eval blds='${'$tasks'}'
t=0; for thisbuild in $blds; do
  IFS='+' read -ra REFS <<< "$thisbuild"
  thisimg="${images[${REFS[0]}]}"
  thisbld="${REFS[2]}"
  thistartag="${REFS[1]}"

  printf "$ANSI_YELLOW[$t| GET] Docker image $thisimg $ANSI_NOCOLOR\n"  
  get_builder "$thisimg"
  printf "$ANSI_YELLOW[$t| TASK] Init $ANSI_NOCOLOR\n"
  echo "image: $thisimg"
  echo "build: $thisbld"
  echo "tartag: $thistartag"
  
  if [ -z "$(docker images -q $thisimg 2> /dev/null)" ]; then
    echo "Image $thisimage not available. Task $t aborted" > "$cloned/log_$t.log"
  else
    task "$t" "$thisimg" "$thisbld" "$thistartag" "$ENABLECOLOR" &
  fi
  t=$(($t+1));
done

printf "$ANSI_YELLOW[FACTORY] Waiting... $ANSI_NOCOLOR\n"
wait
cd "$cloned"
printf "$ANSI_YELLOW[FACTORY] Done waiting. Show work dir content: $ANSI_NOCOLOR\n"
ls -la
#printf "$ANSI_YELLOW[FACTORY] Check build and test results $ANSI_NOCOLOR\n"
#t=0; for b in $blds; do
#  # Read the last line of the log
#  RESULT[$t]=$(awk '/./{line=$0} END{print line}' "log_$t.log")
#  # If it did not end with [$t|SUCCESSFUL], break the build
#  if [ "${RESULT[$t]}" != "[$t|SUCCESSFUL]" ]; then EXITCODE=$(($t+1)); fi
#  # Anyway, always print the full log
#  printf "$ANSI_YELLOW[FACTORY] Print log of task $t $ANSI_NOCOLOR\n"
#  cat "log_$t.log"
#  printf "$ANSI_YELLOW[FACTORY] Print imglog of task $t $ANSI_NOCOLOR\n"
#  cat "imglog_$t.log"
#  t=$(($t+1));
#done

#if [ -f "imglog.log" ]; then
#  printf "$ANSI_YELLOW[FACTORY] Print main imglog $ANSI_NOCOLOR\n"
#  cat imglog.log
#fi

docker images

# The exit code indicates the last broken build (1:bnum)
return $EXITCODE