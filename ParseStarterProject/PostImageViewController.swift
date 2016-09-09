//
//  PostImageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var usertitle = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usertitle = (PFUser.currentUser()?.username)!
        userTitle?.title = usertitle
    }
    

    @IBOutlet weak var userTitle: UINavigationItem!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var imagePicked = false

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var message: UITextField!
    
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackground()
        performSegueWithIdentifier("logout", sender: self)
        UIApplication.sharedApplication().keyWindow?.rootViewController = ViewController()
    }
    
    @IBAction func ChooseImage(sender: AnyObject) {
        
        //print((PFUser.currentUser()?.username)!)
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
   
    @IBAction func PostImage(sender: AnyObject) {
        
        var errorMessage = "Please try again later"
        
        if imagePicked {
            displayActivityIndicator()
            
            let post = PFObject(className: "Post")
            post["message"] = message.text
            post["userId"] = PFUser.currentUser()?.objectId
            post["userName"] = PFUser.currentUser()?.username
            
            let imageData = UIImageJPEGRepresentation(imageToPost.image!, 1)
            let imageFile = PFFile(name: "image.jpeg", data: imageData!)
            post["imageFile"] = imageFile
            
            post.saveInBackgroundWithBlock { (success, error) in
                
                self.hideActivityIndicator()
                if error == nil {
                    
                    //self.displayAlert("Successful", message: "Your image has been posted")
                    print("success")
                    self.imageToPost.image = UIImage(named: "ProfilePlaceholderSuit.png")
                    self.message.text = ""
                } else {
                    
                    if let errorString = error?.userInfo["error"] as? String {
                        
                        errorMessage = errorString
                    }
                    
                    //self.displayAlert("Failed to Post", message: errorMessage)
                    
                }
            }
            
        } else {
            
            self.displayAlert("Image not selected", message: "Pease select an image to post")
            
        }
        
        imagePicked = false

    }

    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
        imagePicked = true
    }
    
    func displayActivityIndicator() {
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) in
           
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }


}


