#!/bin/sh
## Uninstaller for sample-trace2-otel-collector (as installed by the release .pkg)
##################################################################

set -x

INSTALL_LOCATION=/usr/local/sample-trace2-otel-collector

echo "Stopping service..."
if [ -e $INSTALL_LOCATION/scripts/service_stop ]
then
	## Force stop the service.
	$INSTALL_LOCATION/scripts/service_stop
fi

echo "Disassociate from Launchctl..."
/bin/rm -f /Library/LaunchDaemons/com.git-ecosystem.sample-trace2-otel-collector.plist

echo "Unset system config variables set by scripts/postinstall..."

for g in /usr/bin/git /usr/local/bin/git
do
	if [ -x "$g" ]
	then
		$g config --system --unset trace2.eventtarget
		$g config --system --unset trace2.configparams
	fi
done

echo "Removing application directory $INSTALL_LOCATION..."
/bin/rm -rf $INSTALL_LOCATION
