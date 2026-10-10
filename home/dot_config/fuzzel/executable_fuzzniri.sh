#!/usr/bin/env sh

Help() {
    echo "This is a window switcher for niri"
}

while getopts 'ht:' option; do
    case "${option}" in
        h) #display help
            Help
            exit
            ;;
        t) #set type
            type="${OPTARG}"
            ;;
        *)
            echo 'Error in command line parsing' >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

type=${type:='all'}

all_windows=$(niri msg -j windows | \
    jq -r '.[] | select(.is_focused == false) | [.id, .title, .app_id] | @tsv' | \
    awk 'BEGIN {
        FS="\t";
        OFS="\t";
        # Define all your icon substitutions here
        icons["Brave-browser"] = "brave-browser"
        icons["obsidian"] = "Obsidian"
    }
    {
        # Check if the app_id exists as a key in our array
        if ($3 in icons) {
            $3 = icons[$3]  # If it exists, replace it
        }
        print $1, $2, "\\0icon\\x1f"$3
    }')
selected=$(echo -en "${all_windows}" | fuzzel --dmenu --anchor=top-left --accept-nth=1 --with-nth=2)

[ -z "${selected}" ] && exit 130
niri msg action focus-window --id "${selected}"
