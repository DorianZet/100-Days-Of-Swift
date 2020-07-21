import UIKit


// Challenge 1. Extend UIView so that it has a bounceOut(duration:) method that uses
// animation to scale its size down to 0.0001 over a specified number of seconds:
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        })
    }
}
// Testing the challenge 1. code (or just paste into whichever project):
let view = UIView()
view.bounceOut(duration: 5)


// Challenge 2. Extend Int with a times() method that runs a closure as many times as
// the number is high. For example, 5.times { print("Hello!") } will print “Hello” five times:
extension Int {
    func times(_ closure: () -> Void) {
        if self > 1 {
            for _ in 1...self {
            closure()
            }
        } else {
            print("The number of closure repetitions needs to be higher than 1.")
        }
    }
}
// Testing the challenge 2. code:
5.times {
    print("I like sausage")
}



// Challenge 3. Extend Array so that it has a mutating remove(item:) method.
// If the item exists more than once, it should remove only the first instance it finds:
extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        let itemIndex = self.firstIndex(of: item)
        if let firstItemIndex = itemIndex {
            remove(at: firstItemIndex)
        }
    }
}
// Testing the challenge 3. code:
var array = ["apple", "lemon", "orange", "lemon", "orange", "apple"]

array.remove(item: "apple")

for elements in array {
    print(elements)
}

