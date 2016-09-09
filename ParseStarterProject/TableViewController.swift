//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/11/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        var refresher: UIRefreshControl!
        
        
        var usernames = [""]
        var sortedUsernames = [""]
        var userids = [""]
        var isFollowing = ["":false]
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            loadUserList()
            refresh()
        }
        
         func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
         func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return usernames.count
        }
        
         func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.textLabel?.text = sortedUsernames[indexPath.row]
            
            let followedObjectID = userids[indexPath.row]
            
            if isFollowing[followedObjectID] == true {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            
            return cell
            
        }
        
         func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
            
            let followedObjectID = userids[indexPath.row]
            if isFollowing[followedObjectID] == false {
                
                isFollowing[followedObjectID] = true
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                
                let following = PFObject(className: "Followers")
                following["following"] = userids[indexPath.row]
                following["follower"] = PFUser.currentUser()?.objectId
                following.saveInBackground()
                
            } else {
                
                isFollowing[followedObjectID] = false
                cell.accessoryType = UITableViewCellAccessoryType.None
                
                let query = PFQuery(className: "Followers")
                query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                query.whereKey("following", equalTo: userids[indexPath.row])
                
                query.findObjectsInBackgroundWithBlock({ (objects, error) in
                    
                    if let objects = objects {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                            
                        }
                    }
                })
            }
        }
        
        func loadUserList() {
            
            let query = PFUser.query()
            query?.findObjectsInBackgroundWithBlock({ (objects, error) in
                
                if let users = objects {
                    
                    self.usernames.removeAll(keepCapacity: true)
                    self.userids.removeAll(keepCapacity: true)
                    self.sortedUsernames.removeAll(keepCapacity: true)
                    self.isFollowing.removeAll(keepCapacity: true)
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            if user.objectId != PFUser.currentUser()?.objectId {
                                
                                self.usernames.append(user.username!)
                                self.userids.append(user.objectId!)
                                
                                let query = PFQuery(className: "Followers")
                                query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
                                query.whereKey("following", equalTo: user.objectId!)
                                
                                query.findObjectsInBackgroundWithBlock({ (objects, error) in
                                    
                                    if let objects = objects {
                                        
                                        if objects.count > 0{
                                            
                                            self.isFollowing[user.objectId!] = true
                                            
                                        } else {
                                            
                                            self.isFollowing[user.objectId!] = false
                                        }
                                        
                                    }
                                    
                                    if self.isFollowing.count == self.usernames.count {
                                        self.tableView.reloadData()
                                        self.refresher.endRefreshing()
                                        
                                    }
                                })
                            }
                        }
                    }
                }
                
                self.sortedUsernames = self.usernames.sort{ $0 < $1 }
                
            })
        }
        
        func refresh() {
            
            refresher = UIRefreshControl()
            refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refresher.addTarget(self, action: #selector(TableViewController.loadUserList), forControlEvents: UIControlEvents.ValueChanged)
            self.tableView.addSubview(refresher)
        }
        
        //    func displayActivityIndicator() {
        //        
        //        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        //        activityIndicator.center = self.view.center
        //        activityIndicator.hidesWhenStopped = true
        //        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        //        view.addSubview(activityIndicator)
        //        activityIndicator.startAnimating()
        //        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        //    }
        //    
        //    func hideActivityIndicator() {
        //        
        //        self.activityIndicator.stopAnimating()
        //        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        //    }


}
