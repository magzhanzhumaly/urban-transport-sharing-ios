//
//  RegistrationManager.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 03.03.2022.
//

import Foundation

protocol RegistrationManagerDelegate {
    func didUpdateRegistration(_ registrationManager: RegistrationManager, registration: RegistrationModel)
    func didFailWithError(error: Error)
}

struct RegistrationManager  {
    
    var resp = 400
    var delegate: RegistrationManagerDelegate?
    
    func getResponseValue() -> Int {
        return resp
    }
    
    func register(email: String, username: String, password: String) -> Bool {
        
        guard let url =  URL(string:"http://localhost:8080/api/auth/signup")
        else { return false }
        
        let session = URLSession(configuration: .default)
        
        let body: [String: Any] = ["email": email, "password": password, "role": ["user"], "username": username]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data {
                
                let responseJSON = try? JSONSerialization.jsonObject(with: safeData, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    
                    let message = responseJSON["message"] as? String ?? "nil"
                    let statusCode = responseJSON["statusCode"] as? Int ?? -1
                    let username = responseJSON["username"] as? String ?? "nil"
                    let email = responseJSON["email"] as? String ?? "nil"
                    let password = responseJSON["password"] as? String ?? "nil"
                    
                    let registration = RegistrationModel(message: message, statusCode: statusCode, username: username, email: email, password: password)
                    self.delegate?.didUpdateRegistration(self, registration: registration)
                }
            }
        }
        task.resume()
        return false
    }
}
