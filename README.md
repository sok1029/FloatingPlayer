# FloatingPlayer
This repository is simplest menu navigation. 

<img alt="Demo" src="/resources/demo.gif?raw=true" width="290">&nbsp;


## Usage

```swift
//set your floating Image
FloatingPlayer.shared.buttonImg.accept("buttonImage")

//set your player controller images
FloatingPlayer.shared.setImages(("pause","play","prev","next"))

//set first Player Status Pause or Play
FloatingPlayer.shared.isPlaying.accept(false)

//connect your player to floatingPlayer
FloatingPlayer.shared.setEventHandler(open: {

//input your openButton Act
print("openButton Act")
},
prev: {
//input your prevButton Act
print("prevButton act")
},
next: {
//input your nextButton Act
print("nextButton act")
},
pause: {
//input your pauseButton Act
print("pauseButton act")
}) {
//input your playButton Act
print("playButton act")
}

//show floating
FloatingPlayer.shared.showFloating()

//hide floating
FloatingPlayer.shared.hideFloating()

```

## Author

sok1029@gmail.com
