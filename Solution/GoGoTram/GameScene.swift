//
//  GameScene.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 22/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Actors
    var tram: SKSpriteNode?
    var signalFault: SKSpriteNode?
    var passengers: SKSpriteNode?
    // Game state
    var score: UInt64 = 0 {
        didSet {
            self.scoreLabel?.text = "\(self.score)"
        }
    }
    var level: Int = 0 {
        didSet {
            self.levelLabel?.text = "Level \(self.level)"
        }
    }
    var gameStarted: Bool = false
    let createCollectablesActionKey = "createCollectables"
    // Labels
    var scoreLabel: SKLabelNode?
    var levelLabel: SKLabelNode?
    var playGameButton: SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.setupScene()
        self.startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            // Store the position as a local variable
            let position = t.location(in: self)
            // Update the tram position
            self.moveTram(position: position)
            
            // If the play game button is visible, and the touch occured on the button
            if self.playGameButton?.alpha == 1 && self.playGameButton!.frame.contains(position) {
                // Start a new game
                self.startGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.moveTram(position: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.moveTram(position: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.moveTram(position: t.location(in: self))
        }
    }
    
    func setupScene() {
        self.createTram()
        self.signalFault = self.createCollectable(imageName: "signalFault", categoryBitMask: pc.signalFault)
        self.passengers = self.createCollectable(imageName: "passengers", categoryBitMask: pc.passengers)
        
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        backgroundImage.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundImage.size = self.size
        backgroundImage.zPosition = layers.background
        self.addChild(backgroundImage)
        
        self.scoreLabel = SKLabelNode()
        // Position this label to be centered and 50px from the top of the screen
        self.scoreLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height-50)
        self.scoreLabel?.zPosition = layers.text
        self.addChild(self.scoreLabel!)

        self.levelLabel = SKLabelNode()
        // Position this label to be centered and 2/3 up the screen
        self.levelLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height/3*2)
        self.levelLabel?.zPosition = layers.text
        // Start on screen hidden
        self.levelLabel?.alpha = 0
        self.addChild(self.levelLabel!)

        self.playGameButton = SKLabelNode(text: "Play")
        // Position this button (really a label) to be center screen
        self.playGameButton?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.playGameButton?.zPosition = layers.text
        self.playGameButton?.alpha = 0
        self.addChild(self.playGameButton!)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func createTram() {
        // Create a texture from the tram image
        let tramTexture = SKTexture(imageNamed: "tram")
        // Create a sprite node from the tram texture, with the matching size
        self.tram = SKSpriteNode(texture: tramTexture, size: tramTexture.size())
        // Move the tram to 150px from the left of the screen, and half way up it
        self.tram?.position = CGPoint(x: 150, y: self.size.height/2)
        self.tram?.zPosition = layers.actor
        
        self.tram?.physicsBody = SKPhysicsBody(texture: tramTexture, size: tramTexture.size())
        if let pb = self.tram?.physicsBody {
            // This physics body can collide with signal faults and passengers
            pb.contactTestBitMask = (pc.signalFault | pc.passengers)
            // This physics body is completely managed by us
            pb.isDynamic = false
        }
        
        // Add the tram to the screen
        self.addChild(self.tram!)
    }
    
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
    
    func moveTram(position: CGPoint) {
        if let tram = self.tram, self.gameStarted == true {
            tram.position = CGPoint(x: 150, y: position.y)
        }
    }
    
    func startGame() {
        self.gameStarted = true
        self.level = 0
        self.score = 0
        
        self.playGameButton?.run(SKAction.fadeOut(withDuration: 0.5))
        
        self.moveToNextLevel()
    }
    
    func endGame() {
        self.gameStarted = false
        self.removeAction(forKey: self.createCollectablesActionKey)
        
        self.levelLabel?.text = "Game Over"
        self.levelLabel?.run(SKAction.fadeIn(withDuration: 0.5))
        self.playGameButton?.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func moveToNextLevel() {
        // Increment level by 1 every time this method is called
        self.level += 1
        // Increase the number of collectables every time the level increases
        let numberOfCollectables = self.level * 50
        
        // Show next level label and progress level
        self.levelLabel?.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1),
            SKAction.fadeOut(withDuration: 0.5)
        ]), completion: {
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
        })
    }
    
    func createRandomCollectable() {
        let randomItem = arc4random() % 1000 // 0 - 999
        if randomItem < 667 {
            // 66.7% chance
            self.spawnNew(collectable: self.signalFault?.copy() as? SKSpriteNode)
        } else {
            // 33.3% chance
            self.spawnNew(collectable: self.passengers?.copy() as? SKSpriteNode)
        }
    }
    
    func spawnNew(collectable: SKSpriteNode?) {
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
    }
    
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
}
