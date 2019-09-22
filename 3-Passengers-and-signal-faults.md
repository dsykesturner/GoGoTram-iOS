# Passengers and Signal Faults

## New images

Copy the following images (all resolutions) into the `Assets.xcassets` folder in Xcode

- passengers
- signalFault

## Adding passengers and signal faults

When the tram collides with a passengers, it will pick them and and increase the score. However when a passengers collides with a signal fault, the game will end.

While handled differently, these two items are relatively similar. So creating a method which can be used by both is great for removing duplicate code.

First, create two new variables underneath the `tram` variable. 

- `var signalFault: SKSpriteNode?`
- `var passengers: SKSpriteNode?`

Create a new method called `createCollectable`. This will take a parameter `imageName` of type `String`, and return an optional `SKSpriteNode?`

Inside, add code to create a collectable sprite. This is very similar to the `createTram` method, but without a starting position or code to add it directly to the scene.

```
func createCollectable(imageName: String) -> SKSpriteNode? {
	let texture = SKTexture(imageNamed: imageName)
    let collectable = SKSpriteNode(texture: texture, size: texture.size())
    collectable.zPosition = layers.actor
    
    return collectable
}
```

This method is going to be called inside the `setupScene` method from earlier. After calling `createTram`, call `createCollectable` for both the `passengers` and the `signalFault` variables from earlier (make sure to pass in the correct image name).

```
self.signalFault = self.createCollectable(imageName: "signalFault")
self.passengers = self.createCollectable(imageName: "passengers")
```

## Moving collectables

These sprites won't actually be added onto the screen. Since many of them may be in use at once, copies will be made and added when needed, then destroyed afterwards.

Add these new methods to get started:

```
func startGame() {

}

func moveToNextLevel() {

}

func createRandomCollectable() {

}

func spawnNew(collectable: SKSpriteNode?) {

}
```

1. Call the `startGame` method after `setupScene` inside the `didMove` method.
2. Call `moveToNextLevel` inside the `startGame` method
3. Add the following code to the `moveToNextLevel` method:

```
// Run a repeating action on this scene (count=50)
self.run(SKAction.repeat(
	// This action is made up of a sequence of 2 other actions
    SKAction.sequence([
    	// 1. Call the createRandomCollectable method
        SKAction.run(self.createRandomCollectable),
        // 2. Wait 0.6 seconds before repeating
        SKAction.wait(forDuration: 0.6)
    ]), count: 50)
)
```

Inside the `createRandomCollectable` either a signal fault or a passenger will be created. The corresponding probabilities will be 2/3 for a signal fault and 1/3 for a passenger.

A function called `arc4random()` can be used to generate a random number. For example `arc4random() % 1000` would generate a random number between 0 and 999.

Add the following code inside `createRandomCollectable` to make a copy of either `signalFault` or `passengers`, and pass it to the `spawnNew` method:

```
let randomItem = arc4random() % 1000 // 0 - 999
if randomItem < 667 {
    // 66.7% chance
    self.spawnNew(collectable: self.signalFault?.copy() as? SKSpriteNode)
} else {
    // 33.3% chance
    self.spawnNew(collectable: self.passengers?.copy() as? SKSpriteNode)
}
```

Finally, to add the collectable to the screen, add the following code inside the `spawnNew` method:

```
// Safely unwrap the collectable since it was optional (return if it is nil)
guard let collectable = collectable else { return }

let screenHeight = self.size.height
let screenWidth = self.size.width
// Starting x coordinate should be just past the right end of the screen
let startingX = screenWidth + collectable.frame.size.width/2
// Starting y coordinate should be at a random point on the screen, as long as the whole collectable is visible
let startingY = CGFloat(arc4random() % UInt32(screenHeight - collectable.frame.size.height)) + collectable.frame.size.height/2

// Move the collectable into position, and add it to the scene
collectable.position = CGPoint(x: startingX, y: startingY)
self.addChild(collectable)

// Define the coordinates the collectable should move to (off the left side of the screen)
let endingX = -collectable.frame.size.width/2
let endingY = startingY
// Run an action on the collectable to move it to the end point
collectable.run(
    SKAction.move(to: CGPoint(x: endingX, y: endingY), duration: 2),
completion: {
	// Destroy the collectable once it has finished the action
    collectable.run(SKAction.removeFromParent())
})
```

Build and run, and you should see 50 collectables spawn and move across the screen. You won't be able to interact with them just yet!