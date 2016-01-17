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
    var marksHidden = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        baseMapView.delegate = self
        
        setColorDict()
        
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
            let anno = Marks(title: location.title, subTitle: location.subTitle, coordinate: location.coordinate)
            self.baseMapView.addAnnotation(anno)
        }
        
    }
    
    @IBAction func hideShowMarks(sender: AnyObject) {
        let annotations = self.baseMapView.annotations
        if self.marksHidden {
            self.marksHidden = false
            for annotation in annotations {
                self.baseMapView.viewForAnnotation(annotation)?.hidden = false
            }
        } else {
            self.marksHidden = true
            for annotation in annotations {
                self.baseMapView.viewForAnnotation(annotation)?.hidden = true
            }
        }

    }
    
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
            let index = self._districtsRankDict[overlay as! MKPolygon]
            print(index)
            if index < 4 {
                polygonView.fillColor = self.colorsSet[7]
            } else {
                polygonView.fillColor = self.colorsSet[10 - index!]
            }
            
            return polygonView
        }
        return MKOverlayRenderer()
        //        return nil
    }
    
    func setColorDict() {
        let colorsStrArray = ["#ff0000", "#eb3600", "#e54800", "#d86d00", "#d27f00", "#c5a300", "#b9c800", "#a6ff00"]
        for colorStr in colorsStrArray {
            let color = hexStringToUIColor(colorStr)
            self.colorsSet.append(color)
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(0.5)
        )
    }
    
    
    
}

// the class of annotation
class Marks: NSObject, MKAnnotation {
    let title: String?
    let discription: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subTitle: String,coordinate: CLLocationCoordinate2D) {
//        super.init()
        self.title = title
        self.discription = subTitle
        self.coordinate = coordinate
    }
    
    var subtitle: String? {
        return discription
    }
}


