//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/30/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit
import AddressBookUI
import CoreLocation



class  AddLocationViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate  {


    // Button to find location
    @IBOutlet weak var findLocationButton: UIButton!

    // Text Fields
    @IBOutlet weak var locationText: UITextField!
    private let textDelegate = TextDelegate()

    // Variables that will be passed to add location view controller
    var delegate: AddLocationViewControllerDelegate?
    var locationLatitude: Double?
    var locationLongitude: Double?

    // Activity Indicator
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!





     // ***** BUTTON MANAGEMENT  **** //

    // Find Location Touched
    @IBAction func locationSubmitAction(sender: AnyObject) {

        // Close down keyboard
        locationText.resignFirstResponder()

        // Check for valid location
        forwardGeocoding(locationText.text!)
    }


    // Call Apple Geocoding to see if can get valid coordinates
    func forwardGeocoding(address: String)  {

        //  Start activity indicator and disable button
        SharedHelpers.sharedInstance().activityIndicatorsOn(self.activityIndicatorView, button: self.findLocationButton)

        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in

            //  Stop activity indicator and enable button
            SharedHelpers.sharedInstance().activityIndicatorsOff(self.activityIndicatorView, button: self.findLocationButton)

            // Check for errors
            if error != nil {
                self.presentAlert("Unable to find location!", includeRetry: true, includeLogout: true)
                return
            }

            // No errors get the coordinate
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]

                let location = placemark?.location
                let coordinate = location?.coordinate
                self.locationLatitude = coordinate!.latitude
                self.locationLongitude = coordinate!.longitude

                // Send back to the add location view controller so it can be presented and submitted
                self.delegate!.locationFinish(self, newLocation: self.locationText.text!, longitude: self.locationLongitude, latitude: self.locationLatitude, cancelChosen: false)
            }
        })
    }



    // ***** ALERT MANAGEMENT  **** //

    func presentAlert(alertMessage: String, includeRetry: Bool, includeLogout: Bool) {

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

        // Option: Logout
        if includeLogout {
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
                action in
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate!.locationFinish(self, newLocation: nil, longitude: nil, latitude: nil, cancelChosen: true)
                })
            }))
        }

        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}


// Needed so that the location and coordinates can be sent back to the Add information
protocol AddLocationViewControllerDelegate {
    func locationFinish(controller: AddLocationViewController, newLocation: String?, longitude: Double?, latitude: Double?, cancelChosen: Bool?)
}
