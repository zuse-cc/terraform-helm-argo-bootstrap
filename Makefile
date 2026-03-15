PACKAGE_NAME ?= $(shell basename $(CURDIR))
COMMIT ?= $(shell git rev-parse --short HEAD)
VERSION ?= v0.1.0-$(COMMIT)

PACKAGE_FILE ?= $(PACKAGE_NAME)-$(VERSION).tar.gz

.PHONY: default
default: test

out/$(PACKAGE_FILE):
	mkdir -p out
	tar -czf out/$(PACKAGE_FILE) --exclude out --exclude Makefile --exclude .terraform --exclude '.git*' --exclude tests .

.PHONY: package
package: out/$(PACKAGE_FILE)

.PHONY: clean
clean:
	rm -rf out

.PHONY: test
test:
	terraform init -upgrade
	terraform test

.PHONY: fmt
fmt:
	find . -type f -name '*.tf' -or -name '*.tfvars' -or -name '*.tftest.hcl' | xargs -n1 terraform fmt

.PHONY: check-fmt
check-fmt:
	find . -type f -name '*.tf' -or -name '*.tfvars' -or -name '*.tftest.hcl' | xargs -n1 terraform fmt -check -diff

release:
	gh release create $(VERSION) --title "Release $(VERSION)" --target main --generate-notes
