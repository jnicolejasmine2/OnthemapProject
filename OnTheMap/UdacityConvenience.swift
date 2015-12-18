//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/21/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient  {


    func postSignInUdacity(email: String?, password: String?, facebookToken: String?,  completionHandler: (success: Bool, errorString: String? ) -> Void){

        postSignInUdacityGetKey (email, passwordText: password, facebookToken: facebookToken,  completionHandler: {successPost, errorStringPost, udacityKeyFromPost in

            // Was able to get a key sucessful call to Udacity
            if successPost {

                // Call to get student name using the key
                self.GetSignInUdacityWithKey (udacityKeyFromPost, completionHandler: {sucessGet, errorStringGet, studentFirstName, studentLastName, studentEmail in

                    if sucessGet {
                        if let _ = studentFirstName {
                            udacityStudent.sharedInstance.udacityStudentFirstName = studentFirstName
                        } else {
                            udacityStudent.sharedInstance.udacityStudentFirstName = studentFirstName
                        }

                        if let _ = studentLastName {
                            udacityStudent.sharedInstance.udacityStudentLastName = studentLastName
                        } else {
                            udacityStudent.sharedInstance.udacityStudentLastName = " "
                        }

                        udacityStudent.sharedInstance.udacityStudentID = studentEmail
                        
                        completionHandler(success: true,  errorString: nil  )
                    } else {
                        completionHandler(success: sucessGet,  errorString: errorStringGet )
                    }
                })
            } else {
                completionHandler(success: successPost,  errorString: errorStringPost  )
            }
        })
    }


    // Call Udacity to Sign In
    func GetSignInUdacityWithKey(key: String!, completionHandler: (successGet: Bool, errorStringGet: String?, studentFirstName: String?, studentLastName: String?, studentEmail: String?) -> Void){

        // Check if connected to internet
        let isConnectionReturnCode = isConnectedToNetwork()
        if isConnectionReturnCode == false {
            completionHandler(successGet: false, errorStringGet: "Unable to Connect to Internet!", studentFirstName: nil,  studentLastName: nil, studentEmail: nil)
        } else
        {
            // Connected, call Udacity to sign in
            taskForGETMethod(key) {result, error in

                if let error = error {
                    let errorMessage =  error.domain
                    completionHandler(successGet: false,  errorStringGet: errorMessage,  studentFirstName: nil,  studentLastName: nil, studentEmail: nil)
                } else {

                    //  Parse the student name
                    if let resultArray = result as? [String: AnyObject] {
                        if let account = resultArray["user"] as? [String: AnyObject] {
                            if let lastName = account["last_name"] as? String {
                                if let firstName = account["first_name"] as? String {
                                    if let email = account["email"] as? [String: AnyObject] {
                                        if let emailAddress = email["address"] as? String {
                                            completionHandler(successGet: true,  errorStringGet: nil, studentFirstName: firstName, studentLastName: lastName, studentEmail: emailAddress)
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Data was not correct or missing, send back error
                    completionHandler(successGet: false, errorStringGet: "Student Information Not Found", studentFirstName: nil,  studentLastName: nil, studentEmail: nil )

                }
            }

        }
    }



    // Call Udacity to Sign In
    func postSignInUdacityGetKey(emailText: String?, passwordText: String?, facebookToken: String?,  completionHandler: (success: Bool, errorString: String?, udacityKey: String?) -> Void){

        // Check if connected to internet
        let isConnectionReturnCode = isConnectedToNetwork()

        if isConnectionReturnCode == false {
            completionHandler(success: false, errorString: "Unable to Connect to Internet!", udacityKey: nil)
        } else
        {
            // Connected, call Udacity to sign in
            taskForPOSTMethod(emailText, password: passwordText, facebookToken: facebookToken) {result, error in

                // Send back errors and check data was sent correctly
                if let error = error {
                    let errorMessage =  error.domain
                    completionHandler(success: false,  errorString: errorMessage, udacityKey: nil)
                } else {

                    guard let resultArray = result as? [String: AnyObject],
                        let account = resultArray["account"] as? [String: AnyObject],
                        let key = account["key"] as? String else {
                            completionHandler(success: false,  errorString: "Account not Found", udacityKey: nil )
                            return
                    }

                    // Success
                    completionHandler(success: true,  errorString: nil, udacityKey: key )

                }
            }
        }
    }



    // Call UDACITY to delete Logout the User
    func deleteSignInUdacity(completionHandler: (success: Bool, errorString: String?) -> Void){

        // Check if connected to database
        let isConnectionReturnCode = isConnectedToNetwork()
        if isConnectionReturnCode == false {
            completionHandler(success: false, errorString: "Unable to Connect to Internet!")
        } else
        {
            // Call udacity to delete the signon
            taskForDELETEMethod() {result, error in

                if let error = error {
                    let errorMessage =  error.domain
                    if error.code == 0 {
                        completionHandler(success: true,  errorString: errorMessage)

                    } else {
                        completionHandler(success: false,  errorString: errorMessage)

                    }

                }
            }
        }
    }
}
