//
//  SecondViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/1/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {
    
    let newsApiManager = NewsApimanager.sharedInstance


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func newsButtonPressed(sender: AnyObject) {
        newsApiManager.getNews { json in
            print(json)
        }
    }


}

