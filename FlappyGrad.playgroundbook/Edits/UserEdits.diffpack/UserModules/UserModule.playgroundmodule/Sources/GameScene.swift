// Code inside modules can be shared between pages and other source files.
import SpriteKit
import AVFoundation

public class GameScene : SKScene, SKPhysicsContactDelegate {
    /* Global fields */
    var player : SKSpriteNode!
    
    let pipeSpeed : CGFloat = 1
    let pipeYGap : CGFloat = 120
    let maxPipeDiff : CGFloat = 70
    let maxPipeDownHeight : CGFloat = 290
    var movePipesThenRemove : SKAction!
    
    var zoomScore : Int = 0
    var currentTitle : String = Levels.ugs.name
    var scoreUI : SKNode!
    var statusLabel : SKLabelNode!
    var scoreLabel : SKLabelNode!
    var problemLabel : SKLabelNode!
    var textLabel : SKLabelNode!
    var textBackgroundSprite : SKSpriteNode!
    var scroll : SKSpriteNode!
    var centerSprite : SKSpriteNode!
    var game : SKNode!
    var clicksEnabled : Bool = true
    var firstTouch : Bool = false
    
    var birdTexture1 : SKTexture! 
    var birdTexture2 : SKTexture!
    var pipeDownTexture : SKTexture!
    var pipeUpTexture : SKTexture!
    var pipeMidTexture : SKTexture!
    var virus : SKSpriteNode!
    var gameOverSprite : SKNode!
    var virusAnimateForever : SKAction!
    
    var problems = [Problem]()
    
    var backgroundSong : AVAudioPlayer!
    var gameOverSound : AVAudioPlayer!
    var flapSound : AVAudioPlayer!
    
    public override func didMove(to view: SKView) {
        // Music from https://www.bensound.com/royalty-free-music/track/a-new-beginning
        let bgSoundPath = Bundle.main.path(forResource: "song.mp3", ofType:nil)!
        let bgSoundUrl = URL(fileURLWithPath: bgSoundPath)
        
        // Game over sound from https://freesound.org/people/josepharaoh99/sounds/364929/
        let gameOverSoundPath = Bundle.main.path(forResource: "gameOver.mp3", ofType:nil)!
        let gameOverSoundUrl = URL(fileURLWithPath: gameOverSoundPath)
        
        // Bird flap / jump sound from https://freesound.org/people/josepharaoh99/sounds/362328/
        let flapSoundPath = Bundle.main.path(forResource: "flap.mp3", ofType:nil)!
        let flapSoundUrl = URL(fileURLWithPath: flapSoundPath)
        
        do {
            backgroundSong = try AVAudioPlayer(contentsOf: bgSoundUrl)
            backgroundSong?.numberOfLoops = -1
            backgroundSong?.volume = 0.5
            backgroundSong?.play()
            gameOverSound = try AVAudioPlayer(contentsOf: gameOverSoundUrl)
            gameOverSound?.volume = 0.4
            flapSound = try AVAudioPlayer(contentsOf: flapSoundUrl)
            flapSound?.volume = 0.3
        } catch {
            // Couldn't load music
        }
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
        
        frequentTextureSetup()
        fullSetup()
    }
    
