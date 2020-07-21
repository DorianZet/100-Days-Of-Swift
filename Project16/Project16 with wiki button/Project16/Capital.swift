//
//  Capital.swift
//  Project16
//
//  Created by MacBook on 22/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    // Annotations have three "official" properties - 'title', 'subtitle' and 'coordinate'.
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var subtitle: String?
    var webpage: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, subtitle: String?, webpage: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.subtitle = subtitle
        self.webpage = webpage
    }
}
