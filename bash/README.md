detectsudo.sh: detects usage of sudo via two methods:
 + checks env variable `$SUDO_COMMAND` for script name itself
 + checks for process with script name and `sudo`
