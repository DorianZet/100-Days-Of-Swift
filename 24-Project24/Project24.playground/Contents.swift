import UIKit

let name = "Taylor"

for letter in name {
    print("Give me a \(letter)")
}
//How to get the 3rd letter of the 'name' String:
let letter = name[name.index(name.startIndex, offsetBy: 3)]

// Same thing as above, though here, because it's an extension, it applies to all strings:
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

// Now this method should work, but we have to remember that there is an inner and outer loop here - outer loop: go through letters, inner loop: counting through characters every time we read through a letter. That has a potential of being really slow.
let letter2 = name[3]

// Analogically to that, it's always better to use 'someString.isEmpty' rather than 'someString.count == 0', if we're looking for an empty string.


let password = "12345"
password.hasPrefix("123")
password.hasSuffix("456")


// dropFirst() and dropLast() removes the certain amount of letters from a start of an end of a string. As a result, they return a SUBSTRING - a part of a string, not a whole string.
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

//This will print EACH WORD in the string capitalized:
let weather = "it's going to rain"
print(weather.capitalized)

// Same result as above:
extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return ""}
        return firstLetter.uppercased() + self.dropFirst()
    }
}

let input = "Swift is like Objective-C without the C"
input.contains("Swift") // This will return true, because the above string contains word "Swift".

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift") // this will return true, because "Swift" IS somewhere in the array.

// Method 1. of how to check if any string from an array are contained in an input string:
extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) { // 'self' here is a 'String'
                return true
            }
        }
        return false
    }
}
input.containsAny(of: languages)

// Method 2., which is way better:
languages.contains(where: input.contains) // contains(where:) will call its closure once for every element in the "languages" array and if it finds one it returns true, at which point it stops. For our closure, we're passing 'input.contains'. This means Swift will call 'input.contains("Python") and get back 'false'. Then the same method, but for "Ruby" - and get back false again. Finally, it will call 'input.contains("Swift") and return true, then STOP there.
    



// NSAttributedString explanation:

let string = "This is a test string"

let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

// putting the string and attributes together:
let attributedString = NSAttributedString(string: string, attributes: attributes)

// OR we can create a mutable attributed string and then add attributes to it:
let attributedString1 = NSMutableAttributedString(string: string)
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString1.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))
// The offsets 'location' and 'length' match exactly the locations and lengths of the words in 'string'.


