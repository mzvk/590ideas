#!/bin/bash
#
# clears locks of iceweasel and firefox
# @Zvk : 2016
#

echo; echo "- finding iw/ff locks"
if [[ -z `find ~/.mozilla -name *lock` ]]; then
	echo "- no files found"
else
	echo "- $(find ~/.mozilla -name *lock | wc -l) files removed"
	find ~/.mozilla -name *lock | xargs rm
fi
echo
