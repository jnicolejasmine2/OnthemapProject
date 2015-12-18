//
//  AddInformationController.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/30/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//



import Foundation
import UIKit
import MapKit


class AddInformationController: UIViewController, UINavigationControllerDelegate, AddLocationViewControllerDelegate  {

    // Container view that for the location, overlays getting the Share URL
    @IBOutlet weak var containerLocationView: UIView!
    var switchViewsIndicator: Int = 0
    var delegate: AddInformationControllerDelegate?


    // URL TextFields
    @IBOutlet weak var enterURLLabel: UILabel!
    @IBOutlet weak var urlText: UITextField!
    private let textDelegate = TextDelegate()

    // Buttons from the view
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var submitButton: UIButton!

    // Map and label showing location entered
    @IBOutlet weak var studentMapView: MKMapView!
    @IBOutlet weak var locationDescription: UILabel!

    // Variables
    var studentLatitude: Double?
    var studentLongitude: Double?

    // Activity Indicator
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!



    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewDidLoad() {
        super.viewDidLoad()

        // Turn off activity indicator
        submitActivityIndicator.hidden = true

        // Set up text delegate
        urlText.delegate = textDelegate

        // Switch to location view on first time in
        switchViews()
    }



    // ***** BUTTON MANAGEMENT  **** //

    // Cancel button, dismiss view controller, returns to either map or table view
    @IBAction func cancelButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Submit button
    @IBAction func submitAction(sender: AnyObject) {

        // Check URL was entered.  Since the link on the pin 
        // does not work without HTTP..., make sure it is entered
        if  let checkText = urlText.text  {

            let letters = NSCharacterSet.letterCharacterSet()
            let range = checkText.rangeOfCharacterFromSet(letters)
            let httpRange = checkText.rangeOfString("http://www.")
            let httpsRange = checkText.rangeOfString("https://www.")

            // edit for valid http characters...
            if let _ = range  {
                if httpsRange != nil || httpRange != nil {

                    // Got a good URL entered.
                    //  Start activity indicator and disable button
                    SharedHelpers.sharedInstance().activityIndicatorsOn(self.submitActivityIndicator, button: self.submitButton)

                    let jsonBodySet: [String: AnyObject!] =
                    ["uniqueKey": udacityStudent.sharedInstance.udacityStudentID,
                        "firstName": udacityStudent.sharedInstance.udacityStudentFirstName,
                        "lastName": udacityStudent.sharedInstance.udacityStudentLastName,
                        "mapString": locationDescription.text,
                        "mediaURL": urlText.text,
                        "latitude": studentLatitude,
                        "longitude": studentLongitude 
                    ]

                    // Call Parse to post the new information for the student
                    ParseClient.sharedInstance().PUTPOSTStudentLocation(jsonBodySet, completionHandler: { success, errorString in

                        if success {

                            // Get the storyboard and ResultViewController
                            dispatch_async(dispatch_get_main_queue(), {

                                // Locate an existing entry, remove from list so that the pin is also removed
                                var index = 0

                                for student in studentLocationArrayShare.sharedInstance.studentLocationArray {

                                    if let studentFirstName = student.firstName, studentLastName = student.lastName  {
                                            if studentFirstName == udacityStudent.sharedInstance.udacityStudentFirstName && studentLastName == udacityStudent.sharedInstance.udacityStudentLastName {
                                                studentLocationArrayShare.sharedInstance.studentLocationArray.removeAtIndex(index)

                                                break
                                            }
                                    }
                                    index++
                                }

                                // Insert the new information at the beggining, assume it is the most current
                                let newStudentLocation = studentLocation.studentLocationsIndividual(jsonBodySet)
                                studentLocationArrayShare.sharedInstance.studentLocationArray.insert(newStudentLocation, atIndex: 0)

                                // Delegate back to Map so that the pin information is refreshed.
                                if self.delegate != nil {
                                    self.delegate!.postStudentFinish()
                                }

                                //  Stop activity indicator and enable button
                                SharedHelpers.sharedInstance().activityIndicatorsOff(self.submitActivityIndicator, button: self.submitButton)

                                // Dismiss view controller, return to either map or table view
                                self.dismissViewControllerAnimated(true, completion: nil)

                            })
                        } else {

                            // Got an error and could not post the student information
                            dispatch_async(dispatch_get_main_queue(),  {

                                //  Stop activity indicator and enable button
                                SharedHelpers.sharedInstance().activityIndicatorsOff(self.submitActivityIndicator, button: self.submitButton)

                                // Present the alert view
                                self.presentAlert(errorString!, includeRetry: true, includeCancel: true)
                            })
                        }
                    
                    })
                } else {
                    self.presentAlert("URL must begin with http://www. or https://wwww.!", includeRetry: true, includeCancel: true)
                        }
            } else {
                self.presentAlert("URL is required!", includeRetry: true, includeCancel: true)
                    }
        } else  {
             self.presentAlert("URL is required!", includeRetry: true, includeCancel: true)
        }
    }



