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

class MainVC: UIViewController,GaugeViewDelegate, CLLocationManagerDelegate, IsMPHDelegate{
    
    //MARK: Variables
    var isMPH: Bool = false
    //Location
    var locationValue: CLLocationCoordinate2D? = nil
    private var speed: CLLocationSpeed? = nil
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Weather
    private var weather: Weather?
    
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
        startTimer()
        setUpGauge()
        setUpNavBar()

    }
    
    //MARK: Timer
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @IBAction func resetDistAndSpeed(_ sender: Any) {
        appDelegate.distance = 0
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
        destVC.gaugeView.unitOfMeasurementLabel.text = isMPH ? "mph" : "km/h"
        destVC.gaugeView.unitOfMeasurement = isMPH ? "mph" : "km/h"
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showEditMenu(){
        self.performSegue(withIdentifier: "toSettingsVC", sender: self)
    }
    
    //MARK: Delegates
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
        appDelegate.updateSpeedInfo()
    }
}

//MARK: Location and weather
extension MainVC{
    func setUpTemp(){
        guard let weather = weather else {return}
        cityLabel.text = weather.city
        tempLabel.text = String(format: "%0.f°",weather.temperature - 273.15)
    }
    func fetchTemperature(){
        let apiKey = "c27b0060a784a272b8752fe57ca59569"
        
        guard let lon = locationValue?.longitude else {return}
        guard let lat = locationValue?.latitude else {return}

        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(Int(lat))&lon=\(Int(lon))&appid=\(apiKey)"
        
        let request = AF.request(url)
        
        request.responseJSON{ response in
            switch response.result{

            case .success(let value):
                let json = JSON(value)
                let temp = json["main"]["temp"].doubleValue
                let city = json["name"].stringValue
                self.weather = Weather(temperature: temp, city: city)
                self.setUpTemp()
            case .failure(let error):
                print(error)
            }
        }
        
    }
}

//MARK: Gauge
extension MainVC{
    func setUpGauge(){
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        
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

