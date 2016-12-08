//
//  FirstViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/1/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit
import CoreLocation

class RiseTableViewController: UITableViewController {
    
    let riseModel = RiseModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.riseModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return riseModel.weatherModules.count+1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return riseModel.weatherModules[section-1].outfits.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weatherCell", forIndexPath: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "\(riseModel.currentConditionString), \(riseModel.currentTemperature)°\(riseModel.measurementType == "english" ? "F" : "C")"
            
            let url = NSURL(string: riseModel.currentImageURL)!
            // Download task:
            // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                // if responseData is not null...
                if let data = responseData{
                    
                    // execute in UI thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.imageView!.image = UIImage(data: data)
                    })
                }
            }
            // Run task
            task.resume()
            
            return cell
        default:
            cell.textLabel?.text = riseModel.weatherModules[indexPath.section-1].outfits[indexPath.row] as String
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Current Weather Conditions"
        default:
            return "\(riseModel.weatherModules[section-1].startDay) \(riseModel.weatherModules[section-1].startTime) - \(riseModel.weatherModules[section-1].endDay) \(riseModel.weatherModules[section-1].endTime), wear"
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
     
        self.riseModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }


}

