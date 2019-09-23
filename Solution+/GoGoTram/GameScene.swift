//
//  GameScene.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 6/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Actors
    var tram: SKSpriteNode?
    var signalFault: SKSpriteNode?
    var passengers: SKSpriteNode?
    var endGameActors = [SKNode]()
    // Labels
    var scoreLabel: SKLabelNode?
    var levelLabel: SKLabelNode?
    var playGameButton: SKLabelNode?
    // Game Variables
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
    // Game Constants
    let createCollectablesActionKey = "createCollectables"
    
    
    // MARK: Scene Setup
    
    override func didMove(to view: SKView) {
        
        self.setupScene()
    }
    
    func setupScene() {
        
        self.physicsWorld.contactDelegate = self
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        backgroundImage.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundImage.size = self.size
        backgroundImage.zPosition = layers.background
        self.addChild(backgroundImage)
        
        self.createTram()
        self.signalFault = self.createCollectable(imageName: "signalFault", categoryBitMask: pc.signalFault)
        self.passengers = self.createCollectable(imageName: "passengers", categoryBitMask: pc.passengers)
        
        self.scoreLabel = SKLabelNode()
        self.scoreLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height-50)
        self.scoreLabel?.zPosition = layers.text
        self.scoreLabel?.alpha = 0
        self.addChild(self.scoreLabel!)
        
        self.levelLabel = SKLabelNode()
        self.levelLabel?.position = CGPoint(x: self.size.width/2, y: self.size.height/3*2)
        self.levelLabel?.zPosition = layers.text
        self.levelLabel?.alpha = 0
        self.addChild(self.levelLabel!)
        
        self.playGameButton = SKLabelNode(text: "Play")
        self.playGameButton?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.playGameButton?.zPosition = layers.text
        self.addChild(self.playGameButton!)
    }
    
    func createTram() {
        
        let tramTexture = SKTexture(imageNamed: "tram")
        self.tram = SKSpriteNode(texture: tramTexture, size: tramTexture.size())
        self.tram?.position = CGPoint(x: 150, y: self.size.height/2)
        self.tram?.zPosition = layers.actor
        self.tram?.alpha = 0
        self.tram?.physicsBody = SKPhysicsBody(texture: tramTexture, size: tramTexture.size())
        
        if let pb = self.tram?.physicsBody {
            pb.contactTestBitMask = (pc.signalFault | pc.passengers)
            pb.isDynamic = false
        }
        self.addChild(self.tram!)
    }
    
    func createCollectable(imageName: String, categoryBitMask: UInt32) -> SKSpriteNode? {
        
        let texture = SKTexture(imageNamed: imageName)
        let collectable = SKSpriteNode(texture: texture, size: texture.size())
        collectable.zPosition = layers.actor
        collectable.physicsBody = SKPhysicsBody(rectangleOf: texture.size())
        
        if let pb = collectable.physicsBody {
            pb.collisionBitMask = pc.none
            pb.categoryBitMask = categoryBitMask
            pb.affectedByGravity = false
            pb.allowsRotation = false
        }
        
        return collectable
    }
    
    func createFire(collisionPoint: CGPoint) {
        
        let fire = SKLabelNode(text: "🔥")
        fire.position = collisionPoint
        fire.zPosition = layers.fire
        fire.alpha = 0
        
        self.endGameActors.append(fire)
        self.addChild(fire)
        fire.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    // MARK: Game State
    
    func startGame() {

        self.gameStarted = true
        self.score = 0
        self.level = 0
        
        self.tram?.run(SKAction.fadeIn(withDuration: 0.5))
        self.scoreLabel?.run(SKAction.fadeIn(withDuration: 0.5))
        self.playGameButton?.run(SKAction.fadeOut(withDuration: 0.5))
        
        self.moveToNextLevel()
    }
    
    func endGame(signalFault: SKSpriteNode, collisionPoint: CGPoint) {
        
        self.gameStarted = false
        self.removeAction(forKey: self.createCollectablesActionKey)
        
        self.levelLabel?.text = "Game Over"
        self.levelLabel?.run(SKAction.fadeIn(withDuration: 0.5))
        self.playGameButton?.text = "Play Again"
        self.playGameButton?.run(SKAction.fadeIn(withDuration: 0.5))
        
        self.createFire(collisionPoint: collisionPoint)
    }
    
    func moveToNextLevel() {
        
        self.level += 1
        let numberOfCollectables = self.level * 50
        
        // Show next level label and progress level
        self.levelLabel?.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 1),
            SKAction.fadeOut(withDuration: 0.5)
        ]), completion: {
            self.run(SKAction.sequence([
                    SKAction.repeat(
                        SKAction.sequence([
                            SKAction.run(self.createRandomCollectable),
                            SKAction.wait(forDuration: 0.6)
                        ]), count: numberOfCollectables),
                    SKAction.wait(forDuration: 2),
                    SKAction.run(self.moveToNextLevel)
                ]), withKey: self.createCollectablesActionKey)
        })
    }
    
    // MARK: Sprite Handling
    
    func moveTram(position: CGPoint) {
        
        if let tram = self.tram, self.gameStarted == true {
            tram.position = CGPoint(x: 150, y: position.y)
        }
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
        
        guard let collectable = collectable else { return }
        
        let screenHeight = self.size.height
        let screenWidth = self.size.width
        let startingX = screenWidth + collectable.frame.size.width/2
        let startingY = CGFloat(arc4random() % UInt32(screenHeight - collectable.frame.size.height)) + collectable.frame.size.height/2
        
        collectable.position = CGPoint(x: startingX, y: startingY)
        self.addChild(collectable)
        
        let endingX = -collectable.frame.size.width/2
        let endingY = startingY
        collectable.run(
            SKAction.move(to: CGPoint(x: endingX, y: endingY), duration: 2),
        completion: {
            collectable.run(SKAction.removeFromParent())
        })
    }
    
    func handleContact(signalFault: SKSpriteNode, collisionPoint: CGPoint) {
        print("hit signalFault")
        signalFault.physicsBody?.collisionBitMask = pc.none
        signalFault.removeAllActions()
        self.endGameActors.append(signalFault)
        self.endGame(signalFault: signalFault, collisionPoint: collisionPoint)
    }
    
    func handleContact(passengers: SKSpriteNode) {
        print("picked up passengers")
        passengers.run(SKAction.removeFromParent())
        self.score += 2
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            
            self.moveTram(position: position)
            
            if self.playGameButton?.alpha == 1 && self.playGameButton!.frame.contains(position) {
                // Remove all end game actors (this doesn't include the tram)
                for actor in self.endGameActors {
                    actor.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                }
                self.endGameActors.removeAll()
                
                // Start a new game
                self.startGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveTram(position: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveTram(position: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveTram(position: t.location(in: self)) }
    }
    
    // MARK: SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyB.categoryBitMask == pc.signalFault, let signalFault = contact.bodyB.node as? SKSpriteNode {
            self.handleContact(signalFault: signalFault, collisionPoint: contact.contactPoint)
        } else if contact.bodyB.categoryBitMask == pc.passengers, let passengers = contact.bodyB.node as? SKSpriteNode {
            self.handleContact(passengers: passengers)
        }
        // Prevent multiple contacts with this body
        contact.bodyB.categoryBitMask = pc.none
    }
}
