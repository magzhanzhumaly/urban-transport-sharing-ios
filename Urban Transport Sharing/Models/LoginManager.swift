import Foundation

protocol LoginManagerDelegate {
    func didUpdateLogin(_ loginManager: LoginManager, login: LoginModel)
    func didFailWithError(error: Error)
//    func getStatus() -> Bool
}


struct LoginManager  {
    
    var resp = 400
    var delegate: LoginManagerDelegate?
    var username = ""
    
    func getResponseValue() -> Int {
        return resp
    }
    
    func getUsername() -> String {
        return username
    }
    
    func login(username: String, password: String) -> Bool {
        guard let url =  URL(string:"http://localhost:8080/api/auth/signin")
        else { return false }
        
        let session = URLSession(configuration: .default)
        
        let body: [String: String] = ["password": password, "username": username]
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
                    let id = responseJSON["id"] as? Int ?? -1
                    let email = responseJSON["email"] as? String ?? "nil"
                    let roles = responseJSON["roles"] as? [String] ?? ["nil"]
                    let statusCode = responseJSON["statusCode"] as? Int ?? -1
                    let type = responseJSON["type"] as? StringLiteralType ?? "nil"
                    let token = responseJSON["token"] as? String ?? "nil"
                    let username = responseJSON["username"] as? String ?? "nil"
                    
                    let login = LoginModel(message: message, id: id, email: email, roles: roles, statusCode: statusCode, type: type, token: token, username: username)
                    self.delegate?.didUpdateLogin(self, login: login)
                }
            }
        }
        task.resume()
        return false
    }
}
