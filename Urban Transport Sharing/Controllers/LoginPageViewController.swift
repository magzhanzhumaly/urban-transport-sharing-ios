//
//  ViewController.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 27.01.2022.
//

import UIKit


class LoginPageViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var loginManager = LoginManager()
    var loginAllowed = false
    var usernameLocal = ""
    var id = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "Sign in"
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        loginManager.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToMainPage" {
            let destinationVC = segue.destination as! MainPageViewController
            destinationVC.username = usernameLocal
            destinationVC.id = id
        }
    }
}


extension LoginPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameField.endEditing(true)
        passwordField.endEditing(true)
        
        print(usernameField.text!)
        print(passwordField.text!)
        
        if let username = usernameField.text, let password = passwordField.text {
            loginManager.login(username: usernameField.text!, password: passwordField.text!)
        }
        
        return true
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        usernameField.endEditing(true)
        passwordField.endEditing(true)
        
        print(usernameField.text!)
        print(passwordField.text!)
        
        if let username = usernameField.text, let password = passwordField.text {
            loginManager.login(username: usernameField.text!, password: passwordField.text!)
        }
    }
}


extension LoginPageViewController: LoginManagerDelegate {
    func didUpdateLogin(_ loginManager: LoginManager, login: LoginModel) {
        DispatchQueue.main.async {
            if (login.statusCode >= 200 && login.statusCode < 300) {
                self.usernameLocal = login.username
                self.id = login.id
                
                self.performSegue(withIdentifier: "LoginToMainPage", sender: self)
            } else {
                print("login not allowed")
                self.loginButton.tintColor = .red
                self.loginButton.setTitle("Wrong credentials", for: .normal)
                
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: false) // runs for 1.5 seconds and then calls updateUI
            }
        }
    }

    func didFailWithError(error: Error) {
        print("didFailWithError")
        print(error)
    }
    
    @objc func updateUI () {
        self.loginButton.tintColor = UIColor(red: 0.13, green: 0.91, blue: 0.81, alpha: 1.00)

        self.loginButton.setTitle("Login", for: .normal)
    }
}
