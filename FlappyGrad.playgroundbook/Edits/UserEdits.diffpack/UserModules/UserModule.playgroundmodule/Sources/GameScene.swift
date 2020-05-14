// Code inside modules can be shared between pages and other source files.
import SpriteKit

public class GameScene : SKScene, SKPhysicsContactDelegate {
    /* Global fields */
    var player : SKSpriteNode!
    
    let pipeSpeed : CGFloat = 1
    let pipeYGap : CGFloat = 120
    let maxPipeDiff : CGFloat = 140
    let maxPipeDownHeight : CGFloat = 330
    var movePipesThenRemove : SKAction!
    
    var zoomScore : Int = 0
    var currentTitle : String = "Undergrad Senior"
    var scoreTextField : UITextView = UITextView()
    var centerTextField : UITextView = UITextView()
    var degreeLevelTextField : UITextView = UITextView()
    var game : SKNode!
    var firstTouch : Bool = false
    
    var birdTexture1 : SKTexture!
    var birdTexture2 : SKTexture!
    var pipeDownTexture : SKTexture!
    var pipeUpTexture : SKTexture!
    var pipeMidTexture : SKTexture!
    
    var problems = [Problem]()
    
    public override func didMove(to view: SKView) {
        // Set up gameIsActive node
        game = SKNode()
        game.speed = 0
        self.addChild(game)
        
        // Set up the Physics of the Scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0
        physicsBody?.categoryBitMask = Bitmask.world
        physicsBody?.collisionBitMask = Bitmask.player
        physicsBody?.contactTestBitMask = Bitmask.player
        // Contact (collisions) will be handled by this class
        physicsWorld.contactDelegate = self 
        
        pipeDownTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_down.png"))
        pipeUpTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_up.png"))
        pipeMidTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_middle.png"))
        
        initDegreeLevelTextField()
        updateScoreTextField()
        setBackground() // Set background
        createPlayer() // Create player
    }
    
    private func beginPipeSpawnRepeat() {
        let delaySpawn = SKAction.wait(forDuration: TimeInterval(1.5))
        let spawnOnePipeSet = SKAction.run(spawnPipes)
        let spawnThenDelay = SKAction.sequence([delaySpawn, spawnOnePipeSet])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        run(spawnThenDelayForever)
    }
    
