# The Button

This project provides a web interface to a a light strip (specifically one featuring a ws281x controller).

## Server

You will need the following tools to build the server:

- golang
- gcc/make (`build-essentials` via apt)
- scons
- `crossbuild-essential-armhf` cross-compilation build tools
  - I used the package shipped with the default repositories on Ubuntu. As long as you
    have the same tools installed you should be good to go.

Now you may run `make build`. Look in `build` for the server binary which can be used on any ARM system with a configured ws281x strip/matrix.

_Note:_ There are some artifacts around the system after building; cleanup using `make cleanNative`

## Client

The client, `public/`, requires nothing special--throw it on your webserver of choice.

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
