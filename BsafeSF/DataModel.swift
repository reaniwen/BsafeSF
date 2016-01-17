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
    
    private var _crimeLocationData = [(title: String, subTitle:String, coordinate: CLLocationCoordinate2D)]()
    
    private var _polygonCountDict = [MKPolygon: Int]()
    private var _polygonViewTupleArray = [(MKPolygon, CGMutablePath)]()
    
    init(crimeJsonData: JSON, geoJsonData: JSON) {
        _crimeJsonData = crimeJsonData
        _geoJsonData = geoJsonData
    }
    
    func generateViewData() -> [MKPolygon: Int] {
        // Generate polygons
        self.generatePolygons()
        
        // Generate marks, find it belonging and classify with district
        self.generateAnnos()
        
        // Sort the polygons
        let sortedPolygonArray = (self._polygonCountDict as NSDictionary).keysSortedByValueUsingSelector("compare:")
        
        // return the polygons data with rank
        var polygonDict = [MKPolygon:Int]()
        for i in 0..<sortedPolygonArray.count {
            polygonDict[sortedPolygonArray[i] as! MKPolygon] = i
        }
        return polygonDict
    }
    
    func generatePolygons() {
        for (_, subGeoJson):(String, JSON) in self._geoJsonData["features"] {
            let rawPointsData = subGeoJson["geometry"]["coordinates"][0][0]
            var polygonEdgesPoint = [CLLocationCoordinate2D]()
            for (_, rawPointData) in rawPointsData {
                polygonEdgesPoint += [CLLocationCoordinate2DMake(rawPointData[1].doubleValue, rawPointData[0].doubleValue)]
            }
            let polygon = MKPolygon(coordinates: &polygonEdgesPoint, count: polygonEdgesPoint.count)
            
            self._polygonCountDict[polygon] = 0
            self._polygonViewTupleArray.append((polygon,self.generatePathRef(polygonEdgesPoint)))
        }
    }
    
    func generateAnnos() {
        for (_, subJson):(String, JSON) in self._crimeJsonData {
            let title = subJson["category"].stringValue
            let subTitle = subJson["descript"].stringValue
            let location = CLLocationCoordinate2DMake(subJson["location"]["latitude"].doubleValue, subJson["location"]["longitude"].doubleValue)
            
            let mkMapPoint = MKMapPointForCoordinate(location)
            let point = CGPointMake(CGFloat(mkMapPoint.x), CGFloat(mkMapPoint.y))

            for i in 0..<self._polygonViewTupleArray.count {
                let (polygon, pathRef) = self._polygonViewTupleArray[i]
                if CGPathContainsPoint(pathRef, nil, point, false) {
                    if let count = self._polygonCountDict[polygon] {
                        self._polygonCountDict[polygon] = count + 1
                    }
                }
            }
            
            self._crimeLocationData.append((title:title, subTitle:subTitle, coordinate:location))
        }
    }
    
    func getAnnos() ->[(title: String, subTitle: String, coordinate:CLLocationCoordinate2D)] {
        return self._crimeLocationData
    }
    
    func generatePathRef(points: [CLLocationCoordinate2D]) -> CGMutablePathRef{
        let mpr = CGPathCreateMutable()
        
        let polygonPoints = points
        
        for var p = 0; p < polygonPoints.count; p++ {
            let mp = MKMapPointForCoordinate(polygonPoints[p])
            if p == 0 {
                CGPathMoveToPoint(mpr, nil, CGFloat(mp.x), CGFloat(mp.y))
            } else {
                CGPathAddLineToPoint(mpr, nil, CGFloat(mp.x), CGFloat(mp.y))
            }
        }
        return mpr
    }
}

class Logo {
    let positionData = [[(169,10),(159, 10),(159,-10),(169,-10)], [(172,10),(172,-10)], [(175,0),(175,-10),(-175,-10),(-175,0),(175.01,0)], [(-164,0),(-174,0),(-174,-5),(-164,-5),(-164,-10),(-174,-10)], [(-162.99,-5),(-153,-5),(-153,0),(-163,0),(-163,-10),(-153,-10)], [(-140,10),(-150,10),(-150,0),(-140,0),(-140,-10),(-150,-10)]]
    let logo = ["c","l","o","s","e","5"]
    var logoData = [String: [CLLocationCoordinate2D]]()
    init() {
        for i in 0..<positionData.count {
            var coordinates = [CLLocationCoordinate2D]()
            for (x,y) in positionData[i] {
                coordinates.append(CLLocationCoordinate2DMake(Double(y), Double(x)))
            }
            logoData[logo[i]] = coordinates
        }
    }
}
