/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

 class ViewController: UIViewController {
    
    var signUpActive = true
    
    @IBOutlet weak var signupLogin: UIButton!
    @IBOutlet weak var loginSignup: UIButton!
    @IBOutlet weak var regsteredText: UILabel!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.objectId != nil {
            
            self.performSegueWithIdentifier("login", sender: self)

        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        if userName.text == "" || userName.text == "" {
            
            displayAlert("Error in form", message: "Please enter a Username and Password")
            
        } else {
            
            displayActivityIndicator()
            
            var errorMessage = "Please try again later"

            if signUpActive {
                
                let user = PFUser()
                user.username = userName.text
                user.password = password.text
                
                
                user.signUpInBackgroundWithBlock({ (success, error) in
                    
                    self.hideActivityIndicator()
                    
                    if error == nil {
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = PostImageViewController()

                        
                    } else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed SignUp", message: errorMessage)
                    }
                })
                
            } else {
                
                PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!, block: { (user, error) in
                    
                    self.hideActivityIndicator()
                    
                    if user != nil {
                        
                        self.performSegueWithIdentifier("login", sender: self)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = PostImageViewController()

                        
                    } else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }
                
                        self.displayAlert("Failed Login", message: errorMessage)
                        
                    }
                })
            }
        }
        

    }
    
    
    
    @IBAction func login(sender: AnyObject) {
        
        if signUpActive {
            
            signupLogin.setTitle("Login", forState: .Normal)
            regsteredText.text = "Not registered?"
            loginSignup.setTitle("Sign Up", forState: .Normal)
            signUpActive = false
            
        } else {
            
            signupLogin.setTitle("Sign Up", forState: .Normal)
            regsteredText.text = "Already registered?"
            loginSignup.setTitle("Login", forState: .Normal)
            signUpActive = true

            
        }
    }

   
    
    
     func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayActivityIndicator() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

}
