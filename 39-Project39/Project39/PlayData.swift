//
//  PlayData.swift
//  Project39
//
//  Created by Mateusz Zacharski on 30/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
import Foundation

class PlayData {
    var allWords = [String]()
    var wordCounts: NSCountedSet! // NSCountedSet is a set data type, which means that items can only be added once. It keeps track of how many times items you tried to add and remove each item, which means it can handle de-duplicating our words while storing how often they are used (so we don't have to use the dicitionary 'wordCounts = [String: Int]()' anymore).
    private(set) var filteredWords = [String]() // that marks the setter of 'filteredWords' - the code that handles writing - as private, which means ONLY CODE INSIDE THE 'PlayData' CLASS CAN USE IT. The getter - the code that handles reading - is unaffected.
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted) // we split the text in "plays.text" by splitting on anything that ISN'T a letter or number, which can be achieved by inverting the alphanumeric character set.
                allWords = allWords.filter { $0 != ""} // filter all empty lines from the 'allWords' array and remove them.
                
                wordCounts = NSCountedSet(array: allWords) // creates a counted set from all the words, which immediately de-duplicates and counts them all.
//              allWords = wordCounts.allObjects as! [String] // updates the 'allWords' array to be the words from the counted set, this ensuring they are unique.
                let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) } // sort the array so that the most frequent words appear at the top of the table. The closure needs to accept two strins ($0 and $1) and needs to return true if the first string coems before the second. We call 'count(for:)' on each of those strings, so this code will return true ("sort before") if the count for $0 is higher than the code for $1.
                allWords = sorted as! [String]
            }
        }
        applyUserFilter("swift") // show "swift"" words at the launch of the app.
    }
    
    func applyUserFilter (_ input: String) {
        if let userNumber = Int(input) { // Int(input) is a failable initializer (it means it can return nil). In this situation, we'll get nil back if Swift was unable to convert the string ('input') we gave it into an integer. This line means "if the user's input is an integer...").
            
            applyFilter { self.wordCounts.count(for: $0) >= userNumber } // creates an array out of words with a count greater or equal to the number the user entered. $0 here means "every word in 'allWords'.
        } else { // "if the user's input is NOT an integer..." (then of course it has to be a string):
            // we got a string!
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil } // creates an array out of words that contain the user's text as a substring. $0 here means "every word in 'allWords'. We may read it as "give me all words from 'allWords' array that have an 'input' string in their range.
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) { // this function accepts a single parameter, which must be a function that takes a string and returns a boolean. This is exactly what 'filter()' wants, so we can just pass that parameter straight on:
        filteredWords = allWords.filter(filter)
    }
}
