//
//  DataModel.swift
//  BsafeSF
//
//  Created by Rean on 1/14/16.
//  Copyright © 2016 Rean. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON



class DataModel {
    private var _crimeJsonData: JSON
    private var _geoJsonData: JSON
    
    private let concurrentJSONQueue = dispatch_queue_create("com.close5.BsafeSF.JSONQueue", DISPATCH_QUEUE_CONCURRENT)
    
    init(crimeJsonData: JSON, geoJsonData: JSON) {
        _crimeJsonData = crimeJsonData
        _geoJsonData = geoJsonData
    }
    
//    func generateMarks() -> [(title:String, coordinate: CLLocationCoordinate2D)]{
//        var marksData = [(title:String, coordinate: CLLocationCoordinate2D)]()
    
//        for (_, subJson):(String, JSON) in self._jsonData {
//            let title = subJson["category"].stringValue
////            let date = subJson["date"].stringValue
//            let location = subJson["location"]
//            
//            marksData.append((title, CLLocationCoordinate2DMake(location["latitude"].doubleValue, location["longitude"].doubleValue)))
//        }
//        return marksData
//    }
    
    func generateViewData() ->[([CLLocationCoordinate2D], Int)]{
        var polygonEdgesPoints = [([CLLocationCoordinate2D], Int)]()
        for (_, subGeoJson):(String, JSON) in self._geoJsonData["features"] {
            let rawPointsData = subGeoJson["geometry"]["coordinates"][0][0]
            var polygonEdgesPoint = [CLLocationCoordinate2D]()
            for (_, rawPointData) in rawPointsData {
                polygonEdgesPoint += [CLLocationCoordinate2DMake(rawPointData[1].doubleValue, rawPointData[0].doubleValue)]
            }
            polygonEdgesPoints.append((polygonEdgesPoint, 0))
        }
        
        return polygonEdgesPoints
    }
    
}