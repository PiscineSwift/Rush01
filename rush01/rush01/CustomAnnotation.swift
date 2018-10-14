//
//  CustonAnnotation.swift
//  rush01
//
//  Created by Vitalii Poltavets on 10/14/18.
//  Copyright © 2018 Vitalii Poltavets. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var color: UIColor?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
    
}
