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
    
    let newsApiManager = NewsApimanager.sharedInstance
    
    override init() {
        super.init()
        
        
    }
    
}
