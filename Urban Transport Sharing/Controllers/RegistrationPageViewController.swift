//
//  RegistrationPageViewController.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 24.02.2022.
//

import UIKit

class RegistrationPageViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    var registrationManager = RegistrationManager()

    var usernameLocal = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "Sign up"
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        
        
        registrationManager.delegate = self

        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterToMainPage" {
            let destinationVC = segue.destination as! MainPageViewController
            destinationVC.username = usernameLocal
        }
    }
}


extension RegistrationPageViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.endEditing(true)
        usernameField.endEditing(true)
        passwordField.endEditing(true)

        print(emailField.text!)
        print(usernameField.text!)
        print(passwordField.text!)
        
        if emailField.text != nil && usernameField.text != nil && passwordField.text != nil {
            registrationManager.register(email: emailField.text!, username: usernameField.text!, password: passwordField.text!)
        }
        
        return true
    }

    
    @IBAction func authorizationPressed(_ sender: UIButton) {
        emailField.endEditing(true)
        usernameField.endEditing(true)
        passwordField.endEditing(true)

        print(emailField.text!)
        print(usernameField.text!)
        print(passwordField.text!)
        if emailField.text != nil && usernameField.text != nil && passwordField.text != nil {
            registrationManager.register(email: emailField.text!, username: usernameField.text!, password: passwordField.text!)
        }
    }
}


extension RegistrationPageViewController: RegistrationManagerDelegate {
    
    func didUpdateRegistration(_ registrationManager: RegistrationManager, registration: RegistrationModel) {
        DispatchQueue.main.async {
            if (registration.statusCode >= 200 && registration.statusCode < 300) {
                self.usernameLocal = registration.username
                self.performSegue(withIdentifier: "RegisterToMainPage", sender: self)
            } else {
                print("login not allowed")
                self.registerButton.tintColor = .red
                
                if registration.email != "nil" {
                    self.registerButton.setTitle(registration.email, for: .normal)
                } else if registration.username != "nil" {
                    if registration.username != "username is mandatory" {
                        self.registerButton.setTitle("username \(registration.username) symbols", for: .normal)
                    } else {
                        self.registerButton.setTitle(registration.username, for: .normal)
                    }
                } else if registration.password != "nil" {
                    if registration.username != "password is mandatory" {

                        self.registerButton.setTitle("password \(registration.password) symbols", for: .normal)
                    } else {
                        self.registerButton.setTitle(registration.password, for: .normal)
                    }
                } else {
                    self.registerButton.setTitle(registration.message, for: .normal)
                }
                
                
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: false) // runs for 1.5 seconds and then calls updateUI
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print("didFailWithError")
        print(error)
    }
    
    @objc func updateUI () {
        self.registerButton.tintColor = UIColor(red: 0.13, green: 0.91, blue: 0.81, alpha: 1.00)

        self.registerButton.setTitle("Register", for: .normal)
    }
}
