import SpriteKit
import PlaygroundSupport

public class Main {
    public static func main() {
        let skView = SKView(frame: .zero)
        
        let gameScene = GameScene(size: CGSize(width: 1100, height: 600))
        gameScene.scaleMode = .aspectFill
        skView.addSubview(gameScene.getScoreTextField())
        skView.addSubview(gameScene.getCenterTextField())
        skView.addSubview(gameScene.getLevelGuideTextField())
        skView.presentScene(gameScene)
        
        PlaygroundPage.current.liveView = skView
    }
}

