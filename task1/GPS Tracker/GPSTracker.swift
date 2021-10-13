//
//  GPSTracker.swift
//  task1
//
//  Created by Kirill Benderskii on 13.10.2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

protocol GPSTrackerDelegate: AnyObject {
    func updateSpeed(speed: CLLocationSpeed)
    func updateDistance(distance: Double)
    func updateWeather(location: CLLocation)
}

class GPSTracker: NSObject, CLLocationManagerDelegate{
    var locationManager: CLLocationManager!
    var lastLocation: CLLocation!
    var distance: Double = 0
    var speed: CLLocationSpeed = 0
    
    public weak var delegate: GPSTrackerDelegate? = nil
    
    func startTracking(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    // i dont know why but at first launch it's return error = (domain=kclerrordomain code=1 "(null)") and only restart simualtor fix it
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var latValue = locationManager.location?.coordinate.latitude
        var lonValue = locationManager.location?.coordinate.longitude
        
        if lastLocation != nil {
            speed = locationManager.location!.speed
            distance += lastLocation.distance(from: locations.last!)
            delegate?.updateSpeed(speed: speed)
            delegate?.updateDistance(distance: distance)
        }
        lastLocation = locations.last
        delegate?.updateWeather(location: lastLocation)
//        print(lastLocation)
//        
//        print(speed)
//        print(latValue)
//        print(lonValue)
    }
    
    
}
