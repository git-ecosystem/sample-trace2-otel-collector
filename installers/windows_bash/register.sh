#!/bin/sh
# A script to register our service with the control panel service manager.
set -x
set -v

MyVer=X_VER_X
MyAppName=sample-trace2-otel-collector
MyDisplayName="Sample Trace2 OpenTelemetry Collector"
MyDescription="Relay Git telemetry to OpenTelemetry ${MyVer}"
MyExe="sample-trace2-otel-collector.exe"

# In your `config.yml`, you must set the named pipe pathname.  This value
# must match that.
MyPipe="//./pipe/sample-trace2-otel-collector"

# In your (optional) `filter.yml`, you should set a common prefix for
# the nickname and ruleset keys.  This wildcard must match that.
MyNamespace='otel.trace2.*'

# I'm going assume that you have already installed the service exe and
# the various config files here:

MyProgramFilesDir="C:/Program Files/$MyAppName"
MyProgramDataDir="C:/ProgramData/$MyAppName"

SC="C:/Windows/System32/sc.exe"

# Shutdown and remove any previous version of our service.  This is
# mainly to help flush it from the list of services in the control
# panel app.

$SC stop $MyAppName
$SC delete $MyAppName

# Register our service. We have to name the `config.yml` file here
# as part of the command line because the OTEL SVC.Start handler
# only uses `os.Args` and does not look at the `Args` from the
# service start dialog.
#
# We need to use an absolute path to the `config.yml` because the
# service CWD will be in `C:/Windows/System32` when it starts. We
# should likewise use absolute paths for any `pii.yml`, `filter.yml`,
# and rulesets.  I'm going to assume you want them in ProgramData
# rather than next to the executable.
#
# If the any of these commands fail because of a "marked for deletion"
# error from the above, make sure you don't have the control panel
# services (services.msc) app open (also mmc.msc). They seem to hold
# a lock on the registry data.

$SC create $MyAppName \
    binPath= "$MyProgramFilesDir/$MyExe --config $MyProgramDataDir/config.yml" \
    displayName= "$MyDisplayName" \
    start= auto || exit 1
$SC description $MyAppName "$MyDescription"
$SC start $MyAppName || exit 1

# Tell Git to send Trace2 telemetry to us.

git config --global trace2.configparams $MyNamespace
git config --global trace2.eventtarget $MyPipe
git config --global --list --show-origin | grep -i trace2
