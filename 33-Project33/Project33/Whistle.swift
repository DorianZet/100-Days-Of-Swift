//
//  Whistle.swift
//  Project33
//
//  Created by MacBook on 09/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CloudKit
import UIKit

class Whistle: NSObject, NSCoding {
    
    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
    
    override init() {
        super.init() // This got rid of the "Missing argument for parameter 'coder' in call.
    }
    
    init (recordID: CKRecord.ID, genre: String, comments: String, audio: URL) {
        self.recordID = recordID
        self.genre = genre
        self.comments = comments
        self.audio = audio
    }

    // Reading the thing from disk:
    required init?(coder aDecoder: NSCoder) {
        self.recordID = aDecoder.decodeObject(forKey: "recordID") as? CKRecord.ID
        self.genre = aDecoder.decodeObject(forKey: "genre") as? String ?? ""
        self.comments = aDecoder.decodeObject(forKey: "comments") as? String ?? ""
        self.audio = aDecoder.decodeObject(forKey: "audio") as? URL
    }
    
    // Writing the thing to disk:
    func encode(with aCoder: NSCoder) {
        aCoder.encode(recordID, forKey: "recordID")
        aCoder.encode(genre, forKey: "genre")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(audio, forKey: "audio")
    }
    

    
}
