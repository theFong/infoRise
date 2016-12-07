//
//  WeatherApiManager.swift
//  InfoRise
//
//  Created by Alec Fong on 12/4/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import Foundation
import FirebaseDatabase
import SwiftyJSON

class NewsApimanager: NSObject {
    static let sharedInstance = NewsApimanager()
    
    let baseUrl = "https://newsapi.org/v1/"
    
    var currentSource = "google-news"
    
    var sortBy = "top"
    
    var ref: FIRDatabaseReference!

    
    
    override private init() {
        super.init()
        ref = FIRDatabase.database().reference()
        
    }

    
    func getNews(onCompletion: (JSON) -> Void) {

        var route = baseUrl
        
        ref.child("api_keys").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let api_key = (value?["news_api"])!
            route.appendContentsOf("articles?source=\(self.currentSource)&sortBy=top&apiKey=\(api_key)")
            
            
            self.makeHTTPGetRequest(route, onCompletion: { json, err in
                onCompletion(json as JSON)
            })
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
    
    
}
