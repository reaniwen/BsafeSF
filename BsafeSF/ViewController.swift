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
        setMapRegion(initLocation)

        Alamofire.request(.GET, "https://data.sfgov.org/resource/ritf-b9ki.json").responseJSON { response in
            switch response.result {
            case .Success(let value): self.testJSON(value)
            case .Failure(let error): print("\(error)")
            }
        }
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
    
    func testJSON(rawData: AnyObject) {
        let json = JSON(rawData)
        for (index, subJson):(String, JSON) in json {
            print(index, subJson["category"])
        }
//        print("JSON: \(json)")
    }

}

