//
//  ProfileViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/4/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var notifyTimePicker: UIDatePicker!
    @IBOutlet weak var notifyTimeButton: UIButton!
    
    @IBOutlet weak var metricSwitch: UISwitch!
    
    var fireBaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disablePicker()
        fireBaseRef = FIRDatabase.database().reference()
        
        initPicker()
        self.fireBaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("name").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                self.nameLabel.text = snapshot.value as? String
            })
        emailLabel.text = FIRAuth.auth()?.currentUser?.email
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initPicker() {
        self.fireBaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            let valDict = snapshot.value as? NSDictionary
            
            // create dateFormatter with UTC time format
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            let date = dateFormatter.dateFromString((valDict?["notify_time"])! as! String)// create   date from string
            
            // change to a readable time format and change to local time zone
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            let timeStamp = dateFormatter.stringFromDate(date!)
            
            let localTime = dateFormatter.dateFromString(timeStamp)
            
            self.notifyTimePicker.setDate(localTime!, animated: false)
        })
    }
    
    @IBAction func metricSwitchChanged(sender: AnyObject) {
        if metricSwitch.on {
            RiseModel.sharedInstance.measurementType = "metric"
        } else {
            RiseModel.sharedInstance.measurementType = "english"
        }
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        handleLogout()
        self.performSegueWithIdentifier("toLogin", sender: nil)
    }
    
    @IBAction func updateLocationButtonPressed(sender: AnyObject) {
        WeatherApiManager.sharedInstance.updateLocation({(location) in
            let alertController = UIAlertController(title: "Location Updated", message:
                location, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func notifyTimeButtonPressed(sender: AnyObject) {
        if notifyTimeButton.titleLabel?.text! == "Save Time" {
            notifyTimeButton.setTitle("Change Notify Time", forState: .Normal)
            saveTime()
            disablePicker()
            
        } else {
            notifyTimeButton.setTitle("Save Time", forState: .Normal)
            enablePicker()
        }
        
    }
    
    func enablePicker() {
        notifyTimePicker.userInteractionEnabled = true
        notifyTimePicker.alpha = 1.0
    }
    
    func disablePicker() {
        notifyTimePicker.userInteractionEnabled = false
        notifyTimePicker.alpha = 0.4
    }
    
    func saveTime(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let time = dateFormatter.stringFromDate(notifyTimePicker.date)
        fireBaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("notify_time").setValue(time)
        
    }
    
    func handleLogout() {
        GIDSignIn.sharedInstance().signOut()
        try! FIRAuth.auth()!.signOut()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
