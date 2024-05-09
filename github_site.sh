#!/bin/bash

# Process command-line options
while getopts "u:r:w:" opt; do
	case $opt in
		u) git_user="$OPTARG";;
		r) git_repo="$OPTARG";;
		w) url_option="$OPTARG";;
		*) echo "Invalid option"; exit 1;;
	esac
done

shift $((OPTIND - 1))

# Check if site_name is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide the site_name as an argument."
    echo "Example:  -u abarmpou -r angelos -w https://codingplusfun.com codingplusfun"
    exit 1
fi

site_name="$1"


if ! command -v httrack &> /dev/null; then
	echo "httrack is not installed. Installing httrack..."
	apt-get update
	apt-get install httrack
fi

# Store the container IP in a variable
container_port=$(docker port "$site_name"_wp | sed -n '1p' | cut -d ':' -f 2)
echo $container_port

if [ -d "$site_name/github" ]; then 
	echo "A local folder with the name '$site_name/github' exists. Please remove it." 
#	exit 1
else
	echo "Creating local folder '$site_name/github'..."
	mkdir -p "$site_name/github"
fi


cd "$site_name"/github || exit 1 # Navigate into the directory or exit 

httrack_folder="${url_option#*://}"

#We remove the previous version because httrack --update converts the urls to png images into html links.
rm -r "$httrack_folder"
rm -r "$git_repo"

if [ -d "$httrack_folder" ]; then
echo "Running httrack update..."
httrack --update
else
echo "Running httrack for the first time..."
httrack "$url_option"
fi

cp -r ../html/wp-content/uploads "$httrack_folder"/wp-content/

if [ -d "$httrack_folder/.git" ]; then
	echo "$httrack_folder contains .git"
	cd "$httrack_folder"
else
	git clone "git@github.com:$git_user/$git_repo.git" 
	cd "$git_repo" || exit 1
	echo "../$httrack_folder"
	mv ".git" "../$httrack_folder"
	cd "../$httrack_folder"
fi

echo "Replacing URLs..."
string_to_replace="$httrack_folder"
replacement_string="$git_user.github.io/$git_repo"
find . -type f -exec sed -i "s|$string_to_replace|$replacement_string|g" {} +

echo "Enforcing HTTPS..."
string_to_replace="http://"
replacement_string="https://"
find . -type f -exec sed -i "s|$string_to_replace|$replacement_string|g" {} +

echo "Removing HTTrack comments..."
pattern="^<!-- Mirrored from"
find . -type f -exec sed -i "/$pattern/d" {} +
pattern="^<!-- Added by"
find . -type f -exec sed -i "/$pattern/d" {} +

git add -A
git commit -m $(date +"%Y%m%d")
git push
cd - >/dev/null # Return to the previous directory (optional)

