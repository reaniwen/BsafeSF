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
    
    private var polygonCountDict = [MKPolygon: Int]()
    private var polygonArray = [MKPolygon]()
    private var viewArray = [CGMutablePath]()
    private var polygonViewTupleArray = [(MKPolygon, CGMutablePath)]()
    
    //    private let concurrentJSONQueue = dispatch_queue_create("com.close5.BsafeSF.JSONQueue", DISPATCH_QUEUE_CONCURRENT)
    
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
        let sortedPolygonArray = (self.polygonCountDict as NSDictionary).keysSortedByValueUsingSelector("compare:")
        print(sortedPolygonArray)
        
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
            
            self.polygonCountDict[polygon] = 0
            self.polygonArray.append(polygon)
            self.viewArray.append(self.generatePathRef(polygonEdgesPoint))
            self.polygonViewTupleArray.append((polygon,self.generatePathRef(polygonEdgesPoint)))
        }
    }
    
    func generateAnnos() {
        for (_, subJson):(String, JSON) in self._crimeJsonData {
            let title = subJson["category"].stringValue
            let subTitle = subJson["descript"].stringValue
            let location = CLLocationCoordinate2DMake(subJson["location"]["latitude"].doubleValue, subJson["location"]["longitude"].doubleValue)
            
            let mkMapPoint = MKMapPointForCoordinate(location)
            let point = CGPointMake(CGFloat(mkMapPoint.x), CGFloat(mkMapPoint.y))
            //            let point = CGPointMake(CGFloat(location.longitude), CGFloat(location.latitude))

            for i in 0..<self.polygonViewTupleArray.count {
                let (polygon, pathRef) = self.polygonViewTupleArray[i]
                //                let polygonBezierPath = UIBezierPath(CGPath: pathRef)
                //                if polygonBezierPath.containsPoint(point) {
                if CGPathContainsPoint(pathRef, nil, point, false) {
                    if let count = self.polygonCountDict[polygon] {
                        self.polygonCountDict[polygon] = count + 1
                    }
                }
            }
            
            self._crimeLocationData.append((title:title, subTitle:subTitle, coordinate:location))
        }
        for (key, val) in self.polygonCountDict {
            print(key, val)
        }
    }
    
    func getAnnos() ->[(title: String, subTitle: String, coordinate:CLLocationCoordinate2D)] {
        return self._crimeLocationData
    }
    
    func generatePathRef(points: [CLLocationCoordinate2D]) -> CGMutablePathRef{
        var mpr = CGPathCreateMutable()
        
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
