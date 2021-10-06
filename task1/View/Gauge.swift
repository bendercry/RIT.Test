//
//  Gauge.swift
//  task1
//
//  Created by Kirill Benderskii on 30.09.2021.
//

import Foundation
import UIKit

public protocol GaugeViewDelegate : AnyObject{
    func ringStokeColor(gaugeView: GaugeView, value: Double)->UIColor
}

open class GaugeView: UIView{
    
    public static let defaultFontName = "HelveticaNeue-CondensedBold"
    public static let defaultMinMaxValueFont = "HelveticaNeue"
    
    public var value: Double = 0{
        didSet{
            value = max(min(value, maxValue), minValue)
            valueLabel.text = String(format: "%.0f", value)
            strokeGauge()

        }
    }
    
    public var minValue = 0.0
    public var maxValue = 120.0
    public var limitValue = 60.0
    
    @IBInspectable public var ringBackgroundColor: UIColor = UIColor(white: 0.9, alpha: 1)
    @IBInspectable public var ringThickness: Double = 15
    @IBInspectable public var valueFont: UIFont = UIFont(name: defaultFontName, size: 140) ?? UIFont.systemFont(ofSize: 140)
    @IBInspectable public var valueTextColor: UIColor = UIColor(white: 0.1, alpha: 1)

    @IBInspectable public var unitOfMeasurement: String = ""
    @IBInspectable public var unitOfMeasurementFont: UIFont = UIFont(name: defaultFontName, size: 16) ?? UIFont.systemFont(ofSize: 16)
    @IBInspectable public var unitOfMeasurementTextColor: UIColor = UIColor(white: 0.3, alpha: 1)
    @IBInspectable public var showUnitOfMeasurement: Bool = true
    @IBInspectable public var showRing:Bool = false
    @IBInspectable public var divisionsPadding: Double = 12
    @IBInspectable public var divisionsRadius: Double = 1.25
    
    public weak var delegate: GaugeViewDelegate? = nil
    
    var startAngle: Double = .pi * 3/4
    var endAngle: Double = .pi/4 + .pi * 2
    
    lazy var progressLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.contentsScale = UIScreen.main.scale
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = CAShapeLayerLineCap.butt
            layer.lineJoin = CAShapeLayerLineJoin.bevel
            layer.strokeEnd = 0
            return layer
    }()
    
    lazy var valueLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            return label
    }()
    lazy var unitOfMeasurementLabel: UILabel = {
           let label = UILabel()
           label.backgroundColor = UIColor.clear
           label.textAlignment = .center
           label.adjustsFontSizeToFitWidth = true
           return label
       }()
    
    override open func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let ringRadius = Double(min(bounds.width, bounds.height))/2 - ringThickness/2
        
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.addArc(center: center,
                        radius: CGFloat(ringRadius),
                        startAngle: 0,
                        endAngle: .pi * 2,
                        clockwise: false)
        context?.setStrokeColor(ringBackgroundColor.withAlphaComponent(0.3).cgColor)
        context?.strokePath()
        
        context?.setLineWidth(CGFloat(ringThickness))
        context?.beginPath()
        context?.addArc(center: center,
                        radius: CGFloat(ringRadius),
                        startAngle: CGFloat(startAngle),
                        endAngle: CGFloat(endAngle),
                        clockwise: false)
        context?.setStrokeColor(ringBackgroundColor.cgColor)
        context?.strokePath()
        
        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }
        progressLayer.frame = CGRect(x: center.x - CGFloat(ringRadius) - CGFloat(ringThickness)/2,
                                     y: center.y - CGFloat(ringRadius) - CGFloat(ringThickness)/2,
                                     width: (CGFloat(ringRadius) + CGFloat(ringThickness)/2) * 2,
                                     height: (CGFloat(ringRadius) + CGFloat(ringThickness)/2) * 2)
        progressLayer.bounds = progressLayer.frame
        let smoothedPath = UIBezierPath(arcCenter: progressLayer.position,
                                        radius: CGFloat(ringRadius),
                                        startAngle: CGFloat(startAngle),
                                        endAngle: CGFloat(endAngle),
                                        clockwise: true)
        progressLayer.path = smoothedPath.cgPath
        progressLayer.lineWidth = CGFloat(ringThickness)

        // Value Label
        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }
        valueLabel.text = String(format: "%.0f", value)
        valueLabel.font = valueFont
        valueLabel.minimumScaleFactor = 10/valueFont.pointSize
        valueLabel.textColor = valueTextColor
        let insetX = ringThickness + divisionsPadding * 2 + divisionsRadius
        valueLabel.frame = progressLayer.frame.insetBy(dx: CGFloat(insetX), dy: CGFloat(insetX))
        valueLabel.frame = valueLabel.frame.offsetBy(dx: 0, dy: showUnitOfMeasurement ? CGFloat(-divisionsPadding/2) : 0)
        
        // Unit Of Measurement Label
        if unitOfMeasurementLabel.superview == nil {
            addSubview(unitOfMeasurementLabel)
        }
        unitOfMeasurementLabel.text = unitOfMeasurement
        unitOfMeasurementLabel.font = unitOfMeasurementFont
        unitOfMeasurementLabel.minimumScaleFactor = 10/unitOfMeasurementFont.pointSize
        unitOfMeasurementLabel.textColor = unitOfMeasurementTextColor
        unitOfMeasurementLabel.isHidden = !showUnitOfMeasurement
        unitOfMeasurementLabel.frame = CGRect(x: valueLabel.frame.origin.x,
                                              y: valueLabel.frame.maxY - 10,
                                              width: valueLabel.frame.width,
                                              height: 20)
        
    }
    
    public func strokeGauge() {
        
        // Set progress for ring layer
        let progress = maxValue != 0 ? (value - minValue)/(maxValue - minValue) : 0
        progressLayer.strokeEnd = CGFloat(progress)

        // Set ring stroke color
        var ringColor = UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        if let delegate = delegate {
            ringColor = delegate.ringStokeColor(gaugeView: self, value: value)
        }
        progressLayer.strokeColor = ringColor.cgColor
    }
}
