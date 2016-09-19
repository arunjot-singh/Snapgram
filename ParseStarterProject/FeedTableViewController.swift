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
        
    @IBAction func refresh(_ sender: AnyObject) {
        
        loadFeed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFeed()

        
       // })
    }
    
     func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath) as! feedCell
        
        imageFiles[(indexPath as NSIndexPath).row].getDataInBackground { (data, error) in
            
            if let downloadedImage = UIImage(data: data!) {
                
                cell.postedImage.image = downloadedImage
            }
        }
        
        cell.userName.text = userNames[(indexPath as NSIndexPath).row]
        cell.message.text = messages[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func loadFeed() {
        
        let getFollowedUsersQuery = PFQuery(className: "Followers")
        getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.current()!.objectId!)
        getFollowedUsersQuery.findObjectsInBackground { (objects, error) in
            
            if let objects = objects {
                
                self.messages.removeAll(keepingCapacity: true)
                self.userNames.removeAll(keepingCapacity: true)
                self.imageFiles.removeAll(keepingCapacity: true)
                
                
                for object in objects {
                    
                    let followedUser = object["following"] as! String
                    
                    let postQuery = PFQuery(className: "Post")
                    postQuery.whereKey("userId", equalTo: followedUser)
                    
                    postQuery.findObjectsInBackground(block: { (objects, error) in
                        
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
