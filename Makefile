COMMIT = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: build deb clean

default: clean build

build:
	go build -ldflags "-X main.Commit=$(BRANCH)-$(COMMIT)"

deb: clean build
	cp galera_watchdog build/opt/bin/
	fpm --url https://github.com/crahles/galera_watchdog \
	-s dir -t deb -n galera_watchdog -m'christoph@rahles.de' \
	--after-install=build/install.sh \
	-v 1.0.3 --iteration $(COMMIT) ./build/opt/bin/galera_watchdog=/opt/bin/ \
	./build/etc/galera_watchdog/galera_watchdog=/etc/galera_watchdog/ \
	./build/lib/systemd/system/galera_watchdog.service=/lib/systemd/system/

clean:
	rm -rf galera_watchdog galera*watchdog*.deb build/opt/bin/*
