//
//  TextDelegate.swift
//  OnTheMap
//
//  Created by Jeanne Nicole Byers on 11/21/15.
//  Copyright © 2015 Jeanne Nicole Byers. All rights reserved.
//

import Foundation
import UIKit

class TextDelegate: NSObject, UITextFieldDelegate {

    // Clear text field before accepting new text
    func textFieldDidBeginEditing(textField: UITextField) {

        if textField.text == "Email" {
            textField.text = ""
        }

        if textField.text == "Password" {
            textField.text = ""
        }

        if textField.text == "Address" {
            textField.text = ""
        }
    }



    // Allows the keyboard to be closed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


