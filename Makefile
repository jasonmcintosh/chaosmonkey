BINARY=chaosmonkey
GOARCH=amd64

COMMIT=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
REPO=$(shell basename $(shell git rev-parse --show-toplevel))
PKGS := $(shell go list ./... | grep -v -e /integration -e /vendor)
INTEGRATION_PKGS := $(shell go list ./... | grep /integration)

PROJECT_DIR=${GOPATH}/src/github.com/Netflix/chaosmonkey
BUILD_DIR=$(shell pwd)/build
CURRENT_DIR=$(shell pwd)

LDFLAGS = -ldflags "-X main.COMMIT=${COMMIT} -X main.BRANCH=${BRANCH}"
GO111MODULE=on 
GOFLAGS='-mod=vendor' 
GOOS=linux 
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
        LDFLAGS = -ldflags "-X main.COMMIT=${COMMIT} -X main.BRANCH=${BRANCH} -linkmode external -extldflags -static -s -w"
endif

docker:
	docker build . -t netflix/chaosmonkey:${COMMIT}

all: clean test build

clean:
	rm -rf ${BUILD_DIR}
	go clean

build: check
	go build ${LDFLAGS} -o ${BUILD_DIR}/${BINARY} ./cmd/${BINARY}/main.go

check: fmt  

gofmt: fmt

fmt: 
	cd ${PROJECT_DIR}; \
	go fmt $$(go list ./... | grep -v /vendor/) ; 

lint: $(GOLINT)
	golangci-lint run 

#errcheck:
	#errcheck -ignore 'io:Close' -ignoretests `go list ./... | grep -v -e '/vendor/' -e '/migration'`

test:
	go test -v ./...


# Coverage testing
cover:
	echo 'mode: atomic' > coverage.out 
	go list ./... | grep -Ev '/vendor/|/migration' | xargs -n1 -I{} sh -c 'go test -covermode=atomic -coverprofile=coverage.tmp {} && tail -n +2 coverage.tmp >> coverage.out' && rm coverage.tmp
	go tool cover -html=coverage.out

fix:
	gofmt -w -s `find . -name '*.go' | grep -Ev '/vendor/|/migration'`
