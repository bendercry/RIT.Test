//
//  HUDVC.swift
//  task1
//
//  Created by Kirill Benderskii on 05.10.2021.
//

import UIKit

class HUDVC: UIViewController, GaugeViewDelegate {
    
    
    //MARK: Variables
    var isMPH:Bool = false
    var curDist = "Distance: 0 km"
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: VC lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGauge()
        distView.transform = CGAffineTransform(rotationAngle: -90 * .pi/180)
        distLabel.transform = CGAffineTransform(scaleX: -1,y: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    //MARK: IBA
    @IBAction func backToMainVC(_ sender: Any) {
        let destVC: MainVC = appDelegate.mainVC!
        navigationController?.pushViewController(destVC, animated: true)
    }
    @IBOutlet weak var distView: UIView!
    @IBOutlet weak var gaugeView: GaugeView!
    @IBOutlet weak var distLabel: UILabel!
    
    //MARK: Gauge
    func setUpGauge(){
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeView.backgroundColor = UIColor.white
        
        gaugeView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gaugeView.valueLabel.transform = CGAffineTransform(scaleX: -1,y: 1)
        gaugeView.valueTextColor = UIColor(white: 0.1, alpha: 1)
        
        gaugeView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugeView.unitOfMeasurement = (isMPH ? "mph" : "km/h")
        gaugeView.unitOfMeasurementTextColor = UIColor(white: 0.3, alpha: 1)
        gaugeView.unitOfMeasurementLabel.transform = CGAffineTransform(scaleX: -1,y: 1)
        
        gaugeView.delegate = self
        
        gaugeView.minValue = 0
        gaugeView.maxValue = 120
        gaugeView.limitValue = 50
        
        gaugeView.ringBackgroundColor = UIColor(white: 0.9, alpha: 1)
        
        gaugeView.transform = CGAffineTransform(rotationAngle: -90 * .pi/180)
        
        gaugeView.setNeedsDisplay()
        
    }
    
    //MARK: Stoke
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }

}
