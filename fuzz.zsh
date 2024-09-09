alias enumports="python -c 'print(\"\n\".join(str(i) for i in range(1, 65536)))'"

vhost() {
    if [ "$#" -lt 1 ]; then
        echo "[i] Usage: vhost <domain> (extra arguments)"
        return 1
    fi

    local domain=$1
    if [[ ! "$domain" =~ ^https?:// ]]; then
        url="http://$domain"
    else
        url=$domain
        domain=${url/https:\/\//} # ${main_string/search_term/replace_term}
    fi

    local wordlist="$HOME/wordlists/seclists/Discovery/DNS/bitquark-subdomains-top100000.txt"
    ffuf -H "Host: FUZZ.$domain" -u $url -w "$wordlist" "${@:2}"
}