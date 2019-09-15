//
//  GameScene.swift
//  GoGoTram
//
//  Created by Daniel Sykes-Turner on 6/9/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Actors
    var tram: SKSpriteNode?
    var signalFault: SKSpriteNode?
    var passengers: SKSpriteNode?
    var fire: SKLabelNode?
    // Labels
    var scoreLabel: SKLabelNode?
    var levelLabel: SKLabelNode?
    var playGameButton: SKLabelNode?
    // Game Variables
    var score: UInt64 = 0 {
        didSet {
            if let scoreLabel = self.scoreLabel {
                if scoreBonus > 0 {
                    scoreLabel.text = "\(self.score) (+\(self.scoreBonus))"
                } else {
                    scoreLabel.text = "\(self.score)"
                }
            }
        }
    }
    var scoreBonus: UInt64 = 0 {
        didSet {
            if let scoreLabel = self.scoreLabel {
                if scoreBonus == 0 {
                    scoreLabel.text = "\(self.score)"
                }
            }
        }
    }
    var level: Int = 0
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
        //collectable.physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.3, size: texture.size())
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
        
        self.fire = SKLabelNode(text: "🔥")
        self.fire?.position = collisionPoint
        self.fire?.zPosition = layers.fire
        self.fire?.alpha = 0
        
        self.addChild(self.fire!)
        self.fire?.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    // MARK: Game State
    
    func startGame() {

        self.gameStarted = true
        self.score = 0
        self.scoreBonus = 0
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
        
//        signalFault.run(SKAction.removeFromParent())
    }
    
    func moveToNextLevel() {
        
        self.level += 1
        let numberOfCollectables = self.level * 50
        
        // Show next level label and progress level
        self.levelLabel?.text = "Level \(self.level)"
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
    
    func updateTram(position: CGPoint) {
        
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
            if collectable.physicsBody?.categoryBitMask == pc.passengers {
                self.scoreBonus = 0
            }
        })
    }
    
    func handleContact(signalFault: SKSpriteNode, collisionPoint: CGPoint) {
        print("hit signalFault")
        signalFault.physicsBody?.collisionBitMask = pc.none
        signalFault.removeAllActions()
        self.endGame(signalFault: signalFault, collisionPoint: collisionPoint)
    }
    
    func handleContact(passengers: SKSpriteNode) {
        print("hit passengers")
        passengers.run(SKAction.removeFromParent())
        self.score += (2+self.scoreBonus)
        self.scoreBonus += 1
    }
    
    // MARK: Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            
            self.updateTram(position: position)
            
            if self.playGameButton?.alpha == 1 && self.playGameButton!.frame.contains(position) {
                self.startGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.updateTram(position: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.updateTram(position: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.updateTram(position: t.location(in: self)) }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
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
