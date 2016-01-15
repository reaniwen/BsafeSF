//
//  ViewController.swift
//  BsafeSF
//
//  Created by Rean on 1/13/16.
//  Copyright © 2016 Rean. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

private let initLocation = CLLocation(latitude: 37.7545565620279, longitude: -122.419711251166)

class ViewController: UIViewController {
    
    @IBOutlet weak var baseMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let urlStr = "https://data.sfgov.org/resource/ritf-b9ki.json"
        
        setMapRegion(initLocation)
        
        getData(urlStr)
        
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { () -> Void in
//            self.dataModel.getData(urlStr)
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                print("here")
//                for (index, subJson):(String, JSON) in self.dataModel.jsonData {
//                    print(index, subJson["pddistrict"])
//                }
//            })
//        }

        print("test")
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
    
    func getData(urlStr: String) {
        Alamofire.request(.GET, urlStr).responseJSON { response in
            switch response.result {
            case .Success(let value): self.parseData(value)//self.testJSON(value) // if succeed, generate marks
            case .Failure(let error): print("\(error)")
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
        // generate marks on the map
//        print(marksData)
        for mark in marksData {
            let anno = Marks(title: mark.title, coordinate: mark.coordinate)
            self.baseMapView.addAnnotation(anno)
        }
    }
    
}

class Marks: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

