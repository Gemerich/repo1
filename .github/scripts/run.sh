version=$(sed -n "s/version\":[[:space:]]*\"//p" package.json)
major=0
minor=0
revision=0
build=0

# break down the version number into it's components
regex="([0-9]+).([0-9]+).([0-9]{2})([0-9]+)"
if [[ $version =~ $regex ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    revision="${BASH_REMATCH[3]}"
    build="${BASH_REMATCH[4]}"
fi

if [[ "$1" == "beta" ]]; then
    # check paramater to see which number to increment
    if [[ "$2" == "major" ]]; then
        major=$(echo $major + 1 | bc)
        build=$(echo $build + 1 | bc)
        minor=0
        revision=00
    elif [[ "$2" == "minor" ]]; then
        minor=$(echo $minor + 1 | bc)
        build=$(echo $build + 1 | bc)
        revision=00
    elif [[ "$2" == "revision" ]]; then
        revision=$(echo $revision + 1 | bc)
        if (($revision < 10)); then
            revision="0${revision}"
        fi
        build=$(echo $build + 1 | bc)
    elif [[ "$2" == "build" ]]; then
        build=$(echo $build + 1 | bc)
    fi
fi

# echo the new version number
newversion=${major}.${minor}.${revision}${build}
echo "new version: ${newversion} $2"

search='("version":[[:space:]]*").+(")'
replace="\1${newversion}\2"

sed -iE "s/${search}/${replace}/g" "package.json"
rm "package.json.tmp"

git config user.name github-actions
git config user.email github-actions@github.com
git add .
git commit -m "Bump to ${newversion}"
git tag "v-${1}-release-${newversion}"
git push origin --tags
