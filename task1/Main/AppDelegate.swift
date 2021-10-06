//
//  AppDelegate.swift
//  task1
//
//  Created by Kirill Benderskii on 30.09.2021.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    //MARK: Variables
    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var lastLocation: CLLocation!
    var distance: Double = 0
    
    var mainVC: MainVC?
    var hudVC: HUDVC?
    
    var arrayMPH: [Double]! = []
    var arrayKPH: [Double]! = []
    
    //MARK: Setup app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //setup VCs
        setupVCs()
        mainVC = window?.rootViewController?.children[1] as? MainVC
        hudVC = window?.rootViewController?.children[0] as? HUDVC
        hudVC?.loadViewIfNeeded()
        mainVC?.loadViewIfNeeded()
        //setup location manager
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        return true
    }
    // i dont know why but at first launch it's return error = (domain=kclerrordomain code=1 "(null)") and the only restart simualtor fix it
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    //MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // For test I use simulate location(Location.gpx)
        guard let vc = mainVC else {return}
        
        if currentLocation == nil {
            currentLocation = locations.last
            DispatchQueue.main.async {
                vc.locationValue = self.currentLocation?.coordinate
                vc.fetchTemperature()
            }
        }
        if lastLocation != nil {
            updateSpeedInfo()
            distance += lastLocation.distance(from: locations.last!)
            if vc.isMPH{
                let currentDist = distance * 0.00062137
                mainVC?.distLabel.text = String(format: "Distance: %0.f miles", currentDist)
                hudVC?.distLabel.text = String(format: "Distance: %0.f miles", currentDist)
            }
            else {
                let currentDist = distance / 1000
                mainVC?.distLabel.text = String(format: "Distance: %0.f km", currentDist)
                hudVC?.distLabel.text = String(format: "Distance: %0.f km", currentDist)
            }
        }
        lastLocation = locations.last
    }
    
    //MARK: Speed
    func updateSpeedInfo(){
        let speed = currentLocation?.speed
        guard let mainVC = mainVC else {return}
        guard let hudVC = hudVC else {return}

        let speedToMPH = ((speed ?? 0) * 2.23694)
        let speedToKPH = ((speed ?? 0) * 3.6)
        
        if speedToMPH <= 0 {
            mainVC.gaugeView.value = 0
            hudVC.gaugeView.value = 0
            return
        }
        if mainVC.isMPH{
            updateSpeedLabels(speed: speedToMPH)
            arrayMPH.append(speedToMPH)
        }
        else{
            updateSpeedLabels(speed: speedToKPH)
            arrayKPH.append(speedToKPH)
        }
        avgSpeed()
        
    }
    
    func updateSpeedLabels(speed: Double){
        guard let mainVC = mainVC else {return}
        guard let hudVC = hudVC else {return}
        mainVC.gaugeView.value = speed
        hudVC.gaugeView.value = speed
        
    }

    func avgSpeed(){
        guard let mainVC = mainVC else {return}
        if mainVC.isMPH{
            let speed:[Double] = arrayMPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            mainVC.speedLabel.text = "Average speed:\(speedAvg) mph"
            
        }
        else{
            let speed:[Double] = arrayKPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            mainVC.speedLabel.text = "Average speed:\(speedAvg) km/h"
        }
    }
    
    
    //MARK: ViewControllers
    func setupVCs(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
        let hudVC = storyboard.instantiateViewController(withIdentifier: "HUDVC")
        navController.viewControllers = [hudVC,mainVC]
        //create navigator
        self.window?.rootViewController = navController
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
    }


}

