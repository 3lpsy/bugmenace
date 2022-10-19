#!/bin/bash

set -e;

if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    SUDOER="ubuntu"
else
    SUDOER="vagrant"
fi

#echo 'export PS1="\[$(tput bold)\]\[\033[38;5;88m\]@\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;105m\]\u\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;45m\]\W\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;13m\]>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' | sudo tee -a /root/.bashrc

#if [[ -d /home/${SUDOER} ]]; then 
    #echo 'export PS1="\[$(tput bold)\]\[\033[38;5;88m\]@\[$(tput sgr0)\]\[\033[38;5;196m\]\h\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;105m\]\u\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;45m\]\W\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;13m\]>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"' | sudo tee -a /home/$SUDOER/.bashrc
    #sudo chown ${SUDOER}:${SUDOER} /home/$SUDOER/.bashrc;
#fi
