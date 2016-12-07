//
//  FirstViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/1/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit
import CoreLocation

class RiseViewController: UIViewController {

    let weatherApiManager = WeatherApiManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func testButtonPressed(sender: AnyObject) {
        weatherApiManager.getForcast { json in
            print(json)
        }
        
    }
   


}

