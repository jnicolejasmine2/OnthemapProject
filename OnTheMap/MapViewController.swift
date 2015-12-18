//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/23/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//


import Foundation
import UIKit
import MapKit
import CoreLocation
import FBSDKLoginKit
import FBSDKCoreKit



class MapViewController: UIViewController, UINavigationControllerDelegate, MKMapViewDelegate, AddInformationControllerDelegate   {

    // Map View
    @IBOutlet var mapView: MKMapView!


    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // If we have not gotten the students, call Parse to get them
        let count = studentLocationArrayShare.sharedInstance.studentLocationArray.count
        if count == 0 {
            get100Students()
        }
    }

    // Refesh the map when the current student has been added
    override func viewWillAppear(animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        mapViewLoad()

    }



    // ***** BUTTON MANAGEMENT  **** //

    // Logout button, logout both Udacity and Facebook
    @IBAction func logoutButtonAction(sender: AnyObject) {
        SharedHelpers.sharedInstance().logout(self)
    }

    // Refresh map, get the students and rebuild the annotation view
    @IBAction func refreshStudentAction(sender: AnyObject) {

        get100Students()
        mapView.removeAnnotations(mapView.annotations)
        mapViewLoad()
    }


    // Add/Update your own Pin
    @IBAction func addMyLocationAction(sender: AnyObject) {

        // Present the Add Information Controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AddInformationController") as! AddInformationController

        // Set map as a delegate so the map can be refreshed
        controller.delegate = self

        // Present the add information controllers
        self.presentViewController(controller, animated: true, completion: nil)
    }



    // Delegate from AddInformation, passing back new/updated student location so a pin can be added or removed
    func postStudentFinish() {
        mapView.removeAnnotations(mapView.annotations)
        mapViewLoad()
    }



    // ***** MAP MANAGEMENT  **** //

    // Get 100 students, used in initial load and when refresh button selected
    func get100Students() {

        // Get the latest 100 students to load onto the map
        ParseClient.sharedInstance().postGetStudentLocations() { success, errorString in

            // Check if connected to Internet
            if errorString == "Unable to Connect to Internet!"  {
                  self.presentAlert(errorString!, includeRetry: true, includeLogout: true)
            } else {

                // Check if we able to load 100 students
                if success   {

                    // If we successfully got the 100 students, then load the map
                    self.mapViewLoad()
                } else {

                    // Students not retrieved, present alert viewss
                    if errorString == nil {
                        self.presentAlert("Could Not Access Student Location Information!", includeRetry: true, includeLogout: true)
                    } else {

                        self.presentAlert(errorString!, includeRetry: true, includeLogout: true)

                    }
                }
            }
        }
    }


    // MapAnnotation View Build
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.greenColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }



    // Respond to tap of the pin callout, opens the student's URL
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }



    // Build the map, set up all the annotations into an annotation array
    func mapViewLoad() {

        var annotations = [MKPointAnnotation]()

        // Loop through students and load the annotations
        for student in studentLocationArrayShare.sharedInstance.studentLocationArray {

            // Check if student location is missing. If so, skip
            guard let _ = student.latitude, let _ = student.longitude
                else {
                    continue
            }

            // Student's location coordinates
            let latitude = CLLocationDegrees(student.latitude!)
            let longitude = CLLocationDegrees(student.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            // Student's info, defaulted in init so we know they can be unwrapped
            let firstName = student.firstName!
            let lastName = student.lastName!
            let mediaURL = student.mediaURL!

            // create the annotation, set coordiates, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL

            // Add the new annotation to the array
            annotations.append(annotation)
        }

        // When the array is complete, we add the annotations to the map
        self.mapView.addAnnotations(annotations)
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
            alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default, handler: {
                action in
                SharedHelpers.sharedInstance().logout(self)
            }))
        }


        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

}
