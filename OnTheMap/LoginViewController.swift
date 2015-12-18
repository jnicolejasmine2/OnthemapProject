//
//  LoginController
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/20/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit


class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    // Text Fields from View
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    private let textDelegate = TextDelegate()

    // Buttons from View
    @IBOutlet weak var udacitySignInButton: UIButton!
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!

    // Error Messange and Activity Indicator from View
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and permissions for Facebook Login
        facebookSignInButton.delegate = self
        facebookSignInButton.readPermissions = ["public_profile"]

        // Set the text delegate, edits, close keyboard
        emailTextField.delegate = textDelegate
        passwordTextField.delegate = textDelegate

        // Subscribe the notifications so that the bottom text will move when keyboard is presented
        subscribeToKeyboardNotifications()
    }

    func viewWillDisappear() {

        // Subscribe the notifications so that the bottom text will move when keyboard is presented
        unsubscribeFromKeyboardNotifications()
    }



    // ***** BUTTON MANAGEMENT  **** //


    // Udacity Login Button
    @IBAction func loginButtonTouched(sender: AnyObject) {

        // Resign keyboards if left open and reset the view down if keyboard moved it up
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        view.frame.origin.y = 0

        // Edit that an email and a password were entered
        if emailTextField.text == "" {
            errorMessage.text = "Udacity Email is Required"
        } else if passwordTextField.text == "" {
            errorMessage.text = "Udacity Password is Required"
        } else {

            // All is good clear the error message
            errorMessage.text = nil

            // start activity indicator and disable button
            SharedHelpers.sharedInstance().activityIndicatorsOn(loginActivityIndicator, button: udacitySignInButton)

            // Try to Sign on with Udacity
            UdacityClient.sharedInstance().postSignInUdacity(emailTextField.text, password: passwordTextField.text, facebookToken: nil) { success, errorString in

                // If successful, stop the activity indicators and pass control to the map view controller
                if success {
                    // Get the storyboard and ResultViewController
                    dispatch_async(dispatch_get_main_queue(), {

                        // Stop activity indicator and enable button
                        SharedHelpers.sharedInstance().activityIndicatorsOff(self.loginActivityIndicator, button: self.udacitySignInButton)

                        // Present map view controller
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navigationControllerOne") as! UINavigationController
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                } else {

                    // Not sucessful, did not get logged in.  Present alert
                     dispatch_async(dispatch_get_main_queue(), {

                        //  Stop activity indicator and enable button
                        SharedHelpers.sharedInstance().activityIndicatorsOff(self.loginActivityIndicator, button: self.udacitySignInButton)

                        //  Present Alert
                        if let _ = errorString {
                            self.presentAlert(errorString!, includeRetry: true)

                        } else {
                            self.presentAlert(errorString!, includeRetry: true)
                        }
                    })
                }
            }
        }
    }


    // Link to sign up with Udacity, open Udacity web site
    @IBAction func signUpActionLinkToWeb(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)

    }



    // ***** FACEBOOK MANAGEMENT  **** //

    // Facebook Login Button
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        // Error Occurred With FaceBook Signin
        if error  != nil {

            self.errorMessage.text = error.domain
            if let _ = self.errorMessage.text {
                self.presentAlert(self.errorMessage.text!, includeRetry: true)
            } else {
                self.presentAlert("Unable to login with Facebook!", includeRetry: true)
            }
            return
        }

        // Got the token from Facebook, now need to sign on to Udacity
        if let userToken = result.token {
            let accessToken = userToken.tokenString


            // Start activity indicator and disable button
            SharedHelpers.sharedInstance().activityIndicatorsOn(loginActivityIndicator, button: udacitySignInButton)

            UdacityClient.sharedInstance().postSignInUdacity(nil, password: nil, facebookToken: accessToken) { success, errorString in

                if success {
                    // Get the storyboard and ResultViewController
                    dispatch_async(dispatch_get_main_queue(), {

                        // Stop activity indicator and disable button
                        SharedHelpers.sharedInstance().activityIndicatorsOff(self.loginActivityIndicator, button: self.udacitySignInButton)

                        // Turn buttons back on in case of Logout
                        self.udacitySignInButton.enabled = true
                        //  self.facebookSignInButton.enabled = true

                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("navigationControllerOne") as! UINavigationController
                        self.presentViewController(controller, animated: true, completion: nil)
                    })

                } else {
                    dispatch_async(dispatch_get_main_queue()) {

                        // Stop activity indicator and disable button
                        SharedHelpers.sharedInstance().activityIndicatorsOff(self.loginActivityIndicator, button: self.udacitySignInButton)
                        
                        self.errorMessage.text = errorString
                        self.udacitySignInButton.enabled = true
                        //     self.facebookSignInButton.enabled = true
                    }
                    
                }
            }
        }
    }


    // Need when the login button is switched to Logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }




    // ***** ALERT MANAGEMENT  **** //

    func presentAlert(alertMessage: String, includeRetry: Bool ) {

        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)

        // Option: Try again
        if includeRetry  {
            alert.addAction(UIAlertAction(title: "Try Again ", style: UIAlertActionStyle.Default, handler: {
                action in

                dispatch_async(dispatch_get_main_queue(), {
                    self.viewDidLoad()
                })
            }))
        }

        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }


    // ***** KEYBOARD MANAGEMENT  **** //

    // Subsribe to notifications so the view can be moved for the bottom text
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }


    // Unsubscribe from the notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    // If keyboard is not moved up, then move the view out of the way
    func keyboardWillShow(notification: NSNotification) {
        let _ = getKeyboardHeight(notification)
            view.frame.origin.y = 0
            view.frame.origin.y -= getKeyboardHeight(notification)
     }


    // Reset View back down
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }


    // Get keyboard height, used to calculate how much to move keyboard up
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

}
