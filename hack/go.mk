# ----------------------------------------------------------------------------
# global
 
GO_PATH = $(shell go env GOPATH)
PKG = $(subst $(GO_PATH)/src/,,$(CURDIR))
GO_PKGS := $(shell go list ./... | grep -v -e '.pb.go')
GO_PKGS_ABS := $(shell go list -f '$(GO_PATH)/src/{{.ImportPath}}' ./... | grep -v -e '.pb.go')

GO_TEST ?= go test
GO_TEST_FUNC ?= .
GO_BENCH_FUNC ?= .

VET_LINTERS := asmdecl assign atomic bools buildtag cgocall copylocks httpresponse loopclosure lostcancel nilfunc nilness pkgfact shift stdmethods structtag tests unreachable unsafeptr  # composites -composites.whitelist '' findcall -findcall.name '' printf -printf.funcs '' unusedresult -unusedresult.funcs '' -unusedresult.stringmethods ''
GOLANGCI_LINTERS := deadcode dupl errcheck goconst gocyclo golint gosec ineffassign interfacer maligned megacheck structcheck unconvert varcheck 
GOLANGCI_EXCLUDE :=
ifneq ($(wildcard '.errcheckignore'),)
	GOLANGCI_EXCLUDE = $(foreach pat,$(shell cat .errcheckignore),--exclude '$(pat)')
endif

# ----------------------------------------------------------------------------
# defines

define target
@printf "+ \\033[32m$@\\033[0m\\n"
endef

# ----------------------------------------------------------------------------
# targets

.PHONY: test
test:
test:  ## Run the package test.
	$(call target)
	$(GO_TEST) -v -race -tags "$(BUILDTAGS)" -run=$(GO_TEST_FUNC) $(GO_PKGS)

.PHONY: bench
bench:
bench:  ## Take a package benchmark.
	$(call target)
	$(GO_TEST) -v -race -tags "$(BUILDTAGS)" -run='^$$' -bench=$(GO_BENCH_FUNC) -benchmem $(GO_PKGS)

.PHONY: coverage
coverage:  ## Take test coverage.
	$(call target)
	$(GO_TEST) -v -race -covermode=atomic -coverpkg=$(PKG)/... -coverprofile=coverage.out $(GO_PKGS)


lint: lint/fmt lint/govet lint/golint lint/vet lint/golangci-lint  ## Run all linters.

.PHONY: lint/fmt
lint/fmt:  ## Verifies all files have been `gofmt`ed.
	$(call target)
	@gofmt -s -l . | grep -v '.pb.go' | tee /dev/stderr

.PHONY: lint/govet
lint/govet:  ## Verifies `go vet` passes.
	$(call target)
	@go vet -all $(GO_PKGS) | tee /dev/stderr

$(GO_PATH)/bin/golint:
	@go get -u golang.org/x/lint/golint

.PHONY: lint/golint
lint/golint: $(GO_PATH)/bin/golint  ## Verifies `golint` passes.
	$(call target)
	@golint -min_confidence=0.3 -set_exit_status $(GO_PKGS)

$(GO_PATH)/bin/vet:
	@go get -u golang.org/x/tools/go/analysis/cmd/vet golang.org/x/tools/go/analysis/passes/...

lint/vet:  ## Run vet
	$(call target)
	@vet $(foreach linter,$(VET_LINTERS),-$(linter).enable) $(GO_PKGS)

$(GO_PATH)/bin/golangci-lint:
	@go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

.PHONY: golangci-lint
lint/golangci-lint: $(GO_PATH)/bin/golangci-lint  ## Run golangci-lint.
	$(call target)
	@golangci-lint run --no-config --issues-exit-code=0 $(GOLANGCI_EXCLUDE) --deadline=30m --disable-all $(foreach tool,$(GOLANGCI_LINTERS),--enable=$(tool)) $(GO_PKGS_ABS)


$(GO_PATH)/bin/dep:
	@go get -u github.com/golang/dep/cmd/dep

.PHONY: dep/init
dep/init: $(GO_PATH)/bin/dep  ## Fetch vendor packages via dep ensure.
	$(call target)
	@dep init -v -no-examples

.PHONY: dep/ensure
dep/ensure: $(GO_PATH)/bin/dep  ## Fetch vendor packages via dep ensure.
	$(call target)
	@dep ensure -v -vendor-only

.PHONY: dep/update
dep/update: $(GO_PATH)/bin/dep dep/clean  ## Updates the vendoring directory.
	$(call target)
	@dep ensure -v -update

.PHONY: dep/clean
dep/clean:
	$(call target)
	@$(RM) -r vendor


.PHONY: AUTHORS
AUTHORS:
	@$(file >$@,# This file lists all individuals having contributed content to the repository.)
	@$(file >>$@,# For how it is generated, see `make AUTHORS`.)
	@echo "$(shell git log --format='\n%aN <%aE>' | LC_ALL=C.UTF-8 sort -uf)" >> $@


.PHONY: clean
clean:  ## Cleanup any build binaries or packages.
	$(call target)
	$(RM) $(APP) *.out *.prof


.PHONY: help
help:  ## Show make target help.
	@perl -nle 'BEGIN {printf "Usage:\n  make \033[33m<target>\033[0m\n\nTargets:\n"} printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 if /^([a-zA-Z\/_-].+)+:.*?\s+## (.*)/' ${MAKEFILE_LIST}
