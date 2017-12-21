Littlstar iOS SDK
==================


Introduction
-------

Littlstar iOS 360 photo/video player SDK
The Littlstar SDK is a developer library to easily build and implement mobile applications that utilize immersive **360° video** content that is hosted on the [*Littlstar*](http://littlstar.com) back-end service.

360° video is a special type of video that covers the complete surroundings of the camera. With the Littlstar iOS SDK, 360° video can be included to mobile apps with three easy steps:


////////////////////////// / / / / // / / maybe change some of this wording...
1. Content is **hosted** on the Littlstar back-end service. Point your web browser to http://littlstar.com, create a user account, and upload your 360° videos.
2. Content is **accessed** via the SDK in a manner that hides all the complexity. Request your videos with your user ID, and pick a video to be played from the video list response.
3. Content is **played** with a state-of-the-art 360° video player. Include the player fragment into your UI layout and initialize it with a video ID from your video list.
////////////////////////// / / / / // / /


Installation
-------

### Cocoapods
Get [Cocoapods](http://guides.cocoapods.org/using/getting-started.html#installation)

Add the pod to your podfile
```
platform :ios, "9.0"
workspace 'Hello Littlstar 360 Player'

target "Hello Littlstar 360 Player" do
    pod 'ls-ios-sdk'
end
```
run
```
$ pod install
```

After installing the cocoapod into your project import ls-ios-sdk with Swift
`import ls_ios_sdk`

### Carthage
….TODO


Hello Littlstar
-------

### Boilerplate code
```
import ls_ios_sdk
class ViewController: UIViewController {

  var player: LSPlayer!

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    player = LSPlayer(frame: self.view.frame, viewController: self)
    self.view.addSubview(player)

    let hlsExample = URL(string:"https://360.littlstar.com/production/76b490a5-2125-4281-b52d-8198ab0e817d/mobile_hls.m3u8")!
    player.initMedia(hlsExample)
  }

  @objc func play() {
    if player.isPlaying {
      player.pause()
    } else {
      player.play()
    }
  }

  @objc func mute() {
    if player.isMuted {
      player.isMuted = false
    } else {
      player.isMuted = true
    }
  }
}
```


API
-------

### LSPlayer

#### init(frame: CGRect, viewController: UIViewController)
Example: `var player = LSPlayer(frame: self.view.frame, viewController: self)`

#### isMuted: Bool
Can get and set
`if false == player.isMuted {
     player.isMuted = true
}`

#### isPlaying: Bool
Can get
`player.isPlaying`

#### initMedia(_ file: URL)

Loads 360 video or photo.

`player.initMedia("https://my360video.m3u8")`


#### Play()

Plays video from current timecode.
Sets `player.isPlaying` to `true`
If new video, starts playing.
If already playing, no effect.
If Image, no effect.

`player.play()`


#### Pause()

Pauses video at current timecode.
Sets `player.isPlaying` to `false`
If already paused, no effect.
If Image, no effect.

`player.pause()`


#### seek(to second: Int)

programatically seek to specific timecode.

set timecode to 30 seconds:
`player.seek(to: 30)`

play behavior will follow what `player.isPlaying` is set to. ie if video is pause, video will stay paused at new timecode.
this is automatically called when user interacts with timeline


#### invalidate()

destroy, clean up, and remove player.


#### lsMediaReadyWithImage()

???? hey Huy, I don't think this ever gets called right now.


>**Note:** The following functions do not apply to images, only videos

#### lsMediaReadyWithVideo(duration: Double)

Fires with video is ready to play... ??? is this really public?


#### lsMediaHasEnded()

Fires when video has ended.


#### lsMediaHasUpdated(currentTime: Double, bufferedTime: Double)

Fires when player has received updated frames to play.


#### lsMedia(isBuffering: Bool)

???????




### Gestures

single tap toggles play/pause
single finger pan rotates 360 photo/video

