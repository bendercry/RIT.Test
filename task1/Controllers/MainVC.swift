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
    private var isMPH: Bool = false
    private var editImage = UIImage(named: "Ellipsis")!
    
    //Location
    private var locationValue: CLLocationCoordinate2D? = nil
    private var speed: CLLocationSpeed? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var arrayMPH: [Double]! = []
    private var arrayKPH: [Double]! = []
    
    //Weather
    private var weather = Weather(city: "", temperature: 0)
    
    //Timer
    private var timer: Timer?
    private var counter: Int = 0
    
    //Tracker
    internal var tracker = GPSTracker()
    internal var db: DBHelper? = nil
    
    //MARK: @IB var and func
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBAction func resetDistAndSpeed(_ sender: Any) {
        //Reset timer and distance,speed
        
        //db?.insertStat(dist: tracker.distance, time: Int(NSDate().timeIntervalSince1970))
        tracker.distance = 0
        arrayKPH.removeAll()
        arrayMPH.removeAll()
        distLabel.text = "Distance: 0 \(isMPH ? "miles" : "km")"
        speedLabel.text = "Average speed: 0 \(isMPH ? "mph" : "km/h")"
        counter = 0
        timer?.invalidate()
        startTimer()
    }
    
    @IBAction func hudBtnClicked(_ sender: Any) {
        //navigate to HUD viewcontroller
        guard let destVC = appDelegate.hudVC else {return}
        destVC.isMPH = isMPH
        destVC.gaugeView.unitOfMeasurementLabel.text = isMPH ? "mph" : "km/h"
        destVC.gaugeView.unitOfMeasurement = isMPH ? "mph" : "km/h"
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: App lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initDB()
        tracker.startTracking()
        tracker.delegate = self
        startTimer()
        setUpGauge()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    //MARK: Timer
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer(){
        counter += 1
        if counter == 10*60{
            resetDistAndSpeed(self)
        }
    }
    
    //MARK: Update UI
    private func setUpUI(){
        let editBtn = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(showEditMenu))
        editBtn.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.navigationItem.rightBarButtonItem = editBtn
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        cityLabel.text = "Loading..."
        cityLabel.adjustsFontSizeToFitWidth = true
        cityLabel.minimumScaleFactor = 0.8
        tempLabel.adjustsFontSizeToFitWidth = true
        cityLabel.minimumScaleFactor = 0.8
        speedLabel.text = "Average speed: 0 \(isMPH ? "mph" : "km/h")"
    }
    
    @objc private func showEditMenu(){
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
        db?.insertMPH(isMPH: isMPH)
    }
}
//MARK: Init db and implement info
extension MainVC{
    private func initDB(){
        db = DBHelper()
        guard let db = db else {return}
        let configReader = db.readConfig()
        isMPH = configReader
        let statReader = db.readStat()
        if statReader.count != 0 {
            tracker.distance = statReader[0].dist
            updateDistLabel()
        }
    }
    private func updateDistLabel(){
        if isMPH {
            let currentDist = tracker.distance * 0.00062137
            distLabel.text = String(format: "Distance: %0.f miles", currentDist)
            appDelegate.hudVC?.distLabel.text = String(format: "Distance: %0.f miles", currentDist)
        } else {
            let currentDist = tracker.distance / 1000
            distLabel.text = String(format: "Distance: %0.f km", currentDist)
            appDelegate.hudVC?.distLabel.text = String(format: "Distance: %0.f km", currentDist)
        }
    }
}
//MARK: Weather
extension MainVC{
    func updateWeather(location: CLLocation) {
        weather.fetchInfo(locationValue: location.coordinate){ (city,temp) in
            self.weather.city = city
            self.weather.temperature = temp
            self.cityLabel.text = city
            self.tempLabel.text = String(format: "%0.f°",temp - 273.15)
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
            
        } else {
            gaugeView.value = speedToKPH
            arrayKPH.append(speedToKPH)
        }
        appDelegate.hudVC?.gaugeView.value = gaugeView.value
        avgSpeed()
    }
    
    func avgSpeed(){
        if isMPH{
            let speed: [Double] = arrayMPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            speedLabel.text = String(format: "Average speed: %0.f mph",speedAvg)
        
        } else{
            let speed: [Double] = arrayKPH
            let speedAvg = speed.reduce(0,+) / Double(speed.count)
            speedLabel.text = String(format: "Average speed: %0.f km/h",speedAvg)
        }
    }
    
    func updateDistance(distance: Double) {
        if isMPH{
            let currentDist = distance * 0.00062137
            distLabel.text = String(format: "Distance: %0.f miles", currentDist)
        } else {
            let currentDist = distance / 1000
            distLabel.text = String(format: "Distance: %0.f km", currentDist)
        }
        appDelegate.hudVC?.distLabel.text = distLabel.text
    }
}

//MARK: Gauge
extension MainVC{
    private func setUpGauge(){
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/450
        
        gaugeView.backgroundColor = UIColor.white
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        
        gaugeView.unitOfMeasurement = isMPH ? "mph" : "km/h"
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

