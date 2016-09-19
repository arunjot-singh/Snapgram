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
        
         func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return usernames.count
        }
        
         func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = sortedUsernames[(indexPath as NSIndexPath).row]
            
            let followedObjectID = userids[(indexPath as NSIndexPath).row]
            
            if isFollowing[followedObjectID] == true {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            
            return cell
            
        }
        
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
            
            let followedObjectID = userids[(indexPath as NSIndexPath).row]
            if isFollowing[followedObjectID] == false {
                
                isFollowing[followedObjectID] = true
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                
                let following = PFObject(className: "Followers")
                following["following"] = userids[(indexPath as NSIndexPath).row]
                following["follower"] = PFUser.current()?.objectId
                following.saveInBackground()
                
            } else {
                
                isFollowing[followedObjectID] = false
                cell.accessoryType = UITableViewCellAccessoryType.none
                
                let query = PFQuery(className: "Followers")
                query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                query.whereKey("following", equalTo: userids[(indexPath as NSIndexPath).row])
                
                query.findObjectsInBackground(block: { (objects, error) in
                    
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
            query?.findObjectsInBackground(block: { (objects, error) in
                
                if let users = objects {
                    
                    self.usernames.removeAll(keepingCapacity: true)
                    self.userids.removeAll(keepingCapacity: true)
                    self.sortedUsernames.removeAll(keepingCapacity: true)
                    self.isFollowing.removeAll(keepingCapacity: true)
                    
                    for object in users {
                        
                        if let user = object as? PFUser {
                            
                            if user.objectId != PFUser.current()?.objectId {
                                
                                self.usernames.append(user.username!)
                                self.userids.append(user.objectId!)
                                
                                let query = PFQuery(className: "Followers")
                                query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                                query.whereKey("following", equalTo: user.objectId!)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                    
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
                
                self.sortedUsernames = self.usernames.sorted{ $0 < $1 }
                
            })
        }
        
        func refresh() {
            
            refresher = UIRefreshControl()
            refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refresher.addTarget(self, action: #selector(TableViewController.loadUserList), for: UIControlEvents.valueChanged)
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
