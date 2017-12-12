#! /bin/sh

set -e

. dist/linux/travis-utils.sh
. dist/ansi_color.sh
#disable_color

scriptdir=$(dirname $0)

currentdir="${scriptdir}/docker/ext"
for f in `ls $currentdir`; do
    for tag in `grep -oP "FROM.*AS do-\K.*" ${currentdir}/$f`; do
        echo "travis_fold:start:$tag"
        travis_time_start
        printf "$ANSI_BLUE[DOCKER build] ext : ${tag}$ANSI_NOCOLOR\n"
        docker build -t ghdl/ext:${tag} --target do-$tag - < ${currentdir}/$f
        travis_time_finish
        echo "travis_fold:end:$tag"
    done
done

#docker build -t ghdl/ext:vunit --target vunit - < ./dist/linux/docker/ext/vunit
#docker build -t ghdl/ext:vunit-gtkwave --target vunit-gtkwave - < ./dist/linux/docker/ext/vunit
