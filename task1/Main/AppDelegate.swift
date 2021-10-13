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
        
    var orientationLock = UIInterfaceOrientationMask.all
    var mainVC: MainVC?
    var hudVC: HUDVC?
    
    var db: DBHelper? = nil
    
    //MARK: Setup app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //setup VCs
        setupVCs()
        mainVC = window?.rootViewController?.children[1] as? MainVC
        hudVC = window?.rootViewController?.children[0] as? HUDVC
        hudVC?.loadViewIfNeeded()
        mainVC?.loadViewIfNeeded()
        
        //setup db
        db = DBHelper()
        guard let db = db else {return false}
        let dbReader = db.read()
        
        if dbReader.count != 0 {
            mainVC?.isMPH = dbReader[0].isMPH
            mainVC?.gaugeView.unitOfMeasurement = (dbReader[0].isMPH ? "mph" : "km/h")
            //distance = dbReader[0].dist
            //updateDistLabel(isMPH: dbReader[0].isMPH)
        }
        
       
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        guard let mainVC = mainVC else { return }
       // db?.insert(dist: distance, time: Int(NSDate().timeIntervalSince1970), isMPH: mainVC.isMPH)
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
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

