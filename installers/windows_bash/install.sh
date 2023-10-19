#!/bin/sh
# A script to install our service into Program Files and ProgramData.
set -x
set -v
set -e

MyVer=X_VER_X
MyAppName=sample-trace2-otel-collector
MyExe="sample-trace2-otel-collector.exe"

# We split the distribution into "Program Files" and "ProgramData".

MyProgramFilesDir="C:/Program Files/$MyAppName"
MyProgramDataDir="C:/ProgramData/$MyAppName"

mkdir -p "$MyProgramFilesDir"
mkdir -p "$MyProgramDataDir"

cp $MyExe "$MyProgramFilesDir/"
cp *.sh "$MyProgramFilesDir/"

cp *.yml "$MyProgramDataDir/"
