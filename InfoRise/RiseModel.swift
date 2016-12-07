//
//  RiseModel.swift
//  InfoRise
//
//  Created by Alec Fong on 12/5/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class RiseModel: NSObject {
    
    static let sharedInstance = RiseModel()
    
    let weatherApiManager = WeatherApiManager.sharedInstance
    
    var currentHourlyWeather = [JSON]()
    
    var weatherModules = [[NSString]]()
    
    var currentTemperature: NSString!
    
    var conditionsConstants = ["qpf","snow","uvi","wspd"]
    
    var firebaseRef: FIRDatabaseReference!
    
    override private init() {
        super.init()
        
        firebaseRef = FIRDatabase.database().reference()
        
        updateWeatherJson()
    }
    
    struct WeatherModule {
        var startTime: NSString
        var endTime: NSString
        var weather: NSString
        var conditions = [NSString]()
    }
    
    func update() {
        updateWeatherJson()
        updateCurrentTemp()
        updateModules()
    }
    
    private func updateModules() {
        var weatherandConditionsArr = [WeatherModule]()
        firebaseRef.child("rise_data").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            for hour in self.currentHourlyWeather {
                // conditions
                var enumerator = snapshot.childSnapshotForPath("condition_module").children
                var conditionModules = [NSString]()
                var count = 0
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let cond = rest.children.allObjects[0]
                    let condThreshold = cond.value[cond.key]
                    if hour[self.conditionsConstants[count]].int > Int(condThreshold as! NSNumber) {
                        conditionModules.append(rest.key as NSString)
                    }
                    count += 1
                }
                
                // weather
                var weather: NSString = ""
                enumerator = snapshot.childSnapshotForPath("weather_module").children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    let high = rest.value!["high_temp"]
                    let low = rest.value!["low_temp"]
                    if hour["feelslike"].int > Int(low as! NSNumber) && hour["feelslike"].int < Int(high as! NSNumber) {
                        weather = rest.key as NSString
                    }
                }
                let wh = WeatherModule(startTime: hour["FCTTIME"]["civil"].string!, endTime: "", weather: weather, conditions: conditionModules)
                weatherandConditionsArr.append(wh)
            }
            self.setModules(weatherandConditionsArr)
            
        })

    }
    
    private func setModules(w: [WeatherModule]) {
        
        var prevWeather: NSString =  w[0].weather
        for hourWeather in w {
            if prevWeather == hourWeather.weather {
                for cond in hourWeather.conditions {
                    
                }
            }
//            weatherModules.append()
        }
    }
    
    private func updateCurrentTemp() {
        currentTemperature = currentHourlyWeather[0]["temp"].string
    }
    
    private func updateWeatherJson() {
        weatherApiManager.getForcast { json in
            self.currentHourlyWeather = json["hourly_forecast"].array!
        }
    }
    
}