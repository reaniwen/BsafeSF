//
//  DataModel.swift
//  BsafeSF
//
//  Created by Rean on 1/14/16.
//  Copyright © 2016 Rean. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON



class DataModel {
    private var _jsonData: JSON
    
    private let concurrentJSONQueue = dispatch_queue_create("com.close5.BsafeSF.JSONQueue", DISPATCH_QUEUE_CONCURRENT)
    
    init(jsonData: JSON) {
        _jsonData = jsonData
    }
    
    var jsonData: JSON {
        var dataCopy: JSON!
        dispatch_async(concurrentJSONQueue) { () -> Void in
            dataCopy = self._jsonData
        }
        return dataCopy
    }
    
    func generateMarks() -> [(title:String, coordinate: CLLocationCoordinate2D)]{
        var marksData = [(title:String, coordinate: CLLocationCoordinate2D)]()
        
        for (_, subJson):(String, JSON) in self._jsonData {
            let title = subJson["category"].stringValue
            let location = subJson["location"]
            
            marksData.append((title: title, coordinate: CLLocationCoordinate2DMake(location["latitude"].doubleValue, location["longitude"].doubleValue)))
        }
        return marksData
    }
    
    func testJSON(rawData: AnyObject) {
        self._jsonData = JSON(rawData)
        for (index, subJson):(String, JSON) in self._jsonData {
            print(index, subJson["category"])
        }
    }
    
}