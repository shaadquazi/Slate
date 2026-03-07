#!/bin/bash

# Get the total number of commits
commit_count=$(git rev-list --count HEAD)

# Read current version from pubspec.yaml (excluding build number)
current_version=$(grep 'version: ' pubspec.yaml | sed 's/version: //; s/+.*//')

# New version with incremented build number
new_version="$current_version+$commit_count"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/version: .*/version: $new_version/" pubspec.yaml
else
  sed -i "s/version: .*/version: $new_version/" pubspec.yaml
fi

echo "Updated version to $new_version"
