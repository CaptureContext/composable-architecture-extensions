#!/bin/bash

SCRIPT_DIR_PATH="$( cd "$(dirname "$0")" && pwd )"

cd "${SCRIPT_DIR_PATH}/.."

NAME="ComposableExtensions"

WORKSPACE="${NAME}.xcworkspace"

rm -rf "${WORKSPACE}"
mkdir -p "${WORKSPACE}"

cat > "${WORKSPACE}/contents.xcworkspacedata" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Example/Example.xcodeproj">
   </FileRef>
   <FileRef
      location = "group:">
   </FileRef>
</Workspace>
EOL
