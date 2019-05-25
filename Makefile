ROOT_PATH=$(shell pwd)

OUTPUT_DIR=build
BINARY_NAME=server

NATIVES_DIR_NAME=natives-cache
NATIVES_VERSION_LOCK_SHA=ba3b5bdad55dc7754567a68c4364b1e772735f47

all: build

clean:
	rm -rf build/

cleanNative:
	rm -rf $(NATIVES_DIR_NAME)
	sudo rm -rf /usr/local/lib/arm-linux-gnueabihf/

$(NATIVES_DIR_NAME):
	@echo "Missing natives cache, creating..."
	git clone https://github.com/jgarff/rpi_ws281x.git $(NATIVES_DIR_NAME)
	cd $(NATIVES_DIR_NAME) &&\
	  git reset --hard $(NATIVES_VERSION_LOCK_SHA) &&\
	  scons V=true TOOLCHAIN=arm-linux-gnueabihf &&\
	  sudo mkdir -p /usr/local/lib/arm-linux-gnueabihf/ &&\
	  sudo cp libws2811.a /usr/local/lib/arm-linux-gnueabihf/
	  # Setting the library path within the build, whether via `LIBRARY_PATH`
	  # or directly through LD flags, fails for some reason. We're just going
	  # to throw the library into a default LD path to "solve" that issue.
	uname -a > $(NATIVES_DIR_NAME)/built-with.txt

# GOARCH=arm \
# 	  GOARM=7 \
# 	  CGO_ENABLED=1 \
# 	  CC=arm-linux-gnueabihf-gcc \
# 	  CC_FOR_TARGET=arm-linux-gnueabihf-gcc \
# 	  CXX_FOR_TARGET=arm-linux-gnueabihf-g++ 
build: clean | $(NATIVES_DIR_NAME)
	mkdir build/
	  env GOOS=linux \
	  CPATH=$(ROOT_PATH)/$(NATIVES_DIR_NAME) \
	  LIBRARY_PATH=$(ROOT_PATH)/$(NATIVES_DIR_NAME) \
	  go build -o $(OUTPUT_DIR)/$(BINARY_NAME)

.PHONY: all