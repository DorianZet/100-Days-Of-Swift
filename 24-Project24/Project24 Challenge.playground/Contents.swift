import UIKit


// Challenge 1.:
extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.contains(prefix) {
            return self
        } else {
            return prefix + self
        }
    }
}

let str = "pierdzidupa"

str.withPrefix("pierdzi")
str.withPrefix("nie")

// Challenge 2.:
extension String {
    var isNumeric: Bool {
        let numbersArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        if numbersArray.contains(where: self.contains) {
            return true
        } else {
            return false
        }
    }
}

let string1 = "pierdzidupa"
let string2 = "pierdzidupa 123"

string1.isNumeric
string2.isNumeric

// Challenge 3.:
extension String {
    func lines() -> [String] {
        let linebreak = "\n"
        let linesArray = self.components(separatedBy: linebreak)
        
        return linesArray
    }
}

let string3 = "This\nis\na\ntest\nstring"
string3.lines()
string3.lines().count
