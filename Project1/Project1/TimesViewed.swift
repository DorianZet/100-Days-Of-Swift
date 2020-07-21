//
//  TimesViewed.swift
//  Project1
//
//  Created by MacBook on 11/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class TimesViewed: NSObject, Codable {
    var timesPicture1: Int
    var timesPicture2: Int
    var timesPicture3: Int
    var timesPicture4: Int
    var timesPicture5: Int
    var timesPicture6: Int
    var timesPicture7: Int
    var timesPicture8: Int
    var timesPicture9: Int
    var timesPicture10: Int


    
    init (timesPicture1: Int, timesPicture2: Int, timesPicture3: Int, timesPicture4: Int, timesPicture5: Int, timesPicture6: Int, timesPicture7: Int, timesPicture8: Int, timesPicture9: Int, timesPicture10: Int) {
        self.timesPicture1 = timesPicture1
        self.timesPicture2 = timesPicture2
        self.timesPicture3 = timesPicture3
        self.timesPicture4 = timesPicture4
        self.timesPicture5 = timesPicture5
        self.timesPicture6 = timesPicture6
        self.timesPicture7 = timesPicture7
        self.timesPicture8 = timesPicture8
        self.timesPicture9 = timesPicture9
        self.timesPicture10 = timesPicture10
    }
}
