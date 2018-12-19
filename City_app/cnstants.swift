//
//  cnstants.swift
//  City_app
//
//  Created by Georgi Malkhasyan on 12/18/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import Foundation

let apiKey = "5e621154f19be94bc6ba4e93303f1595"

func flickerUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, numberPhotos number: Int) -> String {
    return  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

