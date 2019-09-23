# 2. Creating a tram

## Adding images

For this step an image of a tram and a background image will be needed. These can be found in the `/Images` folder for 3 different resolutions.

1. Open the `Assets.xcassets` folder in Xcode
2. Select all 3 resolutions of the tram image and drag into the assets sidebar in Xcode
3. Repeat for the background image

In Xcode these should be visible as 1x, 2x, and 3x for the different resolutions.

## New methods and variables

Go back to the `GameScene.swift` file, where the following variables and methods will be added.

1. tram (variable)
2. setupScene (method)
3. createTram (method)

Variables are typically declared at the top of a class. Declare the tram as an optional `SKSpriteNode` variable like this:

```
class GameScene: SKScene {
    
    var tram: SKSpriteNode?
```

Next add three new methods:

- `setupScene` will handle creating all the elements that are needed for the scene
- `createTram` will handle creating the tram and adding it to the scene
- `moveTram` will handle moving the tram when the screen is touched

```
func setupScene() {
        
}

func createTram() {
    
}

func moveTram(position: CGPoint) {

}
```

## Adding a moving tram

Inside the `createTram` method, add the following code:

```
// Create a texture from the tram image
let tramTexture = SKTexture(imageNamed: "tram")
// Create a sprite node from the tram texture, with the matching size
self.tram = SKSpriteNode(texture: tramTexture, size: tramTexture.size())
// Move the tram to 150px from the left of the screen, and half way up it
self.tram?.position = CGPoint(x: 150, y: self.size.height/2)
// Add the tram to the screen
self.addChild(self.tram!)
```

Now call the `createTram` method from inside the `setupScene` method, and call the `setupScene` method from inside the `didMove` method.

```
override func didMove(to view: SKView) {     
    self.setupScene()
}
```

Awesome! Build and run, and you should see a tram on screen.

Now it just has to move. Inside the `moveTram` method add the following code:

```
func moveTram(position: CGPoint) {
	// Safely unwrap the tram optional
    if let tram = self.tram {
    	// Keep a fixed position on the x-axis
        tram.position = CGPoint(x: 150, y: position.y)
    }
}
```

Now `moveTram` needs to be called each time an interaction with the screen is registered. Inside each of the touch methods (`touchesBegan`, `touchesMoved`, `touchesEnded`, and `touchesCancelled`) add the following code:

```
// Multiple touches can be received at once, so loop through each touch event and send the position to the moveTram method
for t in touches {
    self.moveTram(position: t.location(in: self))
}
```

## Adding layers

Build and run again, and you should see your tram move along the y-axis.

The last part of this section is adding a background image. To prevent the background image from covering up the tram, it's going to have a `zPosition` below the tram. 

Create a new *Swift File* called `Constants.swift` by using the keyboard shortcut `Cmd-N`. This will define the different layers of the game.

Inside the `Constants.swift` file, `import UIKit` and add a new struct like this:

```
struct layers {
    static let background:CGFloat = 0
    static let actor:CGFloat = 1
}
```

## Adding a background image

Now go back to the `GameScene.swift` file and set the zPosition of the tram to `layers.actor` when creating the tram.

```
self.tram?.zPosition = layers.actor
```

Next, inside the `setupScene` method add the following code to create a background image:

```
let backgroundImage = SKSpriteNode(imageNamed: "background")
// Center screen
backgroundImage.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
// Fit to screen
backgroundImage.size = self.size
// Place behind the tram
backgroundImage.zPosition = layers.background
self.addChild(backgroundImage)
```

Build and run and you should see your tram on top of the background image.

Next: [3. Passengers and signal faults](3-Passengers-and-signal-faults.md)
