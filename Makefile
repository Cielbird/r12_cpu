.PHONY: test clean build all

all: build

build:
	./scripts/build

test:
	./scripts/test

clean:
	./scripts/clean
