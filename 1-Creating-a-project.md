# 1. Creating a project

## Create a new Swift game project

1. Open Xcode and choose new Xcode Project
2. Select an iOS Game
3. Name it "GoGoTram"
4. Enter "Organisation Name" as your name
5. If you have a personal website, reverse it and enter it as your "Organisation Identifier"
6. Choose Swift as the language
7. Choose SpriteKit as the game technology
8. Untick any boxes below
9. Click "Next" and save your project

## Remove unnecessary files

In Xcode 11 this project will come with a few files which can be deleted since we won't be using them in this game.

Delete the below files from the project, selecting "Move to Trash" when prompted:

- `GameScene.sks`
- `Actions.sks`

## GameViewController.swift

In the `GameViewController` under the `viewDidLoad` method, the game scene is created from the `GameScene.sks` file that was just deleted. Since this file no longer exists, the `GameScene` class can be loaded directly. 

Change this:
```
// Load the SKScene from 'GameScene.sks'
if let scene = SKScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    view.presentScene(scene)
}
```

into this:
```
let scene = GameScene(size: view.frame.size)
view.presentScene(scene)
```

Because this game will be in landscape, a variable called `supportedInterfaceOrientations` also needs to be updated.

Change it's contents from this:
```
if UIDevice.current.userInterfaceIdiom == .phone {
    return .allButUpsideDown
} else {
    return .all
}
```

to this:
```
return .landscape
```

Lastly, add another variable below to prevent users with home bars (e.g. iPhone X) from accidentally exiting the game mid-play by swiping up the home bar:
```
override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
  return .bottom
}
```

## GameScene.swift

The default game scene file also comes with a fair amount of example code that won't be needed for the game.

Everything inside the `GameScene` class can be deleted except for the `didMove` method and override touch methods (e.g. `override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)`).

The result should look like this:
```
class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
}
```

Next: [2. Creating a tram](2-Creating-a-tram.md)