    private func setupPipeMovement() {
        let distanceToMove = CGFloat(frame.size.width)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(5.0))
        let destroyPipes = SKAction.removeFromParent()
        movePipesThenRemove = SKAction.sequence([movePipes, destroyPipes])
    }
    
    private func generateProblem() {
        var x = Int(arc4random_uniform(30)) + 1
        var y = Int(arc4random_uniform(30)) + 1
        problems.append(Problem(x: x, op: "+", y: y))
        updateProblemInCenterTextField()
    }
    
    private func spawnPipes() {
        generateProblem()
        
        let scale : CGFloat = 3
        let pipeSet = SKNode()
        pipeSet.position = CGPoint(x: frame.midX + 450, y: frame.midY)
        pipeSet.zPosition = 0
        
        // Set starting height of pipe set at random
        let pipeDownHeight = maxPipeDownHeight - CGFloat(arc4random_uniform(UInt32(maxPipeDiff)))
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture)
        pipeDown.setScale(scale)
        pipeDown.position = CGPoint(x: 0, y: pipeDownHeight)
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.physicsBody?.affectedByGravity = false
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = Bitmask.pipe
        pipeDown.physicsBody?.collisionBitMask = Bitmask.player
        pipeDown.physicsBody?.contactTestBitMask = Bitmask.player
        pipeSet.addChild(pipeDown)
        
        let rand = arc4random_uniform(2)
        let topSlot = SKLabelNode()
        topSlot.fontSize = 40
        topSlot.text = rand == 0 ? String(problems[problems.count - 1].result()) : String(problems[problems.count - 1].badResult())
        topSlot.position = CGPoint(x: 0, y: pipeDownHeight - CGFloat(pipeDown.size.height / 2) - 80)
        topSlot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipeYGap))
        topSlot.physicsBody?.affectedByGravity = false
        topSlot.physicsBody?.categoryBitMask = rand == 0 ? Bitmask.successSlot : Bitmask.failSlot
        topSlot.physicsBody?.collisionBitMask = 0
        topSlot.physicsBody?.contactTestBitMask = Bitmask.player
        pipeSet.addChild(topSlot)
        
        let pipeMid = SKSpriteNode(texture: pipeMidTexture)
        pipeMid.setScale(scale)
        pipeMid.position = CGPoint(x: 0, y: pipeDownHeight - CGFloat(pipeDown.size.height / 2) - pipeYGap - CGFloat(pipeMid.size.height / 2)) 
        pipeMid.physicsBody = SKPhysicsBody(rectangleOf: pipeMid.size)
        pipeMid.physicsBody?.affectedByGravity = false
        pipeMid.physicsBody?.isDynamic = false
        pipeMid.physicsBody?.categoryBitMask = Bitmask.pipe
        pipeMid.physicsBody?.collisionBitMask = Bitmask.player
        pipeMid.physicsBody?.contactTestBitMask = Bitmask.player
        pipeSet.addChild(pipeMid)
        
        let bottomSlot = SKLabelNode()
        bottomSlot.fontSize = 40
        bottomSlot.text = rand == 1 ? String(problems[problems.count - 1].result()) : String(problems[problems.count - 1].badResult())
        bottomSlot.position = CGPoint(x: 0, y: pipeDownHeight - CGFloat(pipeDown.size.height / 2) -  pipeMid.size.height - 190)
        bottomSlot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipeYGap))
        bottomSlot.physicsBody?.affectedByGravity = false
        bottomSlot.physicsBody?.categoryBitMask = rand == 1 ? Bitmask.successSlot : Bitmask.failSlot
        bottomSlot.physicsBody?.collisionBitMask = 0
        bottomSlot.physicsBody?.contactTestBitMask = Bitmask.player
        pipeSet.addChild(bottomSlot)
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture)
        pipeUp.setScale(scale)
        pipeUp.position = CGPoint(x: 0, y: pipeDownHeight - CGFloat(pipeDown.size.height / 2) - pipeMid.size.height - 2 * pipeYGap - CGFloat(pipeUp.size.height / 2))
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.physicsBody?.affectedByGravity = false
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = Bitmask.pipe
        pipeUp.physicsBody?.collisionBitMask = Bitmask.player
        pipeUp.physicsBody?.contactTestBitMask = Bitmask.player
        pipeSet.addChild(pipeUp)
        pipeSet.run(movePipesThenRemove)
        game.addChild(pipeSet)
    }
    
    private func setupCenterTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 150
        centerTextField.frame = CGRect(x: frame.midX - 100, y: frame.midY - CGFloat(textFieldHeight / 2) - 203, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.backgroundColor = UIColor.red
        centerTextField.text = "Hello"
    }
    
    private func updateProblemInCenterTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 100
        centerTextField.frame = CGRect(x: frame.midX - 100, y: frame.midY - CGFloat(textFieldHeight / 2) - 250, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.font = UIFont.boldSystemFont(ofSize: 70)
        centerTextField.backgroundColor = UIColor.cyan
        centerTextField.text = problems[0].toString()
    }
    
    private func initDegreeLevelTextField() {
        let textFieldWidth : CGFloat = 300
        let textFieldHeight : CGFloat = 650
        degreeLevelTextField.frame = CGRect(x: frame.midX + 500, y: frame.midY - 275, width: textFieldWidth, height: textFieldHeight)
        degreeLevelTextField.backgroundColor = UIColor.brown
        degreeLevelTextField.font = UIFont.boldSystemFont(ofSize: 25)
        degreeLevelTextField.text = "\nLEVEL GUIDE\n\n" + "Undergrad Senior   0\n\n" + "B.S. Degree              15\n\n" + "M.S. Degree            30\n\n" + "Ph.D.                           50\n\n" + "M.D. Ph.D.              100\n\n" + "Zoom Lord            200"
    }
    
    private func updateScoreTextField() {
        let textFieldWidth : CGFloat = 360
        let textFieldHeight : CGFloat = 150
        scoreTextField.frame = CGRect(x: frame.midX - 470, y: frame.midY - CGFloat(textFieldHeight / 2) - 230, width: textFieldWidth, height: textFieldHeight)
        scoreTextField.textAlignment = .center
        scoreTextField.backgroundColor = UIColor.blue
        scoreTextField.font = UIFont.boldSystemFont(ofSize: 35)
        scoreTextField.text = String(zoomScore) + " Zoom Credits\n" + currentTitle
    }
    
    private func setBackground() {
        // Background texture
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg.png")))
        bg.setScale(6)
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
    }
    
    private func createPlayer() {
        birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird1new.png"))
        birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird2new.png"))
        
        player = SKSpriteNode(texture: birdTexture1)
        player.setScale(1.6)
        player.zPosition = 0
        player.position = CGPoint(x: frame.midX - 190, y: frame.midY)
        addChild(player)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2.0)
        player.physicsBody?.mass = 0.03
        player.physicsBody?.affectedByGravity = false;
        player.physicsBody?.categoryBitMask = Bitmask.player
        player.physicsBody?.collisionBitMask = Bitmask.pipe | Bitmask.world
        player.physicsBody?.contactTestBitMask = Bitmask.pipe | Bitmask.failSlot | Bitmask.successSlot
        // Set flap animation for player
        let flapAnimation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.4)
        let flapAction = SKAction.repeatForever(flapAnimation)
        player.run(flapAction)
    }
    
    // Update on each frame
    public override func update(_ currentTime: TimeInterval) {
        // Set rotation of player to be between -1 and 0.5   
        if game.speed > 0 {
            player.zRotation = min( max(-1, player.physicsBody!.velocity.dy * 0.001), 0.5 )
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !firstTouch {
            firstTouch = true
            game.speed = 1
            setupPipeMovement()
            beginPipeSpawnRepeat()
        }
        if game.speed > 0 {
            player.physicsBody?.affectedByGravity = true
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 11))
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        if game.speed > 0 {
            if (contact.bodyA.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot || (contact.bodyB.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot {
                // Handle a collision with the successSlot (increment score)
                zoomScore += 1
                
                /* Update the currentTitle based on zoomScore */
                if zoomScore < 1 {
                    currentTitle = "Undergrad Senior"
                }
                else if zoomScore < 2 {
                    currentTitle = "B.S. Degree"
                }
                else if zoomScore < 3 {
                    currentTitle = "M.S. Degree"
                } 
                else if zoomScore < 100 {
                    currentTitle = "Ph.D."
                }
                else if zoomScore < 200 {
                    currentTitle = "M.D. Ph.D."
                }
                else {
                    currentTitle = "** Zoom Lord **"
                }
                updateScoreTextField()
                problems.remove(at: 0)
                updateProblemInCenterTextField()
            }
            else if (contact.bodyA.categoryBitMask & Bitmask.failSlot) == Bitmask.failSlot || (contact.bodyB.categoryBitMask & Bitmask.failSlot) == Bitmask.failSlot || (contact.bodyA.categoryBitMask & Bitmask.pipe) == Bitmask.pipe || (contact.bodyB.categoryBitMask & Bitmask.pipe) == Bitmask.pipe {
                // Stop gameplay
                game.speed = 0
                removeAllActions()
            }
            else {
                
            }
        }
    }
    
    public func getScoreTextField() -> UITextView {
        return scoreTextField
    }
    
    public func getCenterTextField() -> UITextView {
        return centerTextField
    }
    
    public func getDegreeLevelTextField() -> UITextView {
        return degreeLevelTextField
    }
}




