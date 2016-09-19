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
        usertitle = (PFUser.current()?.username)!
        userTitle?.title = usertitle
    }
    

    @IBOutlet weak var userTitle: UINavigationItem!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var imagePicked = false

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var message: UITextField!
    
    @IBAction func logOut(_ sender: AnyObject) {
        PFUser.logOutInBackground()
        performSegue(withIdentifier: "logout", sender: self)
        UIApplication.shared.keyWindow?.rootViewController = ViewController()
    }
    
    @IBAction func ChooseImage(_ sender: AnyObject) {
        
        //print((PFUser.currentUser()?.username)!)
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true, completion: nil)
    }
   
    @IBAction func PostImage(_ sender: AnyObject) {
        
        var errorMessage = "Please try again later"
        
        if imagePicked {
            displayActivityIndicator()
            
            let post = PFObject(className: "Post")
            post["message"] = message.text
            post["userId"] = PFUser.current()?.objectId
            post["userName"] = PFUser.current()?.username
            
            let imageData = UIImageJPEGRepresentation(imageToPost.image!, 1)
            let imageFile = PFFile(name: "image.jpeg", data: imageData!)
            post["imageFile"] = imageFile
            
            post.saveInBackground { (success, error) in
                
                self.hideActivityIndicator()
                if error == nil {
                    
                    //self.displayAlert("Successful", message: "Your image has been posted")
                    print("success")
                    self.imageToPost.image = UIImage(named: "ProfilePlaceholderSuit.png")
                    self.message.text = ""
                } else {
                    
                    if let errorString = error?._userInfo["error"] as? String {
                        
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

    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismiss(animated: true, completion: nil)
        imageToPost.image = image
        imagePicked = true
    }
    
    func displayActivityIndicator() {
        
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) in
           
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func backgroundThread(_ delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(priority: Int(DispatchQoS.QoSClass.userInitiated.rawValue)).async {
            if(background != nil){ background!(); }
            
            let popTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: popTime) {
                if(completion != nil){ completion!(); }
            }
        }
    }


}


