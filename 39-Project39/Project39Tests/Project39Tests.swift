//
//  Project39Tests.swift
//  Project39Tests
//
//  Created by Mateusz Zacharski on 30/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import XCTest
@testable import Project39

class Project39Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllWordsLoaded() { // the method starts with "test" all in lowercase, it accepts no parameters and returns nothing. When you create a method like this inside an XCTestCase subclass, XCode automatically considers it to be a test that should run on your code.
        let playData = PlayData()
        XCTAssertEqual(playData.allWords.count, 18440, "allWords was not 18440") // this checks that its first parameter (playData.allWords.count) equals its second parameter (0). If it doesn't the test will fail and print the message given in parameter three ("allWords must be 0").
    }
    
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "foe"), 8, "\"foe\" does not appear 8 times.")
        XCTAssertEqual(playData.wordCounts.count(for: "herein"), 9, "\"herein\" does not appear 9 times.")
        XCTAssertEqual(playData.wordCounts.count(for: "mean"), 134, "\"mean\" does not appear 134 times.")
    }
    
    // Running a performance test. The closure is run 10 times:
    func testWordsLoadQuickly() {
        measure {
            _ = PlayData() // assigning a new 'PlayData' object to _ will load the file, split it up by lines and count the unique words.
        }
    }
    
    func testApplyUserFilterQuickly() {
        measure {
            _ = PlayData().applyUserFilter("herein")
        }
    }
    
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495, "\"100\" does not appear 495 times.")
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55, "\"1000\" does not appear 55 times.")
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1, "\"10000\" does not appear 1 time.")
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56, "\"test\" does not appear 56 times.")
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7, "\"swift\" does not appear 7 times.")
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0, "\"objective-c\" does not appear 0 times.")
        
    }

}
