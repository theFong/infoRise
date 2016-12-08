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
    
    private let weatherApiManager = WeatherApiManager.sharedInstance
    
    private var currentHourlyWeather = [JSON]()
    
    var weatherModules = [WeatherModule]()
    
    var currentTemperature: NSString!
    
    private var conditionsConstants = ["qpf","snow","uvi","wspd"]
    
    private var firebaseRef: FIRDatabaseReference!
    
    var measurementType = "english"
    
    var currentImageURL = ""
    
    var currentConditionString = ""
    
    class WeatherModule {
        init(startDay: NSString, startTime: NSString, weather: NSString, conditions: [NSString]) {
            self.startTime = startTime
            self.weather = weather
            self.conditions = conditions
        }
        var startDay: NSString = ""
        var startTime: NSString = ""
        var endDay = ""
        var endTime: NSString = ""
        var weather: NSString = ""
        var conditions = [NSString]()
        var outfits = [NSString]()
    }
    
    override private init() {
        super.init()
        firebaseRef = FIRDatabase.database().reference()
    }
    
    func updateModel(onCompletion: () -> Void) {
        // waterfalls
        updateWeatherJson(onCompletion)
    }
    
    // converts data into categories like rain, wind, snow, hot, cold etc..
    private func updateModules(onCompletion: () -> Void) {
        var weatherandConditionsArr = [WeatherModule]()
        firebaseRef.child("rise_data").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            for hour in self.currentHourlyWeather {
                // conditions
                var enumerator = snapshot.childSnapshotForPath("condition_module").children
                var conditionModules = [NSString]()
                var count = 0
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    
                    let cond = rest.children.allObjects[0] as? FIRDataSnapshot
                    let condThreshold = (cond?.value)! as! String
                    
                    if self.conditionsConstants[count] == "uvi" {
                        if Float(hour[self.conditionsConstants[count]].string!) > Float(condThreshold) {
                            conditionModules.append(rest.key as NSString)
                        }
                    }
                    else if Float(hour[self.conditionsConstants[count]]["english"].string!) > Float(condThreshold) {
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
                    
                    // range checking
                    if Int(hour["feelslike"]["english"].string!) >= Int(low as! String) && Int(hour["feelslike"]["english"].string!) < Int(high as! String) {
                        weather = rest.key as NSString
                    }
                }
                var wh = WeatherModule(startDay: hour["FCTTIME"]["weekday_name_abbrev"].string!,startTime: hour["FCTTIME"]["civil"].string!, weather: weather, conditions: conditionModules)
                weatherandConditionsArr.append(wh)
            }
            self.setModules(weatherandConditionsArr, onCompletion: onCompletion)
            
        })

    }
    
    // merging similar modules
    private func setModules(w: [WeatherModule], onCompletion: () -> Void) {
        var prevMod =  w[0]
        weatherModules = [WeatherModule]()
        weatherModules.append(prevMod)
        for hourMod in w {
            // adding missed conditions
            if prevMod.weather == hourMod.weather {
                var currentConds = [NSString:NSString]()
                for prevModCond in prevMod.conditions {
                    currentConds[prevModCond] = ""
                }
                for hourModCond in hourMod.conditions {
                    if currentConds[hourModCond] == nil {
                        prevMod.conditions.append(hourModCond)
                    }
                }

                let meridian = (hourMod.startTime as String).characters.split{$0 == " "}.map(String.init)[1]
                let hourVal = (hourMod.startTime as String).characters.split{$0 == ":"}.map(String.init)[0]
                let nextHour = Int(hourVal) == 12 ? 1 : Int(hourVal)!+1
                var endTimeStr = ""
                if nextHour == 1 {
                    endTimeStr = "\(nextHour):00 \(meridian == "AM" ? "PM" : "AM")"
                } else {
                    endTimeStr = "\(nextHour):00 \(meridian)"
                }
                prevMod.endDay = hourMod.startDay as String
                prevMod.endTime = endTimeStr
            } else {
                prevMod = hourMod
                weatherModules.append(prevMod)
            }
            
        }
        addOutfits(onCompletion)
    }
    
    private func addOutfits(onCompletion: () -> Void){
        firebaseRef.child("rise_data").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for mod in self.weatherModules {
                // look up condition
                for cond in mod.conditions {
                   let outfits = snapshot.childSnapshotForPath("condition_module").childSnapshotForPath(cond as String).childSnapshotForPath("outfits").children
                    for o in outfits {
                        for article in o.children {
                            mod.outfits.append(article.value as NSString)
                        }
                    }
                }
                // look up weather
                let outfitSnap = snapshot.childSnapshotForPath("weather_module").childSnapshotForPath(mod.weather as String).childSnapshotForPath("outfits")
                for o in outfitSnap.children {
                    for article in o.children{
                        mod.outfits.append(article.value as NSString)
                    }
                }
            }
            onCompletion()
        })
        
    }

    
    private func updateCurrent(onCompletion: () -> Void) {
        currentTemperature = currentHourlyWeather[0]["temp"][measurementType].string
        currentImageURL = currentHourlyWeather[0]["icon_url"].string!
        currentConditionString = currentHourlyWeather[0]["condition"].string!
        updateModules(onCompletion)
    }
    
    private func updateWeatherJson(onCompletion: () -> Void) {
        weatherApiManager.getForcast ({ json in
            if json["error"].string != nil{
                print(json["error"].string)
                onCompletion()
                return
            }
            if (json["hourly_forecast"] == "null"){
                print(json)
                onCompletion()
                return
            }
            self.currentHourlyWeather = json["hourly_forecast"].array!
            self.updateCurrent(onCompletion)
        }, onError: onCompletion)
    }
    
}