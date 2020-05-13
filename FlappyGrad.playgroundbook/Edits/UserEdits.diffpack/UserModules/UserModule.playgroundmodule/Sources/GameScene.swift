// Code inside modules can be shared between pages and other source files.
import SpriteKit

public class GameScene : SKScene, SKPhysicsContactDelegate {
    /* Global fields */
    var player : SKSpriteNode!
    var pipes = [SKSpriteNode]()
    var gameStarted : Bool = false
    var textField : UITextField = UITextField()
    
    public override func didMove(to view: SKView) {
        // Set up the Physics of the Scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0
        // Contact (collisions) will be handled by this class
        physicsWorld.contactDelegate = self 
        
        setupTextField() // Set up UITextField
        setBackground() // Set background
        createPlayer() // Create player
    }
    
    private func setupTextField() {
        let textFieldWidth : CGFloat = 500
        let textFieldHeight : CGFloat = 150
        textField.frame = CGRect(x: frame.midX - 100, y: frame.midY - CGFloat(textFieldHeight / 2) - 203, width: textFieldWidth, height: textFieldHeight)
        textField.text = "Hello"
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.red
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
        let birdTexture1 = SKTexture(image: #imageLiteral(resourceName: "bird.png"))
        let birdTexture2 = SKTexture(image: #imageLiteral(resourceName: "bird2.png"))
        
        player = SKSpriteNode(texture: birdTexture1)
        player.setScale(2)
        player.zPosition = 0
        player.position = CGPoint(x: frame.midX - 200, y: frame.midY)
        addChild(player)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2.0)
        player.physicsBody?.affectedByGravity = false;
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
        gameStarted = true
        player.physicsBody?.affectedByGravity = true
        for _ in touches { // do we need all touches?
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }
    }
    
    public func getTextField () -> UITextField {
        return textField;
    }
}




