# FloatingPlayer
This is a floating player that can be used by connecting your player.


<img alt="Demo" src="/resources/demo.GIF?raw=true" width="290">&nbsp;


## Usage

### Configuration

```swift
// Set your floating Image
FloatingPlayer.shared.buttonImg.accept("buttonImage")

// Set your player controller images
FloatingPlayer.shared.setImages(("pause","play","prev","next"))

// Set player status. Pause or Play
FloatingPlayer.shared.isPlaying.accept(false)

// Connect your player to floatingPlayer
FloatingPlayer.shared.setEventHandler(open: {
 // Input your openButton Act
},
prev: {
 // Input your prevButton Act
},
next: {
 // Input your nextButton Act
},
pause: {
 // Input your pauseButton Act
}) {
 // Input your playButton Act
}
```
### Show  ,  Hide

```swift
// Show floating
FloatingPlayer.shared.showFloating()

// Hide floating
FloatingPlayer.shared.hideFloating()

```

## Requirements

* iOS 11

## Dependencies

* [RxSwift](https://github.com/ReactiveX/RxSwift) >= 5.0

## Author

sok1029@gmail.com
