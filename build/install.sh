#!/bin/sh

# Text color variables
TEXT_BOLD=$(tput bold)                    # Bold
BOLD_GREEN=${TEXT_BOLD}$(tput setaf 2)    # green
bldwht=${TEXT_BOLD}$(tput setaf 7)        # white
TEXT_RESET=$(tput sgr0)                   # Reset
INFO_COLOR=${bldwht}*${TEXT_RESET}        # Feedback


/bin/echo -en "$INFO_COLOR adding galera_watchdog user ..."
/usr/sbin/useradd -s /usr/sbin/nologin -r -M galera_watchdog
/bin/echo $BOLD_GREEN "[ok] ${TEXT_RESET}"

/bin/echo -en "$INFO_COLOR enable galera_watchdog service ..."
/bin/systemctl enable galera_watchdog
/bin/echo $BOLD_GREEN "[ok] ${TEXT_RESET}"

/bin/echo -en "$INFO_COLOR starting galera_watchdog service ..."
/bin/systemctl start galera_watchdog
/bin/echo $BOLD_GREEN "[ok] ${TEXT_RESET}"
