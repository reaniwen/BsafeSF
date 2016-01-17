//
//  ViewController.swift
//  BsafeSF
//
//  Created by Rean on 1/13/16.
//  Copyright © 2016 Rean. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

private let initLocation = CLLocation(latitude: 37.774930, longitude: -122.435420)

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var baseMapView: MKMapView!
    
    let client = SODAClient(domain: "data.sfgov.org", token: "j9av0DoPIMeXOVaSrmD3jFeEf")
    
    let colorDict = [UIColor:[Int]]()
    var colorsSet = [UIColor]()
    private var _districtsRankDict = [MKPolygon:Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        baseMapView.delegate = self
        
        setMapRegion(initLocation)
        getCrimeData()
        
        NSLog("getting data concurrently")
//        print("getting data concurrently")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMapRegion(location: CLLocation) {
        let regionRadius: CLLocationDistance = 12000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        self.baseMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getCrimeData() {
        
        // Gernerate SODA query
        let crimeLocation = client.queryDataset("tmnf-yvry")
        
        let targetDate = NSDate(timeIntervalSinceNow: -2_592_000.0)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timeStr = "date >= '\(formatter.stringFromDate(targetDate))T00:00:00'"
        
//        let pdDistrictStr = "pddistrict = 'INGLESIDE'"
        
        crimeLocation.filter(timeStr).get { (res) -> Void in
            switch res {
            case .Dataset(let data): self.getMapData(data)//self.parseData(data)//print(data.count)
            case .Error(let error): print("\(error)")
            }
        }
        
    }
    
    func getMapData(crimeData: AnyObject) {
        if let path = NSBundle.mainBundle().pathForResource("Districts", ofType: "geojson") {
            do{
                let geoRawData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                if let crimeJson = JSON(rawValue: crimeData) {
                    let geoData = try NSJSONSerialization.JSONObjectWithData(geoRawData, options: .MutableContainers)
                    if let geoJson = JSON(rawValue: geoData) {
                        
                        // Generate the data model to parse and calculate the data
                        let dataModel = DataModel(crimeJsonData: crimeJson, geoJsonData: geoJson)
                        
                        // Render the map with district polygons
                        self._districtsRankDict = dataModel.generateViewData()
                        generatePolygons()
                        generateMarks(dataModel)
                        //                        generatePolygons(polygonsBounds)
                        
                        // Render the marks on the map
                        
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func generatePolygons() {
        for (polygon, _) in self._districtsRankDict {
            self.baseMapView.addOverlay(polygon)
        }
    }
    
    func generateMarks(dataModel: DataModel) {
        let marksLocations = dataModel.getAnnos()
        for location in marksLocations {
            let anno = Marks(title: location.title, coordinate: location.coordinate)
            self.baseMapView.addAnnotation(anno)
        }
        
    }
    
    //    func generatePolygons(polygonsBounds: [([CLLocationCoordinate2D], Int)]) {
    //
    //        // render polygon based on the map data in models
    //        for (polygonBoundsData, rank) in polygonsBounds {
    //            var polygonBoundsPoint = polygonBoundsData
    //            let polygon = MKPolygon(coordinates: &polygonBoundsPoint, count: polygonBoundsPoint.count)
    //            self._districtsTimesDict[polygon] = rank
    //            self.baseMapView.addOverlay(polygon)
    //        }
    //
    //    }
    
    
    
    
    //    func parseData(rawData: AnyObject) {
    //
    //        let json = JSON(rawData)
    ////        let datamodel = DataModel(jsonData: json)
    ////        let marksData = datamodel.generateMarks()
    //
    //
    //        // generate annotations on the map
    ////        print(marksData.count)
    ////        for mark in marksData {
    ////            // generate annotation
    ////            let anno = Marks(title: mark.title, coordinate: mark.coordinate)
    ////            }
    //        }
    
    //    }
    
    // mapView delegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.greenColor()
            
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            
            //generate color based on rank
            polygonView.lineWidth = 1
            polygonView.strokeColor = UIColor.blackColor()
            //            let index = self._districtsRankDict[overlay as! MKPolygon]
            //            if index <
            
            return polygonView
        }
        return MKOverlayRenderer()
        //        return nil
    }
    
    //    func setColorDict() {
    //        let colorsStrArray = ["#ff0000", "#eb3600", "#e54800", "#d86d00", "#d27f00", "#c5a300", "#b9c800", "#a6ff00"]
    //        for colorStr in colorsStrArray {
    //            let color = UIColor(rgba: colorStr)
    //            self.colorsSet.append(color)
    //        }
    //    }
    
    
    
}

// the class of annotation
class Marks: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}


