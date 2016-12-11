//
//  FeedModel.swift
//  InfoRise
//
//  Created by Alec Fong on 12/5/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import Foundation

class FeedModel: NSObject {
    
    static let sharedInstance = FeedModel()
    private let newsApiManager = NewsApimanager.sharedInstance
    private var articlesJson = [JSON]()
    var feedObjects = [FeedObject]()
    
    struct FeedObject {
        var headLine = ""
        var link = ""
        var description = ""
        var iconLink = ""
    }
    
    private override init() {
        super.init()
    }
    
    func updateModel(onCompletion: () -> Void){
        updateNews(onCompletion)
    }
    
    private func updateNews(onCompletion: () -> Void){
        newsApiManager.getNews { json in
            
            self.articlesJson = (json as JSON)["articles"].array!
            self.setFeed()
            
            onCompletion()
        }
    }
    
    private func setFeed() {
        for a in articlesJson {
            let fo = FeedObject(headLine: a["title"].string != nil ? a["title"].string! : "", link: a["url"].string!, description: a["description"].string != nil ? a["description"].string! : "", iconLink: a["urlToImage"].string != nil ? a["urlToImage"].string! : "")
            feedObjects.append(fo)
        }
    }
    
}
