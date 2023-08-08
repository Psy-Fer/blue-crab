#!/bin/sh

# MIT License

# Copyright (c) 2020 Hiruna Samarakoon
# Copyright (c) 2020 Sasha Jenner
# Copyright (c) 2020,2023 Hasindu Gamaarachchi

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

TESTCASE_NAME="p2s test"
echo_test $TESTCASE_NAME
if ! ./test/test_p2s.sh; then
    fail "$TESTCASE_NAME"
fi

TESTCASE_NAME="p2s_s2p integrity test"
echo_test $TESTCASE_NAME
if ! ./test/test_p2s_s2p_integrity.sh; then
    fail "$TESTCASE_NAME"
fi

TESTCASE_NAME="s2p test"
echo_test $TESTCASE_NAME
if ! ./test/test_s2p.sh ; then
    fail "$TESTCASE_NAME"
fi

if [ $ret -eq 1 ]; then
  echo ">>>>>One or more test cases have failed. The first failed set of testcases is $FIRST_FAILED_SET_OF_TESTCASES<<<<<"
fi

exit $ret
