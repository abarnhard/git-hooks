# git-hooks
This repo is a set of githooks you can add to your git repo to automate validation.
Currently it includes:
* pre-commit - A script to check if you've left debugging commands on accident
* commit-msg - A script to add Jira ticket numbers to your commit messages if you want them
    * has a bash & sh version, both do the same thing, the sh version is compatible with non-bash shells

### Setup
Ensure load-hook.sh is executable. If not, run `chmod +x load-hook.sh`

### Usage
Run the load-hook.sh with the path to the hook you want and the root of the git repo you want to add it to.
```
./load-hook.sh ./hooks/commit-msg.sh ../ingram_iq
```
Will load the commit-msg hook to the ingram_iq repo. Once loaded, any attempt to make a commit when both the message and the branch name are missing 
a Jira ticket number will fail
