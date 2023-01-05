//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text {
            if let password = passwordTextfield.text{
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    if let e = error{
                        self!.errorMessage.text = "login fail: \(e)"
                    } else {
                        self?.performSegue(withIdentifier: K.loginSegue, sender: self)
                    }
                }
                
                
            } else {
                passwordTextfield.placeholder = "please enter password"
            }
        } else {
            emailTextfield.placeholder = "please enter login email"
        }
    }
    
}
