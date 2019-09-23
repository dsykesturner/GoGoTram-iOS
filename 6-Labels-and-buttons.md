# 6. Labels and buttons

Now that the game can run from start to finish, it needs a button to restart as well as labels to show the game state to the user.

## New layer

All text should be on top of the background layer and other actors, so inside the `Constants.swift` file, add `static let text:CGFloat = 2` to the `layers` struct.

## New variables

To create the label variables, return to the `GameScene.swift` and add the following to the top of the class:

- `var scoreLabel: SKLabelNode?`
- `var levelLabel: SKLabelNode?`
- `var playGameButton: SKLabelNode?`

These labels also needs adding to the scene. So inside the `setupScene` method, add the following:

```
self.scoreLabel = SKLabelNode()
// Position this label to be centred and 50px from the top of the screen
self.scoreLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height-50)
self.scoreLabel?.zPosition = layers.text
self.addChild(self.scoreLabel!)

self.levelLabel = SKLabelNode()
// Position this label to be centred and 2/3 up the screen
self.levelLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height/3*2)
self.levelLabel?.zPosition = layers.text
// Start on screen hidden
self.levelLabel?.alpha = 0 
self.addChild(self.levelLabel!)

self.playGameButton = SKLabelNode(text: "Play")
// Position this button (really a label) to be centre screen
self.playGameButton?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
self.playGameButton?.zPosition = layers.text
self.playGameButton?.alpha = 0
self.addChild(self.playGameButton!)
```

## Score label

Whenever the `score` variable updates, the `scoreLabel` should also update. For this, a `didSet` can be used as shown below:

```
var score: UInt64 = 0 {
    didSet {
        self.scoreLabel?.text = "\(self.score)"
    }
}
```

## Level label

Add a similar `didSet` to the `levelLabel` as was done for the score label:

```
var level: Int = 0 {
    didSet {
        self.levelLabel?.text = "Level \(self.level)"
    }
}
```

The level doesn't always need to be shown, so will have an `alpha = 0` for most of the time.

When it is needed, it will fade into the screen and fade back out. To do this an action can be used again. Update the code inside the `moveToNextLevel` method to the following:

```
// Show next level label and progress level
self.levelLabel?.run(SKAction.sequence([
    SKAction.fadeIn(withDuration: 0.5),
    SKAction.wait(forDuration: 1),
    SKAction.fadeOut(withDuration: 0.5)
]), completion: {
	// Run a sequence of actions on this scene
	... keep the create collectable action here
})
```

## Play game button

The play game button as well as a "Game Over" label only need to be visible when a game has ended. So add the following code to the `endGame` method to fade these two labels into view:

```
self.levelLabel?.text = "Game Over"
self.levelLabel?.run(SKAction.fadeIn(withDuration: 0.5))
self.playGameButton?.run(SKAction.fadeIn(withDuration: 0.5))
```

Then when the play game button is tapped and the game begins, it can be faded out. Add the following line to the `startGame` method like this:

```
self.playGameButton?.run(SKAction.fadeOut(withDuration: 0.5))
```

The play game button is technically a label, so to make it behave like a button touches on the label can be handled as necessary.

Update the following code inside the `touchesBegan` method:

```
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
    	// Store the position as a local variable
        let position = t.location(in: self)
        // Update the tram position
        self.moveTram(position: position)
        
        // If the play game button is visible, and the touch occurred on the button
        if self.playGameButton?.alpha == 1 && self.playGameButton!.frame.contains(position) {
            // Start a new game
            self.startGame()
        }
    }
}
```

You're done! Build and run, and you should have a playable game which increases the level as your tram progresses. 

Next: [7. Next steps](7-Next-steps.md)
