//
//  Weather.swift
//  task1
//
//  Created by Kirill Benderskii on 01.10.2021.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

struct Weather{
    //Variables
    var temperature : Double = 0.0
    var city : String = ""
    // Initializer
    init(city: String, temperature: Double){
        self.city = city
        self.temperature = temperature
    }
    //Fetching current forecast using coordinates
    mutating func fetchInfo(locationValue: CLLocationCoordinate2D, completion: @escaping (String,Double) -> () ){
        let lon = locationValue.longitude
        let lat = locationValue.latitude
        let apiKey = "c27b0060a784a272b8752fe57ca59569"

        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(Int(lat))&lon=\(Int(lon))&appid=\(apiKey)"
        
        let request = AF.request(url)
        var temp:Double = 0
        var city:String = ""
        request.responseJSON{ response in
            switch response.result{
                
            case .success(let value):
                let json = JSON(value)
                temp = json["main"]["temp"].doubleValue
                city = json["name"].stringValue
                completion(city,temp)
            case .failure(let error):
                print(error)
            }
            
        }
       
    }

}
