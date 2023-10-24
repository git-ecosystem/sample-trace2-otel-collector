# Sample Trace2 OpenTelemetry Collector

This directory contains a sample custom collector to read
Trace2 telemetry from Git commands, transform it into OTLP,
and export it to various OpenTelemetry data sinks.

You can use this demonstration collector to quickly evaluate the
[`trace2receiver`](https://github.com/git-ecosystem/trace2receiver)
technology and before building your own telemetry solution.

The collector source code (`./*.go` and `./go.*`) distributed
in this repository was generated automatically by the OpenTelemetry
builder tool (as explained below). Its purpose is to quick start
your evaluation.

* NOTE Once you become familiar with the technology,
you'll want to fork the repo, download the most recent version
of the builder tool, and regenerate the source code. This is
especially true if you want to include other exporter components
that I didn't include in the demonstration version.

Also included in this repository is a set of Makefiles and scripts
to build distribution/installer packages for the collector on each
of the major platforms. The collector is designed to run as a
long-running service daemon and these scripts will help you
start building your own packages. These scripts cover the basic
setup, but omit some details, like package signing.

* NOTE Before generating deployment packages, you'll want to:
  * Configure your `config.yml` (as explained below) to talk to your chosen telemetry data sink or cloud provider.
  * Create any additional `pii.yml`, `filter.yml`, and rulesets so that your distribution packages will be pre-configured when you deploy them to your users.
  * Rename the example collector exectuable, pathnames, and assets to reflect your organization.



## Generating/regenerating the sample collector

The GOLANG source was generated using the OpenTelemetry
[builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder)
tool and the `builder-config.yml` definition.  This YML file
defines the various receiver, pipeline, and exporter components
that will be statically linked into the custom collector executable.
If you want to add or remove a component, update the YML file
and re-run the builder tool.

```
$ GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@latest 
$ ~/go/bin/builder --config ./builder-config.yml
$ go build
$ go test
```

The `builder-config.yml` file provided here contains a basic set of components to get you started.
The [`trace2receiver`](https://github.com/git-ecosystem/trace2receiver) component
has additional [details](https://github.com/git-ecosystem/trace2receiver/blob/main/Docs/).

The `go` commands will automatically pull in the `trace2receiver`
component as a dependent module in the normal GOLANG way. You may
want to update the version numbers of any dependent modules at this time.



## Configuring the sample collector

Once built, your collector requires another YML file to tell it which (of the
statically linked components) to actually instantiate, how to plumb data
between them, and set any configuration parameters (such as cloud credentials
for your data sink(s) or other pathnames).

The `sample-configs/*/config.yml` files provided here contains a minimal set of components to log
telemetry to the console or system event viewer. They assume that:
* On Linux and macOS: you will install the collector executable and
the various YML files into `/usr/local/sample-trace2-otel-collector/`.
* On Windows: you will install the executable into `C:/Program Files/sample-trace2-otel-collector/` and
the various YML data files into `C:/ProgramData/sample-trace2-otel-collector/`.

_(The named pipe pathname is not in the ProgramData directory, since
named pipes must be created on the Named Pipe File System (NPFS) and
have the `//./pipe/` prefix.)_

The `trace2receiver` component has additional
[details](https://github.com/git-ecosystem/trace2receiver/blob/main/Docs/configure-custom-collector.md)
and several [examples](https://github.com/git-ecosystem/trace2receiver/tree/main/Docs/Examples).



## Interactively running the sample collector (optional)

If you want, you can run the collector in a terminal window to test
your configuration. When interactive, the debug log will appear on the
console. You can change the two logging verbosity settings in the `config.yml`
file to see the OTLP being emitted.

```
$ ./sample-trace2-otel-collector --config <pathname-to-config.yml>
```

_In addition to having a running the collector, listening on a Unix
Domain Socket (SOCKET) or Windows Named Pipe (PIPE), you'll also need
to tell Git to send telemetry to the collector using the
`trace2.eventtarget` Git config variable (using `--system` or
`--global` scope). The various installer `service_start` scripts show
how to do this._




## Building sample installer packages

The provided `installer/<platform>/Makefile` will build a minimal installer
package for your platform.

### On macOS

To build an installer PKG on macOS:

```
$ go build
$ cd ./installer/<platform>
$ make layout
$ make package
```

A ".pkg" will be created in `./installer/macos/_out_/_pkg_/`.  You can use it to
install the sample collector in `/usr/local/sample-trace2-otel-collector/*`.
The installer script will copy the files, register it with `launchctl(1)`,
and start it.

The scripts in `/usr/local/sample-trace2-otel-collector/scripts/*` let you
stop and restart the service. Use these if you want to try different settings
in your installed `config.yml` or other YML files (such as `filter.yml`).

The `/usr/local/sample-trace2-otel-collector/uninstaller.sh` script will stop
the service and delete it.


### On Linux

To build an installer DEB on Linux:

```
$ go build
$ cd ./installer/<platform>
$ make layout
$ make package
```

A ".deb" will be created in `./installer/linux/_out_/_pkg_/`.  You can use it to
install the sample collector in `/usr/local/sample-trace2-otel-collector/*`.
The installer script will copy the files, register it with `systemctl(1)`,
and start it.

The scripts in `/usr/local/sample-trace2-otel-collector/scripts/*` let you
stop and restart the service. Use these if you want to try different settings
in your installed `config.yml` or other YML files (such as `filter.yml`).


### On Windows (Command Prompt)

To build a ZIP file for Windows using a Command Prompt and create BAT files.
(_You can use either a VS Developer Command Prompt or a plain Command Prompt._)

```
> go build
> cd ./installer/windows_batch_file
> build.bat
```

A ZIP file will be created in `./installer/windows_batch_file/_out_/` containing the
executable, the YML files, and scripts to install and register/unregister
the service with Control Panel. You can redistribute the ZIP file and let
users (in an elevated Command Prompt) run the `install.bat` and `register.bat`
scripts. You should then see the collector in the Control Panel Service Manager.

Having three scripts is not as nice as a stand-alone exe installer,
but they will let you kick the tires and/or distribute the ZIP file to your users
without involving a third-party installer-builder tool.


NOTE: The `register.bat` script will use `git config --global` to set some global
config values to tell Git to send telemetry data to the collector.  These are
per-user config values, so telemetry will only be collected from the user who
ran the script.  If you want to collect telemetry from multiple users on a
computer, you should have each user execute those Git commands.  This is a
limitation of using "global" scope.  You might change it to use `--system`
scope, but this causes problems if you have multiple versions of Git installed
on the computer, such as the one bundled with Visual Studio vs the one installed
in `C:\Program Files\Git`, since each version has its own notion of where
the system configuration is stored. Using `--global` solves that problem.



### On Windows (Git SDK) (Deprecated)

If you have the Git SDK installer and are comfortable in an `msys2 bash` shell,
you can create a ZIP file for Windows that uses bash scripts:

```
$ go build
$ cd ./installer/windows_bash
$ make layout
$ make package
```

A ZIP file will be created in `./installers/windows_bash/_out_/` containing the
executable, the YML files, and scripts to install and register/unregister
the service with Control Panel.  The ZIP file will contain `install.sh`,
`register.sh` and `unregister.sh`. Run these from an elevated bash terminal.
You should then see the collector in the Control Panel Service Manager.

_I created these scripts during development, but very few people have the Git
SDK installed, so I created the above BAT file versions and will retire the
bash version eventually._


## Troubleshooting

### Use the console logs

Once you have the collector running as a service, you can look at
its console logs in `/usr/local/sample-trace2-otel-collector/logs/*`
on Linux and macOS.  On Windows, these messages are written to the
Event Viewer (under "Windows Logs > Application").

* NOTE I would rather that console logs on Windows were written to a
log file in the ProgramData directory rather than the Event Viewer, but
that is the behavior of the default logger built into the collector.
It should be possible to change this, but I have not taken time to
investigate this.

There are two settings in `config.yml` to control the verbosity of
the console logs. You can turn them up to get more detailed messages
and debug output. _(They will generate a lot of data, so don't forget
to turn them back down when you're finished.)_


### Add a real exporter

In the example `config.yml` that I included with this sample collector,
it only writes to the console log. You'll need to add one or more (real)
exporters to send the telemetry somewhere. The documentation in the
`trace2receiver` component has several examples.


### Verify the rendezvous SOCKET or PIPE

The Trace2 feature in Git will send telemetry to a SOCKET or PIPE
defined in the `trace2.eventtarget` system- or global-level config
value. The value of this pathname must match the pathname where the
collector is listening.

The Git config variable is added to the Git environment using the
various `service_start` or `register.sh` scripts in the installers.

The collector gets this pathname from the `config.yml` file.

If you're not seeing any data for your Git commands, verify that these
two pathnames match.  It may be helpful to use `GIT_TRACE2_DST_DEBUG`
to verify that Git can write to the SOCKET or PIPE:

```
$ git config --global trace2.eventtarget "af_unix:/foo"
$ GIT_TRACE2_DST_DEBUG=1 git version
warning: trace2: could not connect to socket '/foo' for 'GIT_TRACE2_EVENT' tracing: No such file or directory
git version 2.42.0
```


### Too much data

If you're sending too much telemetry to your data sink or
cloud provider, you can try the filtering built into the
`trace2receiver` component. For example, have it drop data
from uninteresting commands or repositories and let you focus
on the important commands that are causing your users pain.

The `trace2receiver` documentation has a whole section on
such filtering.

You may also want to consider adding a pipeline component
(between the trace2 receiver component and your exporter
component) that does some form of sampling. That is outside
of the scope of my goals here.



## Contributions

This project is under active development, and loves contributions from
the community.  Check out the [CONTRIBUTING](./CONTRIBUTING.md) guide
for details on getting started.


## License

This project is licensed under the terms of the MIT open source license.
Please refer to [LICENSE](./LICENSE) for the full terms.


## Maintainers

See [CODEOWNERS](./CODEOWNERS) for a list of current project maintainers.


## Support

See [SUPPORT](./SUPPORT.md) for instructions on how to file bugs, make feature
requests, or seek help.
