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
    
    let riseModel = RiseModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        riseModel.updateModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func testButtonPressed(sender: AnyObject) {
        riseModel.updateModel()
    }
   


}

