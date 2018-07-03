#!/bin/bash
#set -x

SUCCESS=0
ERROR=1

commit_slug=""
gawk_path=""

# check if gawk dependency is installed
gawk_path=$(which gawk)
if [[ -z gawk_path ]]; then
	echo "commit-msg githook requires gawk to be installed" && \
	echo "on Mac run 'brew install gawk'" && \
	echo "aborting commit, to override use \"git commit --no-verify ...\""

	exit ${ERROR}
fi

# the user's commit message is saved in a temp file, the path is passed as the argument to this hook
# $1 is the filepath, $(<$1) reads the contents of the file into the variable
commit_message=$(<$1)
echo ${commit_message}

# check if message already includes a ticket number, exit successful if it does
commit_slug=$(echo ${commit_message} | gawk '{ match($0, /^(\w+-[0-9]+)/, arr); print arr[1] }')
echo ${commit_slug}
if [[ -n $commit_slug ]]; then
	exit ${SUCCESS}
fi

# parse the ticket number from the branch name
# expects branches to be named either:
#    * BID-1234-some-branch-name
#    * ticket_type/BID-1234-some-branch-name
branch_name=$(git branch | grep '*' | sed 's/* //')
echo ${branch_name}
ticket_number=$(echo ${branch_name} | gawk '{ match($0, /^(\w+\/)?(\w+-[0-9]+)/, arr); print arr[2] }')
if [[ -z $ticket_number ]]; then
	echo "Error: malformed branch name" && \
	echo "branches should be named ticket_type/ticket-number" && \
	echo "aborting commit, to override use \"git commit --no-verify ...\""

	exit ${ERROR}
fi

echo "${ticket_number} ${commit_message}" >| $1
