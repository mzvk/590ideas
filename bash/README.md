detectsudo.sh: detects usage of sudo via two methods:
 + checks env variable `$SUDO_COMMAND` for script name itself (checks if shell is included)
 + checks for process with script name and `sudo`

iw_lock_kill.sh: short clean-up method for hung iceweasel/firefox locks
