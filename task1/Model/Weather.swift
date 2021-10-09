//
//  Weather.swift
//  task1
//
//  Created by Kirill Benderskii on 01.10.2021.
//

import Foundation

struct Weather{
    var temperature : Double = 0.0
    var city : String = ""
    
    init(temperature: Double, city: String){
        self.temperature = temperature
        self.city = city
    }
}
