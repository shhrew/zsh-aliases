source $(dirname "$0")/env.zsh
source $(dirname "$0")/fuzz.zsh

# Misc
ips() {
  if [ -z "$1" ]; then
      ip a show scope global | awk '/^[0-9]+:/ { sub(/:/,"",$2); iface=$2 } /^[[:space:]]*inet / { split($2, a, "/"); print "[\033[92m" iface"\033[0m] "a[1] }'
      return
  fi

  # Adapter specified by the user
  ADAPTER=$1

  # Check if the specified adapter exists
  if ifconfig $ADAPTER > /dev/null 2>&1; then
      # Extract the IP address and copy it to the clipboard
      IP_ADDRESS=$(ifconfig $ADAPTER | grep 'inet ' | awk '{print $2}' | tr -d '\n')

      # Check if IP_ADDRESS is not empty
      if [ -n "$IP_ADDRESS" ]; then
          echo -n "$IP_ADDRESS" | xclip -sel clip
          print "[\033[92m"$ADAPTER"\033[0m] $IP_ADDRESS copied to clipboard!"
      else
          print "[\033[91m"$ADAPTER"\033[0m] No IP address found for adapter"
      fi
  else
      print "[\033[91m"$ADAPTER"\033[0m] No adapter found with that name"
  fi
}

lspwd() {
  echo -e "[\e[92m`pwd`\e[0m]\e[34m" && ls && echo -en "\e[0m"
}

mkdircd() {
  mkdir $1 && cd $_
}

addhost() {
    if [ "$#" -ne 2 ]; then
      echo "[i] Usage: addhost <ip> <hostname>"
      return 1
    fi

    ip="$1"
    hostname="$2"
    if grep -q "^$ip" /etc/hosts; then
      sudo sed -i "/^$ip/s/$/ $hostname/" /etc/hosts
      print "[\033[92m"+"\033[0m] Appended $hostname to existing entry for $ip in /etc/hosts"
    else
      echo "$ip $hostname" | sudo tee -a /etc/hosts > /dev/null
      print "[\033[92m"+"\033[0m] Added new entry: $ip $hostname to /etc/hosts"
    fi

    grep "^$ip" /etc/hosts
}

cleanup() {
  echo -n > ~/.zsh_history
  sudo find /var/log -type f -regextype posix-extended -regex '.*\.[0-9]+(\.[^/]+)?$' -delete
  for i in $(sudo find /var/log -type f); do sudo sh -c "cat /dev/null > $i"; done
}

alias www="lspwd && sudo python3 -m http.server 80"
alias stty_fix="stty raw -echo; fg; reset"
alias stty_conf="stty -a | sed 's/;//g' | head -n 1 | sed 's/.*baud /stty /g;s/line.*//g' | xclip -sel clip"