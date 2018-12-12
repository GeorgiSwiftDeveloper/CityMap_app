//
//  DroppablePin.swift
//  City_app
//
//  Created by Georgi Malkhasyan on 12/12/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import MapKit
import UIKit


class DroppablePin: NSObject, MKAnnotation {
 dynamic   var coordinate: CLLocationCoordinate2D
    var identifire: String
    
    init(coordinate: CLLocationCoordinate2D, identifire: String) {
        self.coordinate = coordinate
        self.identifire = identifire
        super.init()
    }
}
