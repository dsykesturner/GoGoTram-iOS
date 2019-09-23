# 5. Game state

## Game start and end

To handle collisions with passengers and signal faults, the game is going to need a way to track its current state.

Add the following variables at the top of the class to track the current score, the current level, whether the game has started, and a key to stop collectables from appearing once the game has ended:

- `var score: UInt64 = 0`
- `var level: Int = 0`
- `var gameStarted: Bool = false`
- `let createCollectablesActionKey = "createCollectables"`

All these have default values so they can be non-optional (`Int` vs `Int?`), but they will still need to be set after each game. Inside the `startGame` method, set the values for each before the game begins like this:

```
self.gameStarted = true
self.level = 0
self.score = 0
```

Add a new method called `endGame` with no parameters, and inside set the `gameStarted` variable to `false`.

Next, to help show that the game has ended, only allow the tram to move when `gameStarted == true`. Add this logic into the if statement inside the `moveTram` method so it looks like this:

```
func moveTram(position: CGPoint) {
    if let tram = self.tram, self.gameStarted == true {
        tram.position = CGPoint(x: 150, y: position.y)
    }
}
```

To cause an end game event, the tram needs to collide with a signal fault. So inside the `didBegin` method where a signal fault has been checked for, call the `endGame` method.

## Current level

To increase the difficulty over time, each level should be longer with more collectables for the tram to encounter. So inside the `moveToNextLevel` method add the following:

```
// Increment level by 1 every time this method is called
self.level += 1
// Increase the number of collectables every time the level increases
let numberOfCollectables = self.level * 50
```

And update the action which runs `createRandomCollectable` to the following:

```
// Run a sequence of actions on this scene
self.run(SKAction.sequence([
	// 1. Repeat an action as many times as specified by numberOfCollectables
    SKAction.repeat(
        SKAction.sequence([
        	// 1.1. Call the createRandomCollectable method
            SKAction.run(self.createRandomCollectable),
            // 1.2. Wait 0.6 seconds before repeating
            SKAction.wait(forDuration: 0.6)
        ]), count: numberOfCollectables),
    // 2. Wait 2.0 seconds before the next action
    SKAction.wait(forDuration: 2),
    // 3. Recursively call this method to increase the level and repeat
    SKAction.run(self.moveToNextLevel)
    // Store this run action with the key `createCollectablesActionKey` so it can be stopped later
]), withKey: self.createCollectablesActionKey)
```

To stop the above action when the game has ended, add the following code inside the `endGame` method:

```
self.removeAction(forKey: self.createCollectablesActionKey)
```

## Score

To increase the score whenever a passenger is picked up, increment the global `score` variable inside the `didBegin` method.

When a collision happens, the collectable should also be removed from the scene. So add `contact.bodyB.node.run(SKAction.removeFromParent())` also inside the `didBegin` method like below:

```
func didBegin(_ contact: SKPhysicsContact) {
    // Determine the physics body in contact
    // contact.bodyA will always be the tram, and contact.bodyB will always be either a signal fault or passengers since this is a one-way collision
    if contact.bodyB.categoryBitMask == pc.signalFault {
        print("hit signal fault")
        self.endGame()
        // Remove the signal fault from the scene
        contact.bodyB.node?.run(SKAction.removeFromParent())
    } else if contact.bodyB.categoryBitMask == pc.passengers {
        print("picked up passengers")
        self.score += 2
        // Remove the passenger from the scene
        contact.bodyB.node?.run(SKAction.removeFromParent())
    }

    // Prevent multiple contacts with this body
    contact.bodyB.categoryBitMask = pc.none
}
```

Build and run, and you should see the tram continue after picking up passengers, but stop after hitting a signal fault.

Next: [6. Labels and buttons](6-Labels-and-buttons.md)
