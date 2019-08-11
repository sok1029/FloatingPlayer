# FloatingPlayer
This is a floating player that can be used by connecting your player.


<img alt="Demo" src="/resources/demo.GIF?raw=true" width="290">&nbsp;


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
},
prev: {
 //input your prevButton Act
},
next: {
 //input your nextButton Act
},
pause: {
 //input your pauseButton Act
}) {
 //input your playButton Act
}

//show floating
FloatingPlayer.shared.showFloating()

//hide floating
FloatingPlayer.shared.hideFloating()

```

## Author

sok1029@gmail.com
