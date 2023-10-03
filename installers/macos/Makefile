## Makefile for building macOS installer
## Run this from within the `installers/macos` directory.
##
## This will create a PKG containing the executable, various
## scripts, and the various YML files.
##
## NOTE To streamline enterprise deployment, you should customize
## NOTE the various YML files that are bundled into the overlay
## NOTE before building your PKG.
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

LAY := ./_out_/_layout_/sample-trace2-otel-collector
OVR := ./_out_/_overlay_/sample-trace2-otel-collector

################################################################

# Create the on-disk layouts for our two component packages.  These
# describe the basic structure of the directory, the binary components,
# scripts, and etc.
#
# They will both target the same `/usr/local/sample-trace2-otel-collector`
# installation directory.  That is, one is an overlay for the other.

.PHONY: layout
layout:
	@echo "======== Creating Layouts ========"
	@echo "GOOS is $(GOOS)"
	@echo "GOARCH is $(GOARCH)"
	@uname -a
	@echo

#	Create the basic on-disk layout for the basic structure of the
#	directory, the binary components, scripts, and etc.
#
#	We DO NOT include the YML files in the basic layout.

	rm -rf _out_/_layout_
	mkdir -p $(LAY)
	mkdir -p $(LAY)/bin
	mkdir -p $(LAY)/logs
	mkdir -p $(LAY)/scripts

	cp ./com.git-ecosystem.sample-trace2-otel-collector.plist $(LAY)/

	cp ./uninstaller.sh $(LAY)/
	chmod 755 $(LAY)/uninstaller.sh

	for f in ./postinstall ./preinstall ./service_start ./service_stop ; do \
		echo "Copying $$f..."; \
		cat $$f \
		| sed -e 's/X_VER_X/$(VER)/' \
			> $(LAY)/scripts/$$(basename $$f); \
	done
	chmod 755 $(LAY)/scripts/*

	cp ../../sample-trace2-otel-collector $(LAY)/bin/
	chmod 755 $(LAY)/bin/sample-trace2-otel-collector

	find $(LAY) -name '*.DS_Store' -type f -delete
	/usr/bin/xattr -rc * */*


#	Create the on-disk overlay layout for customization files that we
#	want to install on top of the basic layout.
#
#	Put all of the YML files in the overlay package.

	@echo
	@echo "======== Creating Overlay Layout ========"
	@echo

	rm -rf _out_/_overlay_
	mkdir -p $(OVR)

	cp ../../sample-configs/unix/*.yml $(OVR)/

	find $(OVR) -name '*.DS_Store' -type f -delete
	/usr/bin/xattr -rc * */*


# Component PKGs are pieces.  Distrubtion PKGs are installable.
# Create components for the basic layout and the overlay layout.
# Then create a distribution PKG containing both of them.

.PHONY: package
package:
	@echo "======== Creating Packages ========"
	@echo

#	================================
#	Build base component package.
#	================================

	rm -rf _out_/_component_
	mkdir -p _out_/_component_

	/usr/bin/pkgbuild \
		--root "$(LAY)" \
		--install-location "/usr/local/sample-trace2-otel-collector" \
		--scripts "$(LAY)/scripts/" \
		--identifier "com.git-ecosystem.sample-trace2-otel-collector" \
		--version "$(VER)" \
		"_out_/_component_/com.git-ecosystem.sample-trace2-otel-collector.component.pkg"

#	TODO sign the above.

#	================================
#	Build overlay component package.
#	================================

	/usr/bin/pkgbuild \
		--root "$(OVR)" \
		--install-location "/usr/local/sample-trace2-otel-collector" \
		--identifier "com.git-ecosystem.sample-trace2-otel-collector.overlay" \
		--version "$(VER)" \
		"_out_/_component_/com.git-ecosystem.sample-trace2-otel-collector.overlay.pkg"

#	TODO sign the above.

#	================================
#	Built default distribution package using our two component packages.
#	================================

	rm -rf _out_/_pkg_
	mkdir -p _out_/_pkg_

	/usr/bin/productbuild \
		--distribution "./distribution.$(GOARCH).xml" \
		--package-path "./_out_/_component_/" \
		--identifier "com.git-ecosystem.sample-trace2-otel-collector.dist" \
		--version "$(VER)" \
		"_out_/_pkg_/sample-trace2-otel-collector_$(NVER)_$(GOOS)-$(GOARCH).pkg"

#	TODO sign and notarize the above.


.PHONY: clean
clean:
	rm -rf _out_