    // Delegate from the container for the location 
    // Passes back longitude, latitude, location info
    // Switch so that the submit button shows & hide contianer
    func locationFinish(controller: AddLocationViewController, newLocation: String?, longitude: Double?, latitude: Double?, cancelChosen: Bool?) {

        // Cancel was chosen, dismiss view controller and return to either map or table view
        if cancelChosen == true {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }

        locationDescription.text = controller.locationText!.text!
        studentLatitude = latitude
        studentLongitude = longitude

        // Load the student location map
        mapViewLoad()

        // Switch the location sub-view for the URL fields
        switchViews()

    }


    // Set up the delegate for the view location controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addLocationSegue"  {
            let vc = segue.destinationViewController as! AddLocationViewController
            vc.delegate = self
        }
    }


    // Switch between the two container views depending on whether we have finished getting a location
    // 0 means show the Location View    
    func switchViews () {

        if switchViewsIndicator == 0 {

            containerLocationView.hidden = false
            submitButton.hidden = true
            enterURLLabel.hidden = true
            urlText.hidden = true
            locationDescription.hidden = true
            studentMapView.hidden = true
            
            switchViewsIndicator = 1

        } else if switchViewsIndicator == 1 {

            containerLocationView.hidden = true
            switchViewsIndicator = 0
            submitButton.hidden = false
            enterURLLabel.hidden = false
            urlText.hidden = false
            locationDescription.hidden = false
            studentMapView.hidden = false
        }
    }


    // ***** MAP MANAGEMENT  **** //

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


        // Student's location coordinates
        let latitude = CLLocationDegrees(studentLatitude!)
        let longitude = CLLocationDegrees(studentLongitude!)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        // Set region
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        studentMapView.setRegion(region, animated: true)


        // Student's info, defaulted in init so we know they can be unwrapped

        // create the annotation, set coordiates, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        annotation.title = udacityStudent.sharedInstance.udacityStudentFirstName! + " " + udacityStudent.sharedInstance.udacityStudentLastName!
        annotation.subtitle = locationDescription.text

        // Add the new annotation to the array
        annotations.append(annotation)

        // When the array is complete, we add the annotations to the map
        self.studentMapView.addAnnotations(annotations)
    }



    // ***** ALERT MANAGEMENT  **** //


    func presentAlert(alertMessage: String, includeRetry: Bool, includeCancel: Bool) {

        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)

        // Option: Try again
        if includeRetry  {
            alert.addAction(UIAlertAction(title: "Try Again ", style: UIAlertActionStyle.Default, handler: {
                action in

                dispatch_async(dispatch_get_main_queue(), {
                })
            }))
        }

        // Option: Logout
        if includeCancel {
            alert.addAction(UIAlertAction(title: "Cancel ", style: UIAlertActionStyle.Default, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
        }

        // Present the Alert!
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }


}


// Delegate from Location View Controller. Needed so that the location and coordinates can be passed back.
protocol AddInformationControllerDelegate {
    func postStudentFinish()
}
