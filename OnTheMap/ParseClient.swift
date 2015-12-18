//
//  ParseCLient.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/25/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import SystemConfiguration


class ParseClient: NSObject   {

    // Constants
    let ParseURLSecure = "https://api.parse.com/1/classes/StudentLocation"


    var session: NSURLSession
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }


    func taskForGETMethod( parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask  {


        // Build the URL and configure the request
        let urlString = ParseURLSecure + escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)

        request.HTTPMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        let session = NSURLSession.sharedSession()

        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            // Was there an error?
            guard (error == nil) else {
                completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Manage the return code
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode

            if statusCode  < 200 || statusCode > 300  {
                if let response = response as? NSHTTPURLResponse {

                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Status code: \(response.statusCode)!", code: 1, userInfo: nil))


                } else if let response = response {

                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Response: \(response)!", code: 1, userInfo: nil))

                } else {
                    completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                }
                return
            }

            // Was there any data returned?
            guard let data = data else {
                 completionHandler(result: nil, error: NSError(domain:  "Student not found", code: 1, userInfo: nil))
                return
            }

            // Parse the data and use the data (happens in completion handler)
            parseJSONWithCompletionHandler(data, completionHandler: completionHandler)

        }

        // Start the request
        task.resume()

        return task
    }




    func taskForPUTandPOSTMethod(method: String!, URLObjectID: String?, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask  {

        // Build the URL and configure the request
        var urlString: String?

        if method == "POST" {
            urlString = ParseURLSecure
        } else if method == "PUT" {
            urlString = ParseURLSecure + "/" + URLObjectID!
        }

        let url = NSURL(string: urlString!)!
        let request = NSMutableURLRequest(URL: url)

        if method == "POST" {
            request.HTTPMethod = "POST"
        } else if method == "PUT" {
            request.HTTPMethod = "PUT"
        }

        // Add values needed for interface
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add the JSON data to be sent
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }

        let session = NSURLSession.sharedSession()

        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            // Was there an error?
            guard (error == nil) else {
                completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Manage the return code
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode

            if statusCode  < 200 || statusCode > 300  {
                if let response = response as? NSHTTPURLResponse {

                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Status code: \(response.statusCode)!", code: 1, userInfo: nil))

                } else {

                    completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))

                }

                return
            }

            // Was there any data returned?
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain:  "Student not found", code: 1, userInfo: nil))
                return
            }

            // Parse the data and use the data (happens in completion handler)
            parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }

        // Start the request
        task.resume()

        return task
    }


    // Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }

}