    private func frequentTextureSetup() {
        pipeDownTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_down.png"))
        pipeUpTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_up.png"))
        pipeMidTexture = SKTexture(image: #imageLiteral(resourceName: "pipe_middle.png"))
    }
    
    private func fullSetup() {
        showLevelGuide()
        setupCenterLabel()
        setupScoreTextField()
        updateScoreTextField()
        setupTextLabel()
        setBackground()
        createPlayer() 
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
        pipeSet.zPosition = -8
        
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
        let slot = SKLabelNode(fontNamed: "AvenirNext-Bold")
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
    
    private func setupCenterLabel() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 300
        problemLabel = SKLabelNode()
        problemLabel.fontSize = 50
        problemLabel.fontName = "AvenirNext-Bold"
        problemLabel.zPosition = 0
        problemLabel.position = CGPoint(x: frame.midX, y: frame.midY + CGFloat(frame.height / 2) - 80)
        problemLabel.text = "Exam Qs"
        centerSprite = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "center.png")))
        centerSprite.zPosition = -4
        centerSprite.position = CGPoint(x: frame.midX, y:  frame.midY + CGFloat(frame.height / 2) - 58)
        addChild(centerSprite)
        addChild(problemLabel)
    }
    
    private func setupProblemInCenterTextField() {
        problemLabel.position = CGPoint(x: frame.midX, y:  frame.midY + CGFloat(frame.height / 2) - 80)
    }
    
    private func updateProblemInCenterTextField() {
        problemLabel.text = problems[0].toString() + "?"
    }
    
    private func showCorrectAnswer() {
        problemLabel.text = problems[0].toString() + String(problems[0].result())
    }
    
    private func setupTextLabel() {
        let textFieldWidth : CGFloat = 300
        let textFieldHeight : CGFloat = 120
        
        textLabel = SKLabelNode()
        textLabel.zPosition = 0
        textLabel.fontName = "Noteworthy-Light"
        textLabel.fontSize = 19
        textLabel.fontColor = UIColor.black
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 6
        textLabel.preferredMaxLayoutWidth = 480
        textLabel.verticalAlignmentMode = .center
        textLabel.text = "You are a flapping bird in the last semester of college when corona suddenly breaks out! Courses have become remote over Zoom. You must now finish all of your final exams, whose questions will be shown above, to earn your Zoom credits. Will you get enough credits to graduate before the effects of corona catch up to you?\n                                  CLICK TO PLAY!"
        
        textBackgroundSprite = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "intro.png")))
        textBackgroundSprite.zPosition = -4
        textLabel.addChild(textBackgroundSprite)
        textLabel.position = CGPoint(x: frame.midX - 160, y: frame.midY - 120)
        addChild(textLabel)
    }
    
    private func createGameOverLabel() {
        let textFieldWidth : CGFloat = 300
        let textFieldHeight : CGFloat = 120
        
        textLabel = SKLabelNode()
        textLabel.zPosition = 0
        textLabel.fontName = "Noteworthy-Light"
        textLabel.fontSize = 19
        textLabel.fontColor = UIColor.black
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 6
        textLabel.preferredMaxLayoutWidth = 480
        textLabel.verticalAlignmentMode = .center
        textLabel.position = CGPoint(x: frame.midX - 150, y: frame.midY - 170)
        if currentTitle == "Undergrad Senior" {
            textLabel.text = "Unfortunately, you were unable to graduate. Gotta brush up on those math skills. Better luck next time!\nFor more information about coronavirus, visit\n\"https://www.cdc.gov/coronavirus/2019-ncov/index.html\"\nClick to play again!"
        }
        else {
            textLabel.text = "Congratulations! You have graduated with a " + currentTitle + " before the effects of coronavirus inevitably caught up to you. Keep on persevering!\nFor more information about coronavirus, visit\n\"https://www.cdc.gov/coronavirus/2019-ncov/index.html\"\nClick to play again!"
        }
        textLabel.addChild(textBackgroundSprite)
        addChild(textLabel)
    }
    
    private func showLevelGuide() {
        scroll = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "scrollfull.png")))
        scroll.zPosition = 0
        scroll.position = CGPoint(x: frame.midX + CGFloat(frame.width / 2 - scroll.size.width / 2), y: frame.midY - 50)
        addChild(scroll)
    }
    
    private func hideLevelGuide() {
        let distanceToMove = CGFloat(scroll.size.width + 10)
        let moveScroll = SKAction.moveBy(x: distanceToMove, y:0.0, duration:TimeInterval(1.5))
        let destroyScroll = SKAction.removeFromParent()
        let moveScrollThenRemove = SKAction.sequence([moveScroll, destroyScroll])
        scroll.run(moveScrollThenRemove)
    }
    
    private func setupScoreTextField() {
        scoreUI = SKNode()
        let scorebg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "score.png")))
        scorebg.zPosition = -4
        scorebg.position = CGPoint(x: 0, y: 0)
        scoreUI.addChild(scorebg)
        
        statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statusLabel.zPosition = 0
        statusLabel.position = CGPoint(x: 0, y: -75)
        statusLabel.fontSize = 24
        scoreUI.addChild(statusLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.zPosition = 0
        scoreLabel.position = CGPoint(x: 0, y: 12)
        scoreLabel.fontSize = 24
        scoreUI.addChild(scoreLabel)
        
        let scoreX = frame.midX - CGFloat(frame.width / 2) + CGFloat(scorebg.size.width / 2)
        let scoreY = frame.midY + CGFloat(frame.height / 2) - CGFloat(scorebg.size.height / 2)
        
        scoreUI.position = CGPoint(x: scoreX, y: scoreY)
        addChild(scoreUI)
    }
    
    private func updateScoreTextField() {
        scoreLabel.text = String(zoomScore)
        statusLabel.text = currentTitle
    }
    
    private func setBackground() {
        // Background texture
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg.png")))
        bg.setScale(6)
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        // Virus texture
        let v1 = SKTexture(image: #imageLiteral(resourceName: "virus_a.png"))
        let v2 = SKTexture(image: #imageLiteral(resourceName: "virus_b.png"))
        let v3 = SKTexture(image: #imageLiteral(resourceName: "virus_c.png"))
        
        virus = SKSpriteNode(texture: v1)
        virus.setScale(1)
        virus.zPosition = -5
        virus.position = CGPoint(x: frame.midX - 900, y: frame.midY)
        let virusAnimate = SKAction.animate(with: [v1, v2, v3], timePerFrame: 0.3)
        virusAnimateForever = SKAction.repeatForever(virusAnimate)
        virus.run(virusAnimateForever)
        addChild(virus)
    }
    
    private func createPlayer() {
        birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird1new.png"))
        birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird2new.png"))
        
        player = SKSpriteNode(texture: birdTexture1)
        player.setScale(1.6)
        player.zPosition = -8
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
        if clicksEnabled {
            if !firstTouch {
                firstTouch = true
                game.speed = 1
                resetScene()
            }
            if game.speed > 0 {
                player.physicsBody?.affectedByGravity = true
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 11))
                if flapSound.isPlaying {
                    flapSound.stop()
                }
                flapSound.currentTime = 0
                flapSound.play()     
            }
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        if game.speed > 0 {
            if (contact.bodyA.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot || (contact.bodyB.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot {
                // Handle a collision with the successSlot (increment score)
                zoomScore += 1
                
                /* Update the currentTitle based on zoomScore */
                if zoomScore < Levels.bsd.scoreRequired {
                    currentTitle = Levels.ugs.name
                }
                else if zoomScore < Levels.msd.scoreRequired {
                    currentTitle = Levels.bsd.name
                }
                else if zoomScore < Levels.phd.scoreRequired {
                    currentTitle = Levels.msd.name
                } 
                else if zoomScore < Levels.mdphd.scoreRequired {
                    currentTitle = Levels.phd.name
                }
                else if zoomScore < Levels.zl.scoreRequired {
                    currentTitle = Levels.mdphd.name
                }
                else {
                    currentTitle = Levels.zl.name
                }
                updateScoreTextField()
                problems.remove(at: 0)
                updateProblemInCenterTextField()
            }
            else if (contact.bodyA.categoryBitMask & Bitmask.failSlot) == Bitmask.failSlot || (contact.bodyB.categoryBitMask & Bitmask.failSlot) == Bitmask.failSlot || (contact.bodyA.categoryBitMask & Bitmask.pipe) == Bitmask.pipe || (contact.bodyB.categoryBitMask & Bitmask.pipe) == Bitmask.pipe {
                // Stop gameplay
                gameOverSound.play()
                clicksEnabled = false
                game.speed = 0
                removeAllActions()
                gameOverActions()
                firstTouch = false
            }
        }
    }
    
    private func resetScene() {
        zoomScore = 0
        currentTitle = Levels.ugs.name
        player.position = CGPoint(x: frame.midX - 190, y: frame.midY)
        
        setupPipeMovement()
        beginPipeSpawnRepeat()
        
        problems.removeAll()
        game.removeAllChildren()
        
        hideLevelGuide()
        setupProblemInCenterTextField()
        gameOverSprite?.removeFromParent()
        textLabel?.removeFromParent()
        updateScoreTextField()
        problemLabel.text = "Exam Qs"
        
        virus.removeAllActions()
        virus.run(virusAnimateForever)
        virus.position = CGPoint(x: frame.midX - 900, y: frame.midY)
        
        backgroundSong?.stop()
        backgroundSong?.play()
    }
    
    private func gameOverActions() {
        var titleIcon : SKTexture!
        switch(currentTitle) {
            case Levels.bsd.name:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "bsd.png"))
            case Levels.msd.name:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "msd.png"))
            case Levels.phd.name:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "phd.png"))
            case Levels.mdphd.name:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "mdphd.png"))
            case Levels.zl.name:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "zoomlord.png"))
                currentTitle = "Zoom Lord Degree"
            default:
                titleIcon = SKTexture(image: #imageLiteral(resourceName: "ugs.png"))
        }
        gameOverSprite = SKSpriteNode(texture: titleIcon)
        gameOverSprite.setScale(2.5)
        gameOverSprite.zPosition = 10
        gameOverSprite.position = CGPoint(x: frame.midX - 150, y: frame.midY)
        addChild(gameOverSprite)
        
        let distanceToMove = CGFloat(1000)
        let moveVirus = SKAction.moveBy(x: distanceToMove, y:0.0, duration:TimeInterval(2))
        let stopAnimate = SKAction.run(stopVirusAnimation)
        let moveVirusThenStopAnimate = SKAction.sequence([moveVirus, stopAnimate])
        virus.run(moveVirusThenStopAnimate)
        
        showLevelGuide()
        showCorrectAnswer()
        createGameOverLabel()
    }
    
    private func stopVirusAnimation() {
        virus.removeAllActions()
        virus.texture = SKTexture(image: #imageLiteral(resourceName: "virus_a.png"))
        clicksEnabled = true
    }
}




