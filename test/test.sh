#!/bin/sh

FIRST_FAILED_SET_OF_TESTCASES="NOT SET"
FLAG_FIRST_FAILED_SET_OF_TESTCASES=0

echo_test() {
    printf '\n--%s--\n' "$1"
}

fail() {
    echo 'FAILURE'
    ret=1
    if [ $FLAG_FIRST_FAILED_SET_OF_TESTCASES -eq 0 ]; then
        FLAG_FIRST_FAILED_SET_OF_TESTCASES=1
        FIRST_FAILED_SET_OF_TESTCASES=$1
    fi
}

my_diff() {
    if ! diff "$1" "$2" -q; then
        fail "my diff"
    fi
}

ret=0

TESTCASE_NAME="f2s test"
echo_test $TESTCASE_NAME
if ! ./test/test_f2s.sh; then
    fail "$TESTCASE_NAME"
fi

TESTCASE_NAME="p2s_s2p integrity test"
echo_test $TESTCASE_NAME
if ! ./test/test_f2s_s2f_integrity.sh; then
    fail "$TESTCASE_NAME"
fi

TESTCASE_NAME="s2p test"
echo_test $TESTCASE_NAME
if ! ./test/test_s2f.sh ; then
    fail "$TESTCASE_NAME"
fi

if [ $ret -eq 1 ]; then
  echo ">>>>>One or more test cases have failed. The first failed set of testcases is $FIRST_FAILED_SET_OF_TESTCASES<<<<<"
fi

exit $ret
