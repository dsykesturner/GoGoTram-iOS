# Collision detection

## Physics categories

SpriteKit comes with some pretty awesome features, collision detection among them. For collision detection to work, sprites need to have a physics body, and each physics body will need information to answer questions like _"which category of bodies do I fit into?"_ and _"what category of bodies can I collide with?"_.

These are answered by assigning a `physicsCategory` to sprite attributes such as the `contactTestBitMask` which allows collisions to other physics bodies with that `physicsCategory`.

To make some physics categories, go to the `Constants.swift` and create a new struct like this:

```
struct pc {
    static let none: UInt32 = 0x1 << 0
    static let signalFault: UInt32 = 0x1 << 1
    static let passengers: UInt32 = 0x1 << 2
}
```

Now go back to the `GameScene.swift` file and find the `createTram` method. Just before adding the tram to the scene using `self.addChild(self.tram!)`, add the following code to create a physics body that can collide with signal faults and passengers:

```
self.tram?.physicsBody = SKPhysicsBody(texture: tramTexture, size: tramTexture.size())
        
if let pb = self.tram?.physicsBody {
	// This physics body can collide with signal faults and passengers
    pb.contactTestBitMask = (pc.signalFault | pc.passengers)
    // This physics body is completely managed by us
    pb.isDynamic = false
}
```

Next, update the `createCollectable` method with the following code to create a physics body:

```
func createCollectable(imageName: String, categoryBitMask: UInt32) -> SKSpriteNode? {
        
    let texture = SKTexture(imageNamed: imageName)
    let collectable = SKSpriteNode(texture: texture, size: texture.size())
    collectable.zPosition = layers.actor
	collectable.physicsBody = SKPhysicsBody(rectangleOf: texture.size())
	        
	if let pb = collectable.physicsBody {
		// This physics body won't collide with anything, which is okay because the tram will collide with it (yes 1-way collisions are possible)
	    pb.collisionBitMask = pc.none
	    // This physics body has a collision category of whatever is passed in
	    pb.categoryBitMask = categoryBitMask
	    // All physics bodies are affected by gravity unless static or this flag is set false
	    pb.affectedByGravity = false
	    pb.allowsRotation = false
	}

	return collectable
}
```

Since the `createCollectable` method has been updated with a new parameter `categoryBitMask`, it must also be updated in the `setupScene` method like this:

```
self.signalFault = self.createCollectable(imageName: "signalFault", categoryBitMask: pc.signalFault)
self.passengers = self.createCollectable(imageName: "passengers", categoryBitMask: pc.passengers)
```

## Responding to collisions

Next to respond to collisions, add the `SKPhysicsContactDelegate` to the `GameScene` class at the top of the file like this:

```
class GameScene: SKScene, SKPhysicsContactDelegate {
```

Inside the `setupScene` method, add the following line to set the contact delegate to the `GameScene` class:

```
self.physicsWorld.contactDelegate = self
```

Finally, add the method below which will be called by the `SKPhysicsContactDelegate` for every collision:

```
func didBegin(_ contact: SKPhysicsContact) {

	// Determine the physics body in contact
	// contact.bodyA will always be the tram, and contact.bodyB will always be either a signal fault or passengers since this is a one-way collision
	if contact.bodyB.categoryBitMask == pc.signalFault {
		print("hit signal fault")
	} else if contact.bodyB.categoryBitMask == pc.passengers {
		print("picked up passengers")
	}

	// Prevent multiple contacts with this body
    contact.bodyB.categoryBitMask = pc.none
}
```

Build and run, and see what happens!