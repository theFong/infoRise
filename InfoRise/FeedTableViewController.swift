//
//  SecondViewController.swift
//  InfoRise
//
//  Created by Alec Fong on 12/1/16.
//  Copyright © 2016 Alec Fong. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    let feedModel = FeedModel.sharedInstance


    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.feedModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedModel.feedObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = feedModel.feedObjects[indexPath.row].headLine
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0;//Choose your custom row height
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {

        self.feedModel.updateModel({
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
        
    }

}

