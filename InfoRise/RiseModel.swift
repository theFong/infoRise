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
    
    var currentTemperature: String!
    
    private var conditionsConstants = ["qpf","snow","uvi","wspd"]
    
    private var firebaseRef: FIRDatabaseReference!
    
    var measurementType = "english"
    
    var currentImageURL = ""
    
    var currentConditionString: String!
    
    var currentCityStr = ""
    
    class WeatherModule {
        init(startDay: NSString, startTime: NSString, weather: NSString, conditions: [NSString]) {
            self.startDay = startDay
            self.startTime = startTime
            self.weather = weather
            self.conditions = conditions
        }
        var startDay: NSString = ""
        var startTime: NSString = ""
        var endDay: NSString = ""
        var endTime: NSString = ""
        var weather: NSString = ""
        var conditions = [NSString]()
        var outfits = [Article]()
    }
    
    struct Article {
        var name: String
        var specialCondition: Bool
        var image: String
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
        objc_sync_enter(weatherModules)
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
                let wh = WeatherModule(startDay: hour["FCTTIME"]["weekday_name_abbrev"].string!,startTime: hour["FCTTIME"]["civil"].string!, weather: weather, conditions: conditionModules)
                weatherandConditionsArr.append(wh)
            }
            self.setModules(weatherandConditionsArr, onCompletion: onCompletion)
            
        })

    }
    
    // merging similar modules
    private func setModules(w: [WeatherModule], onCompletion: () -> Void) {
        var prevMod =  w[0]
        weatherModules.removeAll()
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
                
                prevMod.endDay = hourMod.startDay
                prevMod.endTime = getNextHour(hourMod.startTime as String)

            } else {
                prevMod = hourMod
                prevMod.endDay = prevMod.startDay
                prevMod.endTime = getNextHour(prevMod.startTime as String)
                weatherModules.append(prevMod)
            }
            
        }
        w[0].startDay = ""
        w[0].startTime = "Now"
        addOutfits(onCompletion)
    }
    
    private func getNextHour(hour: String) -> String {
        let meridian = hour.characters.split{$0 == " "}.map(String.init)[1]
        let hourVal = hour.characters.split{$0 == ":"}.map(String.init)[0]
        let nextHour = Int(hourVal) == 12 ? 1 : Int(hourVal)!+1
        var endTimeStr = ""
        if nextHour == 1 {
            endTimeStr = "\(nextHour):00 \(meridian == "AM" ? "PM" : "AM")"
        } else {
            endTimeStr = "\(nextHour):00 \(meridian)"
        }
        return endTimeStr
    }
    
    private func addOutfits(onCompletion: () -> Void){
        firebaseRef.child("rise_data").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            for mod in self.weatherModules {
                // look up condition
                for cond in mod.conditions {
                   let outfits = snapshot.childSnapshotForPath("condition_module").childSnapshotForPath(cond as String).childSnapshotForPath("outfits").children
                    for o in outfits {
                        for article in o.children {
                            let name = snapshot.childSnapshotForPath("clothing").childSnapshotForPath(article.value).children.nextObject()?.key
                            let img = snapshot.childSnapshotForPath("clothing").childSnapshotForPath(article.value).children.nextObject()?.childSnapshotForPath("image").value
                            let a = Article(name: name! as String, specialCondition: true, image: img as! String)
                            mod.outfits.append(a)
                        }
                    }
                }
                // look up weather
                let outfitSnap = snapshot.childSnapshotForPath("weather_module").childSnapshotForPath(mod.weather as String).childSnapshotForPath("outfits")
                for o in outfitSnap.children {
                    for article in o.children{
                        let name = snapshot.childSnapshotForPath("clothing").childSnapshotForPath(article.value).children.nextObject()?.key
                        let img = snapshot.childSnapshotForPath("clothing").childSnapshotForPath(article.value).children.nextObject()?.childSnapshotForPath("image").value
                        let a = Article(name: name! as String, specialCondition: false, image: img as! String)
                        mod.outfits.append(a)
                    }
                }
            }
            objc_sync_exit(self.weatherModules)
            onCompletion()
        })
        
    }

    
    private func updateCurrent(onCompletion: () -> Void) {
        currentTemperature = currentHourlyWeather[0]["temp"][measurementType].string!
        currentImageURL = currentHourlyWeather[0]["icon_url"].string!
        currentConditionString = currentHourlyWeather[0]["condition"].string!
        currentCityStr = weatherApiManager.cityName as String
        updateModules(onCompletion)
    }
    
    private func updateWeatherJson(onCompletion: () -> Void) {
        weatherApiManager.getForcast ({ json in
            if json["error"].string != nil{
                print(json["error"].string)
                onCompletion()
                return
            }
            if (json["hourly_forecast"].array == nil){
                print(json)
                print("error")
                onCompletion()
                return
            }
            self.currentHourlyWeather = json["hourly_forecast"].array!
            self.updateCurrent(onCompletion)
        }, onError: onCompletion)
    }
    
}
