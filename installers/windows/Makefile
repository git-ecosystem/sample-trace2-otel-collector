## Makefile for building Windows distribution.
## Run this from within the `installers/windows` directory.
##
## This will create a ZIP file containing the executable, various
## scripts, and the various YML files.
##
## NOTE To streamline enterprise deployment, you should customize
## NOTE the various YML files before building the ZIP file.
## NOTE Eventually, you will probably want to create a real
## NOTE Windows installer from these pieces.
################################################################

GOOS := $(shell go env GOOS)
GOARCH := $(shell go env GOARCH)

################################################################
# VER is the version of the trace2receiver that we are using.
# Since the collector is generated source, its version number
# isn't that interesting.
#
# You might have to override this if you build from an @latest,
# a SHA, or other GOLANG module specification.

VER := $(shell go list -m github.com/git-ecosystem/trace2receiver | awk '{print $$2}')

# Strip the leading 'v' for use in the .pkg filename.

NVER := $(shell echo $(VER) | sed 's/^v//')

################################################################

ZIPNAME := sample-trace2-otel-collector_$(NVER)_$(GOOS)-$(GOARCH)

################################################################

DST := ./_out_/$(ZIPNAME)

.PHONY: layout
layout:
	@echo "======== Creating Layout ========"
	@echo "GOOS is $(GOOS)"
	@echo "GOARCH is $(GOARCH)"
	@uname -a
	@echo

	rm -rf _out_

	mkdir -p $(DST)

	cp ../../sample-trace2-otel-collector.exe $(DST)/

	for f in ./install.sh ./register.sh ./unregister.sh ; do \
		echo "Copying $$f..."; \
		cat $$f \
		| sed -e 's/X_VER_X/$(VER)/' \
			> $(DST)/$$(basename $$f); \
	done

	cp ../../sample-configs/windows/*.yml $(DST)/


.PHONY: package
package:
	@echo "======== Creating ZIP Package ========"
	@echo

	(	cd "_out_"; \
		if (type -P pwsh.exe) \
		then \
			pwsh.exe -Command 'Compress-Archive -DestinationPath "./$(ZIPNAME).zip" -Path "$(ZIPNAME)/"'; \
		elif (type -P powershell.exe) \
		then \
			powershell.exe -Command 'Compress-Archive -DestinationPath "./$(ZIPNAME).zip" -Path "$(ZIPNAME)/"'; \
		else \
			echo "Error: could not find powershell."; \
			exit 1; \
		fi \
	)

.PHONY: clean
clean:
	rm -rf _out_
