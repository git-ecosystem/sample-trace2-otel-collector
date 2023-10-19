#!/bin/sh
# A script to unregister and remove our service from the control panel
# service manager.  We DO NOT delete Program Files nor ProgramData; we
# are only unregistering with the system, not uninstalling it.

set -x
set -v

MyAppName=sample-trace2-otel-collector

SC="C:/Windows/System32/sc.exe"

# Tell Git to stop sending Trace2 telemetry to us.
git config --global --unset trace2.configparams
git config --global --unset trace2.eventtarget
git config --global --list --show-origin | grep -i trace2

# Shutdown and remove any previous version of our service.  This is
# mainly to help flush it from the list of services in the control
# panel app.
$SC stop $MyAppName || exit 0
$SC delete $MyAppName || exit 0
