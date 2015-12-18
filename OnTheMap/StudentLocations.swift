//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/26/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation

// Global variable to store student locations so it is shared
// by map and by list


// Global variable to store student locations so it is shared
// by map and by list
class studentLocationArrayShare   {
    var studentLocationArray: [studentLocation]  = []

    static let sharedInstance = studentLocationArrayShare()

}


// Global variable to store the student that is signed in
class udacityStudent {
    var udacityStudentFirstName: String?
    var udacityStudentLastName: String?
    var udacityStudentID: String?

    static let sharedInstance = udacityStudent()

}





