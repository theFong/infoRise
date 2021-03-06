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
    
    var tooHotButton = RadioButton()
    var tooColdButton = RadioButton()
    var justRightButton = RadioButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.riseModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }
    
    override func awakeFromNib() {
        self.view.layoutIfNeeded()
        
        tooHotButton.selected = false
        tooHotButton.setButtonColor(hexStringToUIColor("FAAF09").CGColor)
        tooColdButton.selected = false
        tooColdButton.setButtonColor(hexStringToUIColor("3D586C").CGColor)
        justRightButton.selected = false
        justRightButton.setButtonColor(UIColor.greenColor().CGColor)
        
        tooHotButton.alternateButton = [tooColdButton,justRightButton]
        tooColdButton.alternateButton = [tooHotButton,justRightButton]
        justRightButton.alternateButton = [tooColdButton,tooHotButton]
        
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
            return riseModel.groups[section].groupElements.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weatherCell", forIndexPath: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.textColor = hexStringToUIColor("FAAF09")
            cell.textLabel?.font = cell.textLabel!.font.fontWithSize(20)

            if(riseModel.currentConditionString == nil || riseModel.currentTemperature == nil){
                cell.textLabel?.textAlignment = .Center
                cell.textLabel?.text = "Refresh"
                self.riseModel.updateModel({
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                })
            } else {
                cell.textLabel?.textAlignment = .Left
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
            }
            return cell
        default:
            cell.textLabel?.font = cell.textLabel!.font.fontWithSize(16)
            cell.imageView!.image = nil
            //hacky fix to weird bug where sometimes the outfits get cleared, appears before load often
            if riseModel.weatherModules[indexPath.section-1].outfits.count == 0 {
                print("null in table caught")
                return cell
            }
            // clothing icon
//            cell.imageView?.image = UIImage(named: riseModel.weatherModules[indexPath.section-1].outfits[indexPath.row].image as String)
            cell.imageView?.image = UIImage(named: riseModel.groups[indexPath.section].groupElements[indexPath.row].image as String)
            
            
            if riseModel.groups[indexPath.section].groupElements[indexPath.row].specialCondition {
                cell.textLabel?.textColor = hexStringToUIColor("FAAF09") //yellow
            } else {
                cell.textLabel?.textColor = hexStringToUIColor("3D586C") //blue

            }
            cell.textLabel?.text = riseModel.groups[indexPath.section].groupElements[indexPath.row].name
            return cell
        }
    }
    
    //custom row height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) ->
        CGFloat {
        switch indexPath.section {
        case 0:
            return 75;
        default:
            return 50;
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            let cityName = riseModel.currentCityStr.stringByReplacingOccurrencesOfString("_", withString: " ")
            return "Current Conditions, \(cityName)"
        default:
            return "\(riseModel.weatherModules[section-1].startDay) \(riseModel.weatherModules[section-1].startTime) - \(riseModel.weatherModules[section-1].endDay != riseModel.weatherModules[section-1].startDay ? riseModel.weatherModules[section-1].endDay : "") \(riseModel.weatherModules[section-1].endTime), suggest"
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
     
        self.riseModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }
    
    //stackoverflow
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }


}





