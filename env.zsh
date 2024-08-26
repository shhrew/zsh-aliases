# Create file for env vars if it doesnt exist
if [ ! -f ~/.zshenv ]; then
    touch ~/.zshenv
fi

source ~/.zshenv

setenv() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: setenv <name>=<value>"
        return
    fi

    VAR_NAME="${1%%=*}"
    VAR_VALUE="${1#*=}"

    # Check if the provided argument contains '='
    if [ -z "$VAR_NAME" ] || [ "$VAR_NAME" = "$VAR_VALUE" ]; then
        echo "Invalid format. Use: setenv NAME=VALUE"
        return
    fi

    EXPORT_LINE="export $VAR_NAME=$VAR_VALUE"

    if grep -q "^export $VAR_NAME=" ~/.zshenv; then
        print "[\033[92m"+"\033[0m] The variable $VAR_NAME is already set, updating its value."
        sed -i "/^export $VAR_NAME=/c\\$EXPORT_LINE" ~/.zshenv
    else
        print "[\033[92m"+"\033[0m] Environment variable set: $VAR_NAME"
        echo "$EXPORT_LINE" >> ~/.zshenv
    fi

    source ~/.zshenv
}

unsetenv() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: unsetenv VAR_NAME"
        return 1
    fi

    VAR_NAME=$1
    unset $VAR_NAME

    if grep -q "^export $VAR_NAME=" ~/.zshenv; then
        sed -i.bak "/^export $VAR_NAME=/d" ~/.zshenv
        print "[\033[92m+\033[0m] Environment variable unset: $VAR_NAME"
    else
        print "[\033[91m!\033[0m] Variable $VAR_NAME not found in .zshenv"
    fi

    source ~/.zshenv
}

listenv() {
    grep '^export ' ~/.zshenv | sort | while IFS= read -r line; do
        var_name=$(echo "$line" | sed 's/^export \([^=]*\)=.*/\1/')
        var_value=$(eval echo \$$var_name)
        echo "$var_name=$var_value"
    done
}