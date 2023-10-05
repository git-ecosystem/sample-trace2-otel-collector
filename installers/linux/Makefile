## Makefile for building Linux installer
## Run this from within the `installers/linux` directory.
##
## This will create a binary DEB package containing the executable,
## various scripts, and the various YML files.
##
## NOTE To streamline enterprise deployment, you should customize
## NOTE the various YML files before building your DEB.
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

# Strip the leading 'v' per debian conventions.

NVER := $(shell echo $(VER) | sed 's/^v//')

################################################################

DST    := ./_out_/_layout_/usr/local/sample-trace2-otel-collector
DEBIAN := ./_out_/_layout_/DEBIAN
ETC    := ./_out_/_layout_/etc/systemd/system

.PHONY: layout
layout:
	@echo "======== Creating Layout ========"
	@echo "GOOS is $(GOOS)"
	@echo "GOARCH is $(GOARCH)"
	@uname -a
	@echo

#	Create the basic on-disk layout for the our installation directory.

	rm -rf _out_/_layout_

	mkdir -p $(DST)
	mkdir -p $(DST)/bin
	mkdir -p $(DST)/logs
	mkdir -p $(DST)/scripts

	cp ../../sample-configs/unix/*.yml $(DST)/

	cp ./scripts/* $(DST)/scripts/
	chmod 755 $(DST)/scripts/*

	cp ../../sample-trace2-otel-collector $(DST)/bin/
	chmod 755 $(DST)/bin/sample-trace2-otel-collector

#	Create ETC for systemd(1).

	mkdir -p $(ETC)
	cp ./sample-trace2-otel-collector.service $(ETC)/

#	Create DEBIAN files for package.

	mkdir -p $(DEBIAN)

	for f in ./deb-scripts/* ; do \
		echo "Copying $$f..."; \
		cat $$f \
		| sed -e 's/X_VER_X/$(VER)/' \
			> $(DEBIAN)/$$(basename $$f); \
	done
	chmod 755 $(DEBIAN)/*

	cat ./control \
		| sed -e 's/X_NVER_X/$(NVER)/' \
		| sed -e 's/X_GOARCH_X/$(GOARCH)/' \
		> $(DEBIAN)/control


.PHONY: package
package:
	@echo "======== Creating Package ========"
	@echo

	rm -rf _out_/_pkg_
	mkdir -p _out_/_pkg_

	dpkg-deb \
		-Zxz \
		--build _out_/_layout_ \
		"_out_/_pkg_/sample-trace2-otel-collector_$(NVER)_$(GOOS)-$(GOARCH).deb"


.PHONY: clean
clean:
	rm -rf _out_
