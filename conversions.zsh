convert_sid() {
    local binary_sid="$1"

    # Remove any single quotes and 'b' prefix if present
    binary_sid=$(echo "$binary_sid" | sed "s/^b'//" | sed "s/'$//")

    # Convert hex to binary and parse SID structure
    local sid_hex=$(echo "$binary_sid" | cut -c 1-2)
    local revision=$(printf "%d" "0x$sid_hex")

    local subauth_count_hex=$(echo "$binary_sid" | cut -c 3-4)
    local subauth_count=$(printf "%d" "0x$subauth_count_hex")

    local authority_hex=$(echo "$binary_sid" | cut -c 5-16)

    # Convert 48-bit authority (big-endian)
    local authority=0
    for ((i=0; i<12; i+=2)); do
        local byte=$(echo "$authority_hex" | cut -c $((i+1))-$((i+2)))
        authority=$((authority * 256 + 0x$byte))
    done

    # Build SID string
    local sid_string="S-$revision-$authority"

    # Process sub-authorities (little-endian)
    local pos=17
    for ((i=0; i<subauth_count; i++)); do
        local subauth_hex=$(echo "$binary_sid" | cut -c $((pos))-$((pos+7)))
        local subauth=0

        # Convert little-endian hex to decimal
        for ((j=6; j>=0; j-=2)); do
            local byte=$(echo "$subauth_hex" | cut -c $((j+1))-$((j+2)))
            subauth=$((subauth * 256 + 0x$byte))
        done

        sid_string="$sid_string-$subauth"
        pos=$((pos + 8))
    done

    echo "$sid_string"
}

ntlm_hash() {
    local password="$1"
    local uppercase="${2:-true}"  # Optional: output in uppercase

    if [[ -z "$password" ]]; then
        echo "Usage: ntlm_hash <password> <uppercase>"
        echo "Example: ntlm_hash 'mypassword'"
        echo "Example: ntlm_hash 'mypassword' true"
        return 1
    fi

    # Create NTLM hash
    local hash
    hash=$(echo -n "$password" | iconv -f UTF-8 -t UTF-16LE | openssl dgst -md4 -binary | xxd -p | tr -d '\n')

    if [[ "$uppercase" == "true" ]]; then
        echo "$hash" | tr '[:lower:]' '[:upper:]'
    else
        echo "$hash"
    fi
}