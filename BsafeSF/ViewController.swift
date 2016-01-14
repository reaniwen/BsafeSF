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

private let initLocation = CLLocation(latitude: 37.7545565620279, longitude: -122.419711251166)

class ViewController: UIViewController {
    
    @IBOutlet weak var baseMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setMapRegion(initLocation)
        
//        Alamofire.request(.GET, "https://api.500px.com/v1/photos").responseJSON() {
//            (_, _, data, _) in
//            println(data)
//        }
        Alamofire.request(.GET, "https://data.sfgov.org/resource/ritf-b9ki.json").responseJSON { (data) -> Void in
            print(data)
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

}

