//
//  Meme.swift
//  MemeMe
//
//  Created by Jeanne Nicole Byers on 8/22/15.
//  Copyright (c) 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit

struct studentLocation {

    var firstName: String?
    var lastName: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?

    init(parsedStudentLocation: [String:AnyObject]) {

        firstName = parsedStudentLocation["firstName"] as? String
        lastName = parsedStudentLocation["lastName"] as? String
        mediaURL = parsedStudentLocation["mediaURL"] as? String
        latitude = parsedStudentLocation["latitude"] as? Double
        longitude = parsedStudentLocation["longitude"] as? Double

        // Default first, last names and URLS in case of problems
        // with students getting bad student information in the
        // database
        if firstName == nil {
            firstName = " "
        }

        if lastName == nil {
            lastName = " "
        }

        if mediaURL ==  nil {
            mediaURL = "https://www.Udacity.com"
        }

    }


    // Given an array of dictionaries, convert them to an array of studentLocation objects */
    static func studentLocationsFromResults(results: [[String : AnyObject]]) -> [studentLocation] {

        var studentLocations = [studentLocation]()

        for result in results {
            studentLocations.append(studentLocation(parsedStudentLocation: result))
        }

        return studentLocations
    }


    // Given an array of dictionaries, convert them to an array of studentLocation objects */
    static func studentLocationsIndividual(parsedStudentLocation: [String : AnyObject]) -> studentLocation {

        let newStudentLocation = studentLocation(parsedStudentLocation: parsedStudentLocation)

        return newStudentLocation
    }
}
