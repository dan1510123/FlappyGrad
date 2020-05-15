import SpriteKit
import PlaygroundSupport

public class Main {
    public static func main() {
        let skView = SKView(frame: .zero)
        
        let gameScene = GameScene(size: CGSize(width: 1000, height: 600))
        gameScene.scaleMode = .aspectFit
        skView.presentScene(gameScene)
        
        PlaygroundPage.current.liveView = skView
        // PlaygroundPage.current.wantsFullScreenLiveView = true
    }
}

