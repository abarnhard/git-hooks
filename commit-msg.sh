#!/bin/sh

TEXT_DEFAULT="\\033[0;39m"
TEXT_INFO="\\033[1;32m"
TEXT_ERROR="\\033[1;31m"
TEXT_YELLOW="\\033[1;33m"

SUCCESS=0
ERROR=1

# the user's commit message is saved in a temp file, the path is passed as the argument to this hook
# $1 is the filepath, $(<$1) reads the contents of the file into the variable
commit_message=$(<$1)
echo ${commit_message}

# check if message already includes a ticket number, exit successful if it does
commit_slug=$(echo ${commit_message} | sed 's/^\([a-zA-Z]*-[0-9]*\)[[:space:]].*/#####found ticket number#####/')
echo ${commit_slug}
if [ "$commit_slug" != "$commit_message" ]; then
	exit ${SUCCESS}
fi

# parse the ticket number from the branch name
# expects branches to be named either:
#    * BID-1234-some-branch-name
#    * ticket_type/BID-1234-some-branch-name
branch_name=$(git branch | grep '*' | sed 's/* //')
echo ${branch_name}
ticket_number=$(echo ${branch_name} | sed 's|^\([a-zA-Z]*/\)\{0,1\}\([a-zA-Z]*-[0-9]*\)-.*$|\2|')
if [ "$branch_name" == "$ticket_number" ]; then
  echo "$TEXT_ERROR[ >>> COMMIT REJECTED ]" &&
	echo "$TEXT_ERROR""Error: malformed branch name" &&
	echo "$TEXT_ERROR""branches should be named ticket_type/ticket_number-branch description or ticket_number-branch-description" &&
	echo "$TEXT_ERROR""If you absolutely need to commit this use git commit --no-verify"

	exit ${ERROR}
fi

echo "${ticket_number} ${commit_message}" >| $1
