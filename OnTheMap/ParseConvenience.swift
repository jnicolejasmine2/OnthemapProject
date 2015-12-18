//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/25/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit

extension ParseClient  {


    // Get 100 student entries to present on map and list
    func postGetStudentLocations( completionHandler: (success: Bool, errorString: String?) -> Void){

        // Parameters to limit the number of students and to sort by most recent first
        let parameters  = ["limit": 100,
                        "order": "-updatedAt"

        ]

        // Check if connected to database
        let isConnectionReturnCode = isConnectedToNetwork()

        if isConnectionReturnCode == false {
            completionHandler(success: false, errorString: "Unable to Connect to Internet!")
        } else
        {
            taskForGETMethod(parameters) {result, error in

                // Send the desired value(s) to completion handler
                if let error = error {
                    let errorMessage =  error.domain
                    completionHandler(success: false,  errorString: errorMessage)
                } else {

                    // Success call to Parse site
                    if let results = result["results"] as? [[String : AnyObject]]  {

                        // Results are now in array format, save in global variable for use later
                        studentLocationArrayShare.sharedInstance.studentLocationArray = studentLocation.studentLocationsFromResults(results)

                        // Verify the studentLocation array  has one or more entries
                        let count = studentLocationArrayShare.sharedInstance.studentLocationArray.count
                        if count == 0 {
                            completionHandler(success: false, errorString: "Could Not Access Student Location Information!")
                        } else {
                            completionHandler(success: true, errorString: "Students Available!")

                        }
                    }
                }
            }
        }
    }




    // Post the student information
    func PUTPOSTStudentLocation(jsonBody: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {

        // Check if connected to database
        let isConnectionReturnCode = isConnectedToNetwork()
        if isConnectionReturnCode == false {
            completionHandler(success: false, errorString: "Unable to Connect to Internet!")
        } else {

            var method: String?
            var URLObjectID: String?
            GetCurrentStudentLocation( {successGet, errorStringGet, objectID in

                // If sucess is true, then the student was found and we should do a PUT
                if let _ = errorStringGet {
                    completionHandler(success: false,  errorString: errorStringGet)
                } else if successGet {
                        method = "PUT"
                        URLObjectID = objectID

                    } else  {
                        method = "POST"
                        URLObjectID = nil
                    }


                 //func taskForPUTandPOSTMethod(method: String!, parameters: AnyObject?, jsonBody: [String: AnyObject],
                self.taskForPUTandPOSTMethod (method, URLObjectID: URLObjectID, jsonBody: jsonBody) {result, error in

                    // Send the desired value(s) to completion handler
                    if let error = error {
                        let errorMessage =  error.domain
                        completionHandler(success: false,  errorString: errorMessage)
                    } else {
                        completionHandler(success: true,  errorString: nil)
                    }
                }
            })
        }
    }



    // Check to see if student is already in the database
    func GetCurrentStudentLocation( completionHandler: (success: Bool, errorString: String?, objectID: String?) -> Void){

        let uniqueIDWhereStatement = "{\"uniqueKey\":\"\(udacityStudent.sharedInstance.udacityStudentID!)\"}"
        let parameters  = ["where": uniqueIDWhereStatement]

        // Check if connected to database
        let isConnectionReturnCode = isConnectedToNetwork()

        if isConnectionReturnCode == false {
            completionHandler(success: false, errorString: "Unable to Connect to Internet!", objectID: nil)
        } else  {
            taskForGETMethod(parameters) {result, error in

                // Send the desired value(s) to completion handler
                if let error = error {
                    let errorMessage =  error.domain
                    completionHandler(success: false,  errorString: errorMessage, objectID: nil)
                    return
                } else if let _ = result {
                    // Parse the ObjectID
                    if let resultArray = result as? [String: AnyObject] {
                        if  let resultDictionary = resultArray["results"] as? [[String: AnyObject]] {
                            let resultDictionary2 = resultDictionary[0]
                            if let objectIDValue = resultDictionary2["objectId"] as? String {

                                completionHandler(success: true, errorString: nil, objectID: objectIDValue)
                                return
                            }

                        }

                    }

                }
                // could not find or parse Object ID
                completionHandler(success: false, errorString: "Student was Not Found !", objectID: nil)

            }
        }
    }
}
