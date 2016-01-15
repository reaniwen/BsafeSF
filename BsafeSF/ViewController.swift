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

class ViewController: UIViewController {
    
    @IBOutlet weak var baseMapView: MKMapView!
    
    let client = SODAClient(domain: "data.sfgov.org", token: "j9av0DoPIMeXOVaSrmD3jFeEf")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getData()
        
        setMapRegion(initLocation)
        
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
    
    func getData() {
        let crimeLocation = client.queryDataset("tmnf-yvry")
        
        let targetDate = NSDate(timeIntervalSinceNow: -2_592_000.0)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let timeStr = "date >= '\(formatter.stringFromDate(targetDate))T00:00:00'"
        
        
        crimeLocation.filter(timeStr).get { (res) -> Void in
            switch res {
            case .Dataset(let data): self.parseData(data)//print(data.count)
            case .Error(let error): print("\(error)")
            }
        }
    }
    
    func testJSON(rawData: AnyObject) {
        let json = JSON(rawData)
        for (index, subJson):(String, JSON) in json {
            print(index, subJson["category"])
        }
    }
    
    func parseData(rawData: AnyObject) {
        
        let json = JSON(rawData)
        let datamodel = DataModel(jsonData: json)
        let marksData = datamodel.generateMarks()
        
        // count times in different districts
        var crimeTimes = [String: Int]()
        
        // generate marks on the map
        print(marksData.count)
        for mark in marksData {
            
            // classify district
            let district = mark.district
            if let val = crimeTimes[district] {
                crimeTimes[district] = val + 1
            } else {
                crimeTimes[district] = 1
            }
            let anno = Marks(title: mark.title, district: mark.district, coordinate: mark.coordinate)
//            print(mark.district)
            
            
            self.baseMapView.addAnnotation(anno)
        }
        for (key, val) in crimeTimes {
            print(key, val)
        }
    }
    
}

class Marks: NSObject, MKAnnotation {
    let title: String?
    let district: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, district: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.district = district
        self.coordinate = coordinate
    }
}

