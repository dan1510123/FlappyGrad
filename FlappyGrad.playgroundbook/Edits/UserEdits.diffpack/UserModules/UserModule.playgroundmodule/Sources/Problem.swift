public class Problem {
    var x : Int
    var op : String
    var y : Int
    init(x: Int, op: String, y: Int) {
        self.x = x
        self.op = op
        self.y = y
    }
    
    public func result() -> Int {
        switch(op) {
            case "*":
                return x * y
            case "+":
                return x + y
            case "-":
                return x - y
            case "%":
                return x % y
            default:
                return 0
        }
    }
    
    public func badResult() -> Int {
        let rand4 = Int.random(in: 1..<7)
        switch(rand4) {
            case 1:
                return result() + x
            case 2:
                return result() - x
            case 3:
                return result() + y
            case 4:
                return result() - y
            case 5:
                return result() + Int.random(in: 1..<11)
            case 6:
                return result() + Int.random(in: -10..<0)
            default:
                return 0
        }
    }
    
    public func toString() -> String {
        return String(x) + " " + op + " " + String(y) + " = "
    }
}
