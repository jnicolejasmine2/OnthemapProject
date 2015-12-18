//
//  SharedHelpers.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 12/13/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//


import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit


class SharedHelpers: UIViewController   {


// ***** BUTTON MANAGEMENT  **** //

    // Start animating activity indicators
    // Disable a button and put the color back
    func activityIndicatorsOn(activityIndicator: UIActivityIndicatorView? , button: UIButton?) {

        if let _ = activityIndicator {
              activityIndicator!.startAnimating()
        }
        if let _ = button {
            button!.enabled = false
            button!.alpha = 0.5
        }
    }


    // Stop animating activity indicators
    // Enable a button and put the color back
    func activityIndicatorsOff(activityIndicator: UIActivityIndicatorView? , button: UIButton?) {

        if let _ = activityIndicator {
            activityIndicator!.stopAnimating()
        }

        if let _ = button {
            button!.enabled = true
            button!.alpha = 1.0
        }
    }


    // Function to logout both Udacity and Facebook
    func logout(currentController: UIViewController!) {

        let logoutManager = FBSDKLoginManager()
        logoutManager.logOut()

        studentLocationArrayShare.sharedInstance.studentLocationArray = []

        UdacityClient.sharedInstance().deleteSignInUdacity() { success, errorString in
            dispatch_async(dispatch_get_main_queue(), {
                currentController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }



    // Shared Instance

    class func sharedInstance() -> SharedHelpers {

        struct Singleton {
            static var sharedInstance = SharedHelpers()
        }
        return Singleton.sharedInstance
    }


}
