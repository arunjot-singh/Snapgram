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
    
    override func viewDidAppear(_ animated: Bool) {
        
        if PFUser.current()?.objectId != nil {
            
            self.performSegue(withIdentifier: "login", sender: self)

        }
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        if userName.text == "" || userName.text == "" {
            
            displayAlert("Error in form", message: "Please enter a Username and Password")
            
        } else {
            
            displayActivityIndicator()
            
            var errorMessage = "Please try again later"

            if signUpActive {
                
                let user = PFUser()
                user.username = userName.text
                user.password = password.text
                
                
                user.signUpInBackground(block: { (success, error) in
                    
                    self.hideActivityIndicator()
                    
                    if error == nil {
                        
                        self.performSegue(withIdentifier: "login", sender: self)
                        UIApplication.shared.keyWindow?.rootViewController = PostImageViewController()

                        
                    } else {
                        
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }
                        
                        self.displayAlert("Failed SignUp", message: errorMessage)
                    }
                })
                
            } else {
                
                PFUser.logInWithUsername(inBackground: userName.text!, password: password.text!, block: { (user, error) in
                    
                    self.hideActivityIndicator()
                    
                    if user != nil {
                        
                        self.performSegue(withIdentifier: "login", sender: self)
                        UIApplication.shared.keyWindow?.rootViewController = PostImageViewController()

                        
                    } else {
                        
                        if let errorString = error?._userInfo["error"] as? String {
                            
                            errorMessage = errorString
                        }
                
                        self.displayAlert("Failed Login", message: errorMessage)
                        
                    }
                })
            }
        }
        

    }
    
    
    
    @IBAction func login(_ sender: AnyObject) {
        
        if signUpActive {
            
            signupLogin.setTitle("Login", for: UIControlState())
            regsteredText.text = "Not registered?"
            loginSignup.setTitle("Sign Up", for: UIControlState())
            signUpActive = false
            
        } else {
            
            signupLogin.setTitle("Sign Up", for: UIControlState())
            regsteredText.text = "Already registered?"
            loginSignup.setTitle("Login", for: UIControlState())
            signUpActive = true

            
        }
    }

   
    
    
     func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title , message: message , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayActivityIndicator() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }

}
