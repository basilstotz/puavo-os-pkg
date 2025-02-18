prefix = /usr
datarootdir = $(prefix)/share

INSTALL = install
INSTALL_DATA = $(INSTALL) -m 644

packagedirs  = abitti-naksu
packagedirs += adobe-reader
packagedirs += airtame
packagedirs += appinventor
packagedirs += arduino-ide
packagedirs += arduino-ottodiylib
packagedirs += arduino-radiohead
packagedirs += arduino-tm1637
packagedirs += aseba
packagedirs += aversphere2
packagedirs += bitwarden
packagedirs += bitwarden-cli
packagedirs += bluegriffon
packagedirs += bluej
packagedirs += canon-cque
packagedirs += celestia
packagedirs += clevertouch-lynx
packagedirs += cmaptools
packagedirs += cnijfilter2
packagedirs += cryptomator
packagedirs += cura-appimage
packagedirs += discord
packagedirs += dropbox
packagedirs += dragonbox_algebra_5
packagedirs += dragonbox_algebra_12
packagedirs += dragonbox_bignumbers
packagedirs += dragonbox_koulu1
packagedirs += dragonbox_koulu2
packagedirs += dragonbox_koulu3
packagedirs += dragonbox_numbers
packagedirs += eclipse
packagedirs += ekapeli-alku
packagedirs += enchanting
packagedirs += epson-easymp
packagedirs += eshare
packagedirs += extra-xkb-symbols
packagedirs += ffsend
packagedirs += filius
packagedirs += firefox
packagedirs += firmware-sof-signed
packagedirs += flashforge-flashprint
packagedirs += gdevelop
packagedirs += geogebra
packagedirs += geogebra6
packagedirs += globilab
packagedirs += google-chrome
packagedirs += google-earth
packagedirs += hamstersimulator
packagedirs += hp-bios-utils
packagedirs += icaclient
packagedirs += idid
packagedirs += kdenlive-appimage
packagedirs += kmbeu
packagedirs += kojo
packagedirs += launcherone
packagedirs += logicsim3
packagedirs += lmaths
packagedirs += lumidesktop
packagedirs += mafynetti
packagedirs += marvinsketch
packagedirs += mattermost-desktop
packagedirs += mathpix
packagedirs += mindplus
packagedirs += msttcorefonts
packagedirs += musescore-appimage
packagedirs += netbeans
packagedirs += nextcloud-desktop
packagedirs += nightcode
packagedirs += novoconnect
packagedirs += obsidian-icons
packagedirs += ohjelmointi-opetuksessa
packagedirs += openclipart
packagedirs += openscad-nightly
packagedirs += openshot-appimage
packagedirs += otto-blockly
packagedirs += processing
packagedirs += projectlibre
packagedirs += promethean
packagedirs += prusaslicer
packagedirs += puavo-firmware
packagedirs += pycharm
packagedirs += pyscrlink
packagedirs += qcad-cam
packagedirs += rustdesk
packagedirs += robboscratch
packagedirs += robotmeshconnect
packagedirs += schoolstore-ti-widgets
packagedirs += scratux
packagedirs += shotcut
packagedirs += signal-desktop
packagedirs += skype
packagedirs += smartboard
packagedirs += sparkvue
packagedirs += spotify-client
packagedirs += supertuxkart
packagedirs += structorizer
packagedirs += teams
packagedirs += teamviewer
packagedirs += tela-icon-theme
packagedirs += telegram-desktop
packagedirs += tilitin
packagedirs += t-lasku
packagedirs += thymiosuite
packagedirs += tmux-plugins-battery
packagedirs += ubuntu-focal-libs
packagedirs += ubuntu-wallpapers
packagedirs += ubuntu-wallpapers-bullseye
packagedirs += unityhub
packagedirs += vagrant
packagedirs += veracrypt
packagedirs += vidyo-client
packagedirs += vscode
packagedirs += webex
packagedirs += wine-gecko
packagedirs += wine-mono
packagedirs += zoom

packagefiles = $(patsubst %,%.tar.gz,${packagedirs})

.PHONY: all
all: $(packagefiles) puavo-pkg-installers-bundle.tar puavo-pkg.json
	echo $(packagefiles)

.PHONY: list_packages
list_packages:
	@echo $(packagedirs)

puavo-pkg.json: $(packagefiles)
	jq --null-input --arg packages "$(packagedirs)" \
	  '$$packages | split(" ") | reduce .[] as $$item ({}; .["puavo.pkg." + $$item] = { default: "" })' \
	  > $@.tmp
	mv $@.tmp $@

.PHONY: installdirs
installdirs:
	mkdir -p $(DESTDIR)$(datarootdir)/puavo-conf/definitions
	mkdir -p $(DESTDIR)$(datarootdir)/puavo-pkg/packages

.PHONY: install
install: installdirs
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/puavo-conf/definitions \
		puavo-pkg.json
	$(INSTALL_DATA) -t $(DESTDIR)$(datarootdir)/puavo-pkg/packages \
		$(packagefiles)

puavo-pkg-installers-bundle.tar: $(packagefiles)
	tar cf "$@" $^

# Do not use tar with -z, instead use "gzip -n" so that tar-archives are
# deterministically created and thus different only when their contents have
# changed (we use tar-archive contents as installer versions).
# XXX The above comment implies that the outcome is exactly the same on
# XXX different hosts, given the same directory tree (paths and contents).
# XXX This is *not* true, but should be.
%.tar.gz: %/ %/*
	./update_package_version $(patsubst %.tar.gz,%,$@)
	tar --mtime='2000-01-01 00:00:00 +00:00' -c -f - $< | gzip -n > "$@"

.PHONY: clean
clean:
	rm -rf $(packagefiles) puavo-pkg-installers-bundle.tar puavo-pkg.json
