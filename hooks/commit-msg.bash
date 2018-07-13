#!/bin/bash
#set -x

TEXT_ERROR="\\033[1;31m"

SUCCESS=0
ERROR=1

# parse the ticket number from the branch name
# expects branches to be named either:
#    * TICKET-1234-some-branch-name
#    * ticketType/TICKET-1234-some-branch-name
# Any branch that starts with local/ is not validated
branch_name=$(git branch | grep '*' | sed 's/* //')

is_local_branch=$(echo ${branch_name} | grep 'local/')
if [ ! -z "$is_local_branch" ]; then
	exit ${SUCCESS}
fi

# the user's commit message is saved in a temp file, the path is passed as the argument to this hook
# $1 is the filepath, $(<$1) reads the contents of the file into the variable
commit_message=$(<$1)
# echo ${commit_message}

# check if message already includes a ticket number, exit successful if it does
commit_slug=$(echo ${commit_message} | sed 's/^\([a-zA-Z]*-[0-9]*\)[[:space:]].*/#####found ticket number#####/')
# echo ${commit_slug}
if [ "$commit_slug" != "$commit_message" ]; then
	exit ${SUCCESS}
fi

# parse the ticket number from the branch name
# expects branches to be named either:
#    * TICKET-1234-some-branch-name
#    * ticketType/TICKET-1234-some-branch-name
branch_name=$(git branch | grep '*' | sed 's/* //')
# echo ${branch_name}
ticket_number=$(echo ${branch_name} | sed 's|^\([a-zA-Z]*/\)\{0,1\}\([a-zA-Z]*-[0-9]*\)-.*$|\2|')
if [ "$branch_name" == "$ticket_number" ]; then
	printf "$TEXT_ERROR[ >>> COMMIT REJECTED - Ticket number missing in commit message & branch name ]\\n"
	printf "$TEXT_ERROR Malformed branch name. Branches should be named:\\n"
	printf "$TEXT_ERROR  * ticketType/TICKET-5-some-branch-name\\n"
	printf "$TEXT_ERROR  * TICKET-5-some-branch-name\\n"
	printf "$TEXT_ERROR If you absolutely need to commit this use git commit --no-verify\\n"
	printf "$TEXT_ERROR[ <<< COMMIT REJECTED - Ticket number missing in commit message & branch name ]\\n"

	exit ${ERROR}
fi

echo "${ticket_number} ${commit_message}" >| $1
