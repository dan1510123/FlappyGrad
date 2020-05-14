// Code inside modules can be shared between pages and other source files.
import SpriteKit

public class GameScene : SKScene, SKPhysicsContactDelegate {
    /* Global fields */
    var player : SKSpriteNode!
    
    var pipes = [SKSpriteNode]()
    let pipeSpeed : CGFloat = 1
    
    var zoomScore = 0
    var currentTitle = "Freshman"
    var scoreTextField : UITextView = UITextView()
    var centerTextField : UITextView = UITextView()
    var degreeLevelTextField : UITextView = UITextView()
    var gameIsActive : SKNode!
    
    public override func didMove(to view: SKView) {
        // Set up gameIsActive node
        gameIsActive = SKNode()
        gameIsActive.speed = 0
        self.addChild(gameIsActive)
        
        // Set up the Physics of the Scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0
        // Contact (collisions) will be handled by this class
        physicsWorld.contactDelegate = self 
        
        initDegreeLevelTextField()
        setupInitialTextField() // Set up UITextField
        updateScoreTextField()
        setBackground() // Set background
        createPlayer() // Create player
    }
    
    private func setupInitialTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 150
        centerTextField.frame = CGRect(x: frame.midX - 100, y: frame.midY - CGFloat(textFieldHeight / 2) - 203, width: textFieldWidth, height: textFieldHeight)
        centerTextField.textAlignment = .center
        centerTextField.backgroundColor = UIColor.red
        centerTextField.text = "Hello"
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
        scoreTextField.frame = CGRect(x: frame.midX - 470, y: frame.midY - CGFloat(textFieldHeight / 2) - 203, width: textFieldWidth, height: textFieldHeight)
        scoreTextField.textAlignment = .center
        scoreTextField.backgroundColor = UIColor.blue
        scoreTextField.font = UIFont.boldSystemFont(ofSize: 35)
        scoreTextField.text = String(1000) + " Zoom Credits\n" + currentTitle
    }
    
    private func setBackground() {
        // Background texture
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "bg.png")))
        bg.setScale(5.1)
        bg.zPosition = -10
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
    }
    
    private func createPlayer() {
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird1new.png"))
        let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird2new.png"))
        
        player = SKSpriteNode(texture: birdTexture1)
        player.setScale(2)
        player.zPosition = 0
        player.position = CGPoint(x: frame.midX - 190, y: frame.midY)
        addChild(player)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2.0)
        player.physicsBody?.affectedByGravity = false;
        player.physicsBody?.categoryBitMask = Bitmask.player
        player.physicsBody?.contactTestBitMask = Bitmask.pipe | Bitmask.failSlot | Bitmask.successSlot
        // Set flap animation for player
        let flapAnimation = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.4)
        let flapAction = SKAction.repeatForever(flapAnimation)
        player.run(flapAction)
    }
    
    // Update on each frame
    public override func update(_ currentTime: TimeInterval) {
        // Set rotation of player to be between -1 and 0.5   
        player.zRotation = min( max(-1, player.physicsBody!.velocity.dy * 0.001), 0.5 )
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameIsActive.speed = 1
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        if gameIsActive.speed > 0 {
            if (contact.bodyA.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot || (contact.bodyB.categoryBitMask & Bitmask.successSlot) == Bitmask.successSlot {
                // Handle a collision with the successSlot (increment score)
                zoomScore += 1
                
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




