#! /bin/bash -e

echo "Let's refresh Xcode"
echo "Closing Xcode app..."

killall Xcode

echo "Closed"
echo "Removing cache..."
rm -rf /Users/daviddrobny/Library/Developer/Xcode/DerivedData/AR*

echo "Removed"

sleep 1

echo "Starting xcode..."

open /Users/daviddrobny/Projects/thesis/app/ARapp/ARExperiment.xcodeproj
