//
//  WeatherApiManager.swift
//  InfoRise
//
//  Created by Alec Fong on 12/4/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class WeatherApiManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = WeatherApiManager()
    
    private let baseUrl = "http://api.wunderground.com/api/"
    
    private var ref: FIRDatabaseReference!
    
    private let locationManager = CLLocationManager()
    
    var cityName: NSString! = nil
    var stateName: NSString! = nil
    private var apiKey: NSString!
    private var locationUpdatedCompletionHandler: (String) -> Void = {(location) in }
    
    override private init() {
        super.init()
        ref = FIRDatabase.database().reference()
        
        updateApiKey()
        
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // City
            print(placeMark.addressDictionary)
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                self.cityName = city.stringByReplacingOccurrencesOfString(" ", withString: "_")
            }
            if let state = placeMark.addressDictionary!["State"] as? NSString {
                self.stateName = state
            }
            self.locationManager.stopUpdatingLocation()
            let location = "\(self.cityName), \(self.stateName)".stringByReplacingOccurrencesOfString("_", withString: " ")
            self.locationUpdatedCompletionHandler(location)
        })
    }
    
    
    func updateApiKey() {
        ref.child("api_keys").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.apiKey = (value?["wunderground"])! as! NSString
        })
    }
    
    func updateLocation(onCompletion: (String) -> Void) {
        locationUpdatedCompletionHandler = onCompletion
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func getForcast(onCompletion: (JSON) -> Void, onError: () -> Void) {
        if !CLLocationManager.locationServicesEnabled() || !didLocationInit() {
            onError()
            return
        }
        updateApiKey()
        
        var route = baseUrl
        route.appendContentsOf("\(apiKey)/hourly/q/\(self.stateName)/\(self.cityName).json")
        
        self.makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    
    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            onCompletion(json, error)
        })
        task.resume()
    }
    
    func didLocationInit() -> Bool {
        return(self.cityName != nil && self.stateName != nil)
    }
    
}
