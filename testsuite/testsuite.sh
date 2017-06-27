#! /bin/sh

. ./testenv.sh

flag_log=yes
tests=

for opt; do
  case "$opt" in
      --nolog) flag_log=no ;;
      [a-z]*) tests="$tests $opt" ;;
      *) echo "$0: unknown option $opt"; exit 2 ;;
  esac
done

if [ x$tests = x ]; then tests="gna vests"; fi

printf "$ANSI_BLUE[$TASK| GHDL] Test - sourced the testsuite environment $ANSI_NOCOLOR\n"
printf "$ANSI_BLUE[$TASK| GHDL] Test - GHDL is: $GHDL $ANSI_NOCOLOR\n"

run() { ./testsuite.sh; }
if [ $flag_log = yes ]; then run() { ./testsuite.sh 1>> ./log.log 2>&1; }; fi

# Run a testsuite
do_test() {
  printf "$ANSI_BLUE[$TASK| GHDL] Test - $1 $ANSI_NOCOLOR\n"
  printf "Running testsuite $1\n" >> log.log
  case $1 in
      # The GNA testsuite: regression testsuite using reports/issues from gna.org
      gna) ;;
      # The VESTS testsuite: compliance testsuite, from: https://github.com/nickg/vests.git 388250486a
      vests) gnatmake get_entities 1>> ../log.log 2>&1;;
      *)
          printf *e "$ANSI_RED$0: test name '$1' is unknown $ANSI_NOCOLOR"
          exit 1;;
  esac
  cd "$1"
  run
  cd ..
}

for t in $tests; do do_test $t; done

printf "$ANSI_BLUE[$TASK| GHDL] Test: $ANSI_GREEN SUCCESS $ANSI_NOCOLOR\n"
$GHDL --version 1>> ./log.log 2>&1
exit 0
