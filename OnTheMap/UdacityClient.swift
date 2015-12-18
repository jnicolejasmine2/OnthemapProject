//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/21/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import SystemConfiguration 


class UdacityClient: NSObject   {

    // Constants 
    let UdacityURLSecure = "https://www.udacity.com/api/session"

    /* Shared session */
    var session: NSURLSession
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    // Call UDACITY to sign in
    func taskForPOSTMethod(email: String?, password: String?, facebookToken: String?, completionHandler: (result: AnyObject?, error: NSError? ) -> Void) -> NSURLSessionDataTask  {


        // Build the URL and configure the request
        let urlString = UdacityURLSecure
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)

        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let emailValue = email {
            if let passwordValue = password {
                request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailValue)\", \"password\": \"\(passwordValue)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            }
        } else if let facebookTokenValue = facebookToken {
            request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(facebookTokenValue);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        }

        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // Check for an error
            guard (error == nil) else {
                completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Manage the return code
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode

            // 200-299 Good, all else are error conditions
            if statusCode  < 200 || statusCode > 300  {
                if let response = response as? NSHTTPURLResponse {
                    if statusCode == 403 {
                        completionHandler(result: nil, error: NSError(domain: "Invalid Username or Password!", code: 1, userInfo: nil))
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Status code: \(response.statusCode)!", code: 1, userInfo: nil))
                    }
                } else if let response = response {
                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Response: \(response)!", code: 1, userInfo: nil))
                } else {
                    completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                }

                return
            }


            // Was there any data returned?
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Parse the data and use the data (happens in completion handler)
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

            // Parse the data into a non-JSON format
            parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }

        //Start the request
        task.resume()

        return task
    }



    // Call UDACITY to get the signed on user name 
    func taskForGETMethod(key: String!, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask  {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(key)")!)

        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in

            guard (error == nil) else {
                completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Manage the return code
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode

            // 200-299 Good, all else are error conditions
            if statusCode  < 200 || statusCode > 300  {
                if let response = response as? NSHTTPURLResponse {
                    if statusCode == 403 {
                        completionHandler(result: nil, error: NSError(domain: "Invalid Udacity Key !", code: 1, userInfo: nil))
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Status code: \(response.statusCode)!", code: 1, userInfo: nil))
                    }
                } else if let response = response {
                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Response: \(response)!", code: 1, userInfo: nil))
                } else {
                    completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                }

                return
            }


            // Was there any data returned?
            guard let data = data else {
                completionHandler(result: nil, error: NSError(domain:  "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Parse the data and use the data (happens in completion handler)
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

            // Parse the data into a non-JSON format
            parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)

        }
        task.resume()

        return task
    }



    // Call UDACITY to delete Logout the User
    func taskForDELETEMethod(completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask  {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }

        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let session = NSURLSession.sharedSession()


        let task = session.dataTaskWithRequest(request) { data, response, error in

            // Was there an error?
            guard (error == nil) else {
                completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response!", code: 1, userInfo: nil))
                return
            }

            // Check sttus code, 200-299 is good, all else are errors
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode

            if statusCode  < 200 || statusCode > 300  {
                if let response = response as? NSHTTPURLResponse {

                    completionHandler(result: nil, error: NSError(domain: "Your request returned an invalid response! Status code: \(response.statusCode)!", code: 1, userInfo: nil))
                }
            } else {
                completionHandler(result: nil, error: NSError(domain: "You are signed out!", code: 0, userInfo: nil))
            }

        }
        task.resume()

        return task
    }


    // Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

