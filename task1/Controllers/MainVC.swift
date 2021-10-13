//
//  ViewController.swift
//  task1
//
//  Created by Kirill Benderskii on 30.09.2021.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON

class MainVC: UIViewController, GaugeViewDelegate, IsMPHDelegate, GPSTrackerDelegate{
    
    //MARK: Variables
    var isMPH: Bool = false
    var tracker = GPSTracker()
    //Location
    var locationValue: CLLocationCoordinate2D? = nil
    private var speed: CLLocationSpeed? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrayMPH: [Double]! = []
    var arrayKPH: [Double]! = []
    
    //Weather
    private var weather = Weather(city: "", temperature: 0)
    
    //Timer
    private var timer: Timer?
    private var counter: Int = 0
    
    private var editImage = UIImage(named: "Ellipsis")!
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    //MARK: App lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tracker.startTracking()
        tracker.delegate = self
        startTimer()
        setUpGauge()
        setUpNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    //MARK: Timer
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @IBAction func resetDistAndSpeed(_ sender: Any) {
        //appDelegate.db?.insert(dist: appDelegate.distance, time: Int(NSDate().timeIntervalSince1970), isMPH: isMPH)
        
        tracker.distance = 0
        
        distLabel.text = "Distance: 0 \(isMPH ? "miles" : "km")"
        speedLabel.text = "Average speed: 0 \(isMPH ? "mph" : "km/h")"
        counter = 0
        timer?.invalidate()
        startTimer()
    }
   
    @objc func updateTimer(){
        counter += 1
        if counter == 10*60{
            resetDistAndSpeed(self)
        }
    }
    
    //MARK: Update UI
    func setUpNavBar(){
        let editBtn = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(showEditMenu))
        editBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.rightBarButtonItem = editBtn
        self.navigationItem.setHidesBackButton(true, animated: true)
        cityLabel.text = "Loading..."
        cityLabel.adjustsFontSizeToFitWidth = true
        cityLabel.minimumScaleFactor = 0.8
        tempLabel.adjustsFontSizeToFitWidth = true
        cityLabel.minimumScaleFactor = 0.8
        
    }
    
    @IBAction func hudBtnClicked(_ sender: Any) {
        //navigate to HUD viewcontroller
        guard let destVC = appDelegate.hudVC else {return}
        destVC.isMPH = isMPH
        destVC.tracker = tracker
        destVC.gaugeView.unitOfMeasurementLabel.text = isMPH ? "mph" : "km/h"
        destVC.gaugeView.unitOfMeasurement = isMPH ? "mph" : "km/h"
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showEditMenu(){
        self.performSegue(withIdentifier: "toSettingsVC", sender: self)
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue .identifier == "toSettingsVC" {
            //Navigate to Settings viewcontroller
            let destVC : SettingsVC = segue.destination as! SettingsVC
            destVC.delegate = self
            destVC.isMPH = isMPH
        }
    }
    
    func returnedIsMPH(isMPH: Bool) {
        self.isMPH = isMPH
        gaugeView.unitOfMeasurementLabel.text = isMPH ? "mph" : "km/h"
    }
}

//MARK: Weather
extension MainVC{
    func updateWeather(location: CLLocation) {
        weather.fetchInfo(locationValue: location.coordinate){ (city,temp) in
            self.cityLabel.text = city
            self.tempLabel.text = String(format: "%0.f°",temp - 273.15)
            self.weather.city = city
            self.weather.temperature = temp
        }
    }
}

//MARK: Speed and distance
extension MainVC{
    func updateSpeed(speed: CLLocationSpeed) {
        let speedToMPH = speed * 2.23694
        let speedToKPH = speed * 3.6
        
        if speed <= 0{
            gaugeView.value = 0
            return
        }
        
        if isMPH{
            gaugeView.value = speedToMPH
            arrayMPH.append(speedToMPH)
        }
        else {
            gaugeView.value = speedToKPH
            arrayKPH.append(speedToKPH)
        }
        avgSpeed()
    }
    func avgSpeed(){
        if isMPH{
            let speed: [Double] = arrayMPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            speedLabel.text = "Average speed:\(speedAvg) mph"
        }
        else{
            let speed: [Double] = arrayKPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            speedLabel.text = "Average speed:\(speedAvg) km/h"
        }
    }
    
    func updateDistance(distance: Double) {
        if isMPH{
            let currentDist = distance * 0.00062137
            distLabel.text = String(format: "Distance: %0.f miles", currentDist)
        }
        else {
            let currentDist = distance / 1000
            distLabel.text = String(format: "Distance: %0.f km", currentDist)
        }
    }
}

//MARK: Gauge
extension MainVC{
    func setUpGauge(){
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/450
        
        gaugeView.backgroundColor = UIColor.white
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        
        gaugeView.unitOfMeasurement = "km/h"
        gaugeView.delegate = self
        gaugeView.minValue = 0
        gaugeView.maxValue = 120
        gaugeView.limitValue = 50
        gaugeView.ringBackgroundColor = UIColor(white: 0.9, alpha: 1)
        gaugeView.valueTextColor = UIColor(white: 0.1, alpha: 1)
        gaugeView.unitOfMeasurementTextColor = UIColor(white: 0.3, alpha: 1)
        gaugeView.setNeedsDisplay()
        
    }
    
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
        
    }
    
}

