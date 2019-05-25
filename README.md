# The Button

This project creates a website with a button that controls the illumination state of a light strip (which must be using the ws281x controller).

## Server

The program itself is intented to run on the same CPU architecture as a Raspberry Pi.. though most people are not running on ARM so the build command uses cross compilation by default.

You will need the following tools to build the server:

- golang
- gcc/make (apt `build-essentials`)
- scons
- `crossbuild-essential-armhf` apt package
  - This is included in the default repository, at least on Ubuntu

Now you may run `make build`. Look in `build` for the server binary.

_Note:_ There are some artifacts around the system after building.. cleanup using `make cleanNative`

## Client

The client, `public/`, is nothing special, just throw it on any webserver. You will be responsible for handling how to get the API request back to the server.

## Tool configuration

When I deployed this, I used [frp](https://github.com/fatedier/frp) as a proxy between my LAN and a server exposed to the Internet.

FRP client configuration:

```ini
[common]
server_addr = {frp server address}
server_port = {frp server port}

[button]
type = tcp
local_ip = 127.0.0.1
local_port = 2000
remote_port = 2000
```

nginx block:

```
location /button/api/ {
    proxy_pass http://localhost:2000;
}
```
