//
//  MainPageViewController.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 27.01.2022.
//

import UIKit

class PersonalCabinetViewController: UIViewController {
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var ridingLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    
    var userManager = UserManager()
    
    // user
    var id = -1
    var balance = 0
    var username = ""
    var email = ""
    var isRiding = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        userManager.delegate = self

        textField.delegate = self

        greetingsLabel.text = "Hello \(username.capitalized)"
        balanceLabel.text = "Your Balance is \(balance) tenge"
        emailField.text = "Your email is \(email)"
        idLabel.text = "Your user id is \(id). Name your id if you contact the managers"
        if isRiding == false {
            ridingLabel.text = "You are currently not riding a vehicle"
        } else {
            ridingLabel.text = "You are currently riding a vehicle. Be aware"
        }
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        textField.endEditing(true)
        if let myString = textField.text {
            let myInt = Int(myString) ?? -1
            
            if myInt != -1 {
                let myNewInt = balance + myInt
                userManager.updateBalance(id: id, balance: myNewInt)
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: false) // runs for 1.5 seconds and then calls updateUI
                print("2")

            } else if myInt < 0 {
                submitButton.setTitle("Input a positive integer", for: .normal)
            } else {
                submitButton.setTitle("Input an integer", for: .normal)
            }
            
            textField.text = ""
        }
    }
    
    @objc func updateUI () {
        print("1")
        userManager.getUser(id: id)
    }
}

extension PersonalCabinetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let myString = textField.text {
            let myInt = Int(myString) ?? -1
            
            if myInt != -1 {
                let myNewInt = balance + myInt
                userManager.updateBalance(id: id, balance: myNewInt)
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: false) // runs for 1.5 seconds and then calls updateUI
                print("2")
            } else if myInt < 0 {
                submitButton.setTitle("Input a positive integer", for: .normal)
            } else {
                submitButton.setTitle("Input an integer", for: .normal)
            }
            
            textField.text = ""
        }
        return true
    }
}


extension PersonalCabinetViewController: UserManagerDelegate {
    func didFailWithError(error: Error) {
        print("didfailwitherror")
        print(error)
    }
    
    func didUpdateUser(_ userManager: UserManager, user: UserModel) {
        print("I am here")
        DispatchQueue.main.async {
            self.balance = user.balance
            print("Your Balance is \(user.balance) tenge")
            self.balanceLabel.text = "Your Balance is \(user.balance) tenge"
        }
    }
}
