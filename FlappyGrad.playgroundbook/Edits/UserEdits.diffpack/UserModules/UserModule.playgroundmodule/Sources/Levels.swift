public class Level {
    public var name: String
    public var scoreRequired: Int
    init(name: String, scoreRequired: Int) {
        self.name = name
        self.scoreRequired = scoreRequired
    }
}
public struct Levels {
    static let ugs = Level(name: "Undergrad Senior", scoreRequired: 0)
    static let bsd = Level(name: "B.S. Degree", scoreRequired: 1)
    static let msd = Level(name: "M.S. Degree", scoreRequired: 2)
    static let phd = Level(name: "Ph.D.", scoreRequired: 3)
    static let mdphd = Level(name: "M.D. Ph.D", scoreRequired: 4)
    static let zl = Level(name: "* Zoom Lord *", scoreRequired: 5)
}
