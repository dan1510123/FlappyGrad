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
    var levelGuideTextField : UITextView = UITextView()
    var scroll : SKSpriteNode!
    var game : SKNode!
    var firstTouch : Bool = false
    
    var birdTexture1 : SKTexture! 
    var birdTexture2 : SKTexture!
    var pipeDownTexture : SKTexture!
    var pipeUpTexture : SKTexture!
    var pipeMidTexture : SKTexture!
    var virus : SKSpriteNode!
    
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
        
        scoreTextField.isEditable = false
        centerTextField.isEditable = false
        levelGuideTextField.isEditable = false
        showLevelGuide()
        setupCenterTextField()
        setupScoreTextField()
        setBackground() // Set background
        createPlayer() // Create player
    }
    
    private func beginPipeSpawnRepeat() {
        let delaySpawn = SKAction.wait(forDuration: TimeInterval(2))
        let spawnOnePipeSet = SKAction.run(spawnPipeSet)
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
    
    private func spawnPipeSet() {
        generateProblem()
        
        let pipeSet = SKNode()
        pipeSet.position = CGPoint(x: frame.midX + 450, y: frame.midY)
        pipeSet.zPosition = 0
        
        // Set starting height of pipe set at random
        let pipeDownHeight = maxPipeDownHeight - CGFloat(arc4random_uniform(UInt32(maxPipeDiff)))
        
        /* Add the pipes to the pipe set */
        let pipeDown = spawnPipe(pipeTexture: pipeDownTexture, yPos: pipeDownHeight)
        pipeSet.addChild(pipeDown)
        
        let pipeMid = spawnPipe(pipeTexture: pipeMidTexture, yPos: pipeDownHeight - CGFloat(pipeDownTexture.size().height / 2) - pipeYGap - CGFloat(pipeMidTexture.size().height / 2))
        pipeSet.addChild(pipeMid)
        
        let pipeUp = spawnPipe(pipeTexture: pipeUpTexture, yPos: pipeDownHeight - CGFloat(pipeDownTexture.size().height / 2) - pipeMid.size.height - 2 * pipeYGap - CGFloat(pipeUpTexture.size().height / 2))
        pipeSet.addChild(pipeUp)
        
        /* Add the slots to the pipe set */
        let rand = arc4random_uniform(2)
        let topSlot = spawnSlot(success: rand == 0, yPos: pipeDownHeight - CGFloat(pipeDownTexture.size().height / 2) - 80)
        pipeSet.addChild(topSlot)
        
        let bottomSlot = spawnSlot(success: rand == 1, yPos: pipeDownHeight - CGFloat(pipeDownTexture.size().height / 2) -  pipeMidTexture.size().height - 190)
        pipeSet.addChild(bottomSlot)
        
        pipeSet.run(movePipesThenRemove)
        game.addChild(pipeSet)
    }
    
    private func spawnPipe(pipeTexture : SKTexture, yPos : CGFloat) -> SKSpriteNode {
        let pipe = SKSpriteNode(texture: pipeTexture)
        pipe.position = CGPoint(x: 0, y: yPos)
        pipe.physicsBody = SKPhysicsBody(rectangleOf: pipe.size)
        pipe.physicsBody?.affectedByGravity = false
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.categoryBitMask = Bitmask.pipe
        pipe.physicsBody?.collisionBitMask = Bitmask.player
        pipe.physicsBody?.contactTestBitMask = Bitmask.player
        return pipe
    }
    
    private func spawnSlot(success: Bool, yPos: CGFloat) -> SKLabelNode {
        let slot = SKLabelNode()
        slot.fontSize = 40
        slot.text = success ? String(problems[problems.count - 1].result()) : String(problems[problems.count - 1].badResult())
        slot.position = CGPoint(x: 0, y: yPos)
        slot.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipeYGap))
        slot.physicsBody?.affectedByGravity = false
        slot.physicsBody?.isDynamic = false
        slot.physicsBody?.categoryBitMask = success ? Bitmask.successSlot : Bitmask.failSlot
        slot.physicsBody?.collisionBitMask = success ? 0 : Bitmask.player   
        slot.physicsBody?.contactTestBitMask = Bitmask.player
        return slot
    }
    
    private func setupCenterTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 300
        centerTextField.frame = CGRect(x: frame.midX - 400, y: frame.midY + 250, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.backgroundColor = UIColor.red
        centerTextField.text = "Hello"
    }
    
    private func gameOverCenterTextField() {
        let textFieldWidth : CGFloat = 300
        let textFieldHeight : CGFloat = 120
        centerTextField.frame = CGRect(x: frame.midX, y: frame.midY + 300, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.backgroundColor = UIColor.gray
        centerTextField.textColor = UIColor.white
        centerTextField.font = UIFont.systemFont(ofSize: 20)
        if currentTitle == "Undergrad Senior" {
            centerTextField.text = "Unfortunately, you were unable to graduate. Better brush up on those math skills.\nBetter luck next time!"
        }
        else {
            centerTextField.text = "Congratulations! You have graduated with a " + currentTitle + " before falling victim to the virus"
        }
    }
    
    private func setupProblemInCenterTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 100
        centerTextField.frame = CGRect(x: frame.midX - 100, y: frame.midY - CGFloat(textFieldHeight / 2) - 250, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.font = UIFont.boldSystemFont(ofSize: 70)
        centerTextField.backgroundColor = UIColor.cyan
        centerTextField.text = ""
    }
    
    private func updateProblemInCenterTextField() {
        centerTextField.text = problems[0].toString()
    }
    
    private func showLevelGuide() {
        scroll = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "scrollwithlogos.png")))
        scroll.zPosition = -5
        scroll.position = CGPoint(x: frame.midX + 250, y: frame.midY)
        addChild(scroll)
        
        levelGuideTextField.isHidden = false
        let textFieldWidth : CGFloat = 300
        let textFieldHeight : CGFloat = 680
        levelGuideTextField.frame = CGRect(x: frame.midX + 470, y: frame.midY - 130, width: textFieldWidth, height: textFieldHeight)
        levelGuideTextField.font = UIFont(name: "Papyrus", size: 30)
        levelGuideTextField.backgroundColor = nil
        levelGuideTextField.text = "LEGENDARY\nGRAD REQS\n\n" + "Undergrad Senior  0\n\n" + "     B.S. Degree        15\n\n" + "     M.S. Degree      30\n\n" + "           Ph.D.              50\n\n" + "      M.D. Ph.D.       100\n\n" + "   * Zoom Lord *    200"
    }
    
    private func hideLevelGuide() {
        levelGuideTextField.isHidden = true
        let distanceToMove = CGFloat(scroll.size.width + 10)
        let moveScroll = SKAction.moveBy(x: distanceToMove, y:0.0, duration:TimeInterval(1.5))
        let destroyScroll = SKAction.removeFromParent()
        let moveScrollThenRemove = SKAction.sequence([moveScroll, destroyScroll])
        scroll.run(moveScrollThenRemove)
    }
    
    private func setupScoreTextField() {
        let textFieldWidth : CGFloat = 400
        let textFieldHeight : CGFloat = 200
        scoreTextField.frame = CGRect(x: frame.midX - 550, y: frame.midY - CGFloat(textFieldHeight / 2) - 200, width: textFieldWidth, height: textFieldHeight)
        scoreTextField.textAlignment = .center
        scoreTextField.backgroundColor = UIColor.blue
        scoreTextField.font = UIFont.boldSystemFont(ofSize: 42)
        updateScoreTextField()
    }
    
    private func updateScoreTextField() {
        scoreTextField.text = "Zoom Credits\n" + String(zoomScore) + "\n" + currentTitle
    }
    
    private func setBackground() {
        // Background texture
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg.png")))
        bg.setScale(6)
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        // Virus texture
        let v1 = SKTexture(image: #imageLiteral(resourceName: "virus.png"))
        let v2 = SKTexture(image: #imageLiteral(resourceName: "virus2.png"))
        let v3 = SKTexture(image: #imageLiteral(resourceName: "virus3.png"))
        
        virus = SKSpriteNode(texture: v1)
        virus.setScale(1)
        virus.zPosition = 10
        virus.position = CGPoint(x: frame.midX - 400, y: frame.midY)
        let virusAnimate = SKAction.animate(with: [v1, v2, v3], timePerFrame: 0.3)
        let virusAnimateForever = SKAction.repeatForever(virusAnimate)
        virus.run(virusAnimateForever)
        addChild(virus)
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
            setupProblemInCenterTextField()
            hideLevelGuide()
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
                gameOverActions()
            }
            else {
                
            }
        }
    }
    
    private func gameOverActions() {
        var titleIcon : SKTexture!
        switch(currentTitle) {
            case "B.S. Degree":
            titleIcon = SKTexture(image: #imageLiteral(resourceName: "bsd.png"))
            case "M.S. Degree":
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "msd.png"))
            case "Ph.D.":
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "phd.png"))
            case "M.D. Ph.D.":
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "mdphd.png"))
            case "** Zoom Lord **":
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "zoomlord2.png"))
            default:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "ugs.png"))
        }
        var titleSprite = SKSpriteNode(texture: titleIcon)
        titleSprite.setScale(2.5)
        titleSprite.zPosition = 10
        titleSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(titleSprite)
        
        let distanceToMove = CGFloat(120)
        let moveVirus = SKAction.moveBy(x: distanceToMove, y:0.0, duration:TimeInterval(3))
        virus.run(moveVirus)
        
        gameOverCenterTextField()
    }
    
    public func getScoreTextField() -> UITextView {
        return scoreTextField
    }
    
    public func getCenterTextField() -> UITextView {
        return centerTextField
    }
    
    public func getLevelGuideTextField() -> UITextView {
        return levelGuideTextField
    }
}




