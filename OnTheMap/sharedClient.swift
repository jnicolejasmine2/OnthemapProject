//
//  sharedClient.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/28/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import SystemConfiguration

    // Check to see if there is an internet connection
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()

        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }

        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        return (isReachable && !needsConnection)
    }


//  Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(parameters: [String : AnyObject]) -> String {

        var urlVars = [String]()

        for (key, value) in parameters {
            // Make sure that it is a string value */
            let stringValue = "\(value)"

            // Add escape characters
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            // Append
            urlVars += [key + "=" + "\(escapedValue!)"]

        }
        // Return the URL
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }



/// Given raw JSON, return a usable Foundation object
func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {

    var parsedResult: AnyObject!
    do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    } catch {
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
    }

    completionHandler(result: parsedResult, error: nil)
}
