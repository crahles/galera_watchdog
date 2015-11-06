COMMIT = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: build deb clean

default: clean build

build:
	go build -ldflags "-X main.Commit=$(BRANCH)-$(COMMIT)"

deb: clean build
	mkdir bin
	cp galera_watchdog bin/
	fpm --prefix=/usr --url https://github.com/crahles/galera_watchdog -s dir -t deb -n galera_watchdog -m'christoph@rahles.de' -v $(BRANCH)-$(COMMIT) bin/galera_watchdog

clean:
	rm -rf galera_watchdog galera*watchdog*.deb bin
