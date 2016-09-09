//
//  FeedTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages = [String]()
    var userNames = [String]()
    var imageFiles = [PFFile]()
    var users = [String: String]()
        
    @IBAction func refresh(sender: AnyObject) {
        
        loadFeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFeed()

        
       // })
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("feedcell", forIndexPath: indexPath) as! feedCell
        
        imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) in
            
            if let downloadedImage = UIImage(data: data!) {
                
                cell.postedImage.image = downloadedImage
            }
        }
        
        cell.userName.text = userNames[indexPath.row]
        cell.message.text = messages[indexPath.row]
        return cell
    }
    
    func loadFeed() {
        
        let getFollowedUsersQuery = PFQuery(className: "Followers")
        getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            
            if let objects = objects {
                
                self.messages.removeAll(keepCapacity: true)
                self.userNames.removeAll(keepCapacity: true)
                self.imageFiles.removeAll(keepCapacity: true)
                
                
                for object in objects {
                    
                    let followedUser = object["following"] as! String
                    
                    let postQuery = PFQuery(className: "Post")
                    postQuery.whereKey("userId", equalTo: followedUser)
                    
                    postQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                        
                        if let objects = objects {
                            
                            for object in objects {
                                
                                self.messages.append(object["message"] as! String)
                                self.imageFiles.append(object["imageFile"] as! PFFile)
                                self.userNames.append(object["userName"] as! String)
                                
                                self.tableView.reloadData()
                            }
                            
                            print(self.userNames)
                            print(self.messages)
                        }
                    })
                }
            }
        }
    }
    
    

}
