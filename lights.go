package main

import (
	"flag"
	"log"
	"time"

	ws2811 "github.com/rpi-ws281x/rpi-ws281x-go"
)

const (
	dmaChannel = 10
	onColor    = 0xff0000
	offColor   = 0
)

var (
	ledCount   = flag.Int("ledCount", 300, "The amount of LEDs on the strip to use")
	brightness = flag.Int("brightness", 255, "The desired LED intensity")
)

// stripEngine acts as a golang facade between the underlying C strip communication implementation
type stripEngine interface {
	Init() error
	Render() error
	Wait() error
	Fini()
	Leds(channel int) []uint32
}

// StripController is in charge of orchestrating the communication between
// the exposed HTTP endpoint, and the strip engine.
type StripController struct {
	controlChannel chan bool
	isInUse        bool
	engine         stripEngine
}

func createController() *StripController {
	options := ws2811.DefaultOptions
	options.DmaNum = dmaChannel
	options.Channels[0].LedCount = *ledCount
	options.Channels[0].Brightness = *brightness
	options.Channels[0].StripeType = ws2811.WS2811StripGRB

	engine, err := ws2811.MakeWS2811(&options)

	if err != nil {
		// There is only one error that function will throw
		// so it is safe to go ahead and fail with that reason
		log.Fatalf("Failed to allocate memory for ws2811 instance")
	}

	err = engine.Init()

	if err != nil {
		log.Fatalf("Failed to bind light controller: %s\n", err)
	}

	return &StripController{
		engine:         engine,
		controlChannel: make(chan bool),
	}
}

func (c *StripController) flash() {
	c.setStripColor(onColor)
	time.Sleep(500 * time.Millisecond)
	c.setStripColor(offColor)
}

func (c *StripController) setStripColor(color uint32) {
	for i := 0; i < len(c.engine.Leds(0)); i++ {
		c.engine.Leds(0)[i] = color
	}

	if err := c.engine.Render(); err != nil {
		log.Printf("Failed to render light strip: %s\n", err)
	}
}

func (c *StripController) process() {
	<-c.controlChannel

	if c.isInUse {
		// Go ahead and silently ignore the request
		return
	}

	c.isInUse = true
	c.setStripColor(onColor)
	c.isInUse = false
}

func (c *StripController) cleanup() {
	c.setStripColor(0)
	c.engine.Fini()
}
