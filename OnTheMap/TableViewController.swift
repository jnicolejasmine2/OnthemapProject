//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/27/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit


class TableViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource  {

    // Table View
    @IBOutlet weak var studentTableView: UITableView!


    // ***** VIEW CONTROLLER MANAGEMENT  **** //

    override func viewWillAppear(animated: Bool) {

        // Refesh the table when the current student adds/updates their pin
        studentTableView.reloadData()
    }



    // ***** TABLE MANAGEMENT  **** //

    // Number of Rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocationArrayShare.sharedInstance.studentLocationArray.count
    }

    // Load the images and text into the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("StudentTableCell", forIndexPath: indexPath) as! TableViewCell

        let student = studentLocationArrayShare.sharedInstance.studentLocationArray[indexPath.row]

        // Set Top and Bottom Text
        cell.studentName.text =  student.firstName! + " " + student.lastName!
        cell.studentMediaURL.text = student.mediaURL!

        cell.infoIcon.image = UIImage(named: "InfoIcon")
        cell.infoIcon.image = cell.infoIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.infoIcon.tintColor = UIColor.darkGrayColor()

        return cell
    }


    // When a student is selected, open safari to show link
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let app = UIApplication.sharedApplication()
        let student = studentLocationArrayShare.sharedInstance.studentLocationArray[indexPath.row]

        app.openURL(NSURL(string: student.mediaURL!)!)
    }



    // ***** BUTTON MANAGEMENT  **** //

    // Logout button, logout both Udacity and Facebook
    @IBAction func logoutButtonAction(sender: AnyObject) {
        SharedHelpers.sharedInstance().logout(self)
    }


    // Add/Update your own Pin
    @IBAction func addMyLocation(sender: AnyObject) {

        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AddInformationController") as! AddInformationController

        // Present Add Information controller
        self.presentViewController(controller, animated: true, completion: nil)

    }


    // Refresh List, get the students and rebuild the annotation view
    @IBAction func refreshStudentsAction(sender: AnyObject) {
        self.get100Students()
    }



    // ***** ALERT MANAGEMENT  **** //

    // Present alert views
    func presentAlert(alertMessage: String, includeRetry: Bool, includeLogout: Bool) {

        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)

        // Option: Try again
        if includeRetry  {
            alert.addAction(UIAlertAction(title: "Try Again ", style: UIAlertActionStyle.Default, handler: {
                action in

                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshStudentsAction("nothing needed")
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


    // Get 100 students, used in initial load and when refresh button selected
    func get100Students() {

        // Get the latest 100 students to load onto the map
        ParseClient.sharedInstance().postGetStudentLocations() { success, errorString in
            if errorString == "Unable to Connect to Internet!"  {
                self.presentAlert(errorString!, includeRetry: true, includeLogout: true)
            }

            // Check if we able to load 100 students
            if success   {

                // If we successfully got the 100 students, then load the table
                self.studentTableView.reloadData()

            } else {

                // Could not get the students, present alert views
                if errorString == nil {
                    self.presentAlert("Could Not Access Student Location Information!", includeRetry: true, includeLogout: true)
                } else {
                    self.presentAlert(errorString!, includeRetry: true, includeLogout: true)
                }
            }
        }
    }

}
