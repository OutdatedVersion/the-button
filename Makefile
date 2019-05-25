ROOT=$(shell pwd)

OUTPUT_DIR=build
BINARY_NAME=server

NATIVE_DEP_DIR=natives-cache
NATIVE_CONTROLLER_VERSION_SHA=ba3b5bdad55dc7754567a68c4364b1e772735f47

all: build

clean:
	rm -rf build/

cleanNative:
	rm -rf $(NATIVE_DEP_DIR)
	sudo rm -rf /usr/local/lib/arm-linux-gnueabihf/

$(NATIVE_DEP_DIR):
	@echo "Missing natives cache, creating..."
	git clone https://github.com/jgarff/rpi_ws281x.git $(NATIVE_DEP_DIR)
	cd $(NATIVE_DEP_DIR) &&\
	  git reset --hard $(NATIVE_CONTROLLER_VERSION_SHA) &&\
	  scons V=true TOOLCHAIN=arm-linux-gnueabihf &&\
	  sudo mkdir -p /usr/local/lib/arm-linux-gnueabihf/ &&\
	  sudo cp libws2811.a /usr/local/lib/arm-linux-gnueabihf/
	  # Setting the library path within the build, whether via `LIBRARY_PATH`
	  # or directly through LD flags, fails for some reason. We're just going
	  # to throw the library into a default LD path to "solve" that issue.
	uname -a > $(NATIVE_DEP_DIR)/built-with.txt

build: clean | $(NATIVE_DEP_DIR)
	mkdir build/
	  env GOOS=linux \
	  GOARCH=arm \
	  GOARM=7 \
	  CGO_ENABLED=1 \
	  CC=arm-linux-gnueabihf-gcc \
	  CC_FOR_TARGET=arm-linux-gnueabihf-gcc \
	  CXX_FOR_TARGET=arm-linux-gnueabihf-g++ \
	  CPATH=$(ROOT)/$(NATIVE_DEP_DIR) \
	  LIBRARY_PATH=$(ROOT)/$(NATIVE_DEP_DIR) \
	  go build -o $(OUTPUT_DIR)/$(BINARY_NAME)

addDeps:
	go get -v -u github.com/rpi-ws281x/rpi-ws281x-go

.PHONY: all
