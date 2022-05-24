import Foundation

protocol UserManagerDelegate {
    func didUpdateUser(_ userManager: UserManager, user: UserModel)
    func didFailWithError(error: Error)
}

struct UserManager  {
    var delegate: UserManagerDelegate?

    func getUser(id: Int) -> Bool {
        guard let url =  URL(string:"http://localhost:8080/api/user/\(id)")
        else { return false }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }

            if let safeData = data {
                
                let responseJSON = try? JSONSerialization.jsonObject(with: safeData, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let id = responseJSON["id"] as? Int ?? -1
                    let balance = responseJSON["balance"] as? Int ?? 0
                    let username = responseJSON["username"] as? String ?? "nil"
                    let email = responseJSON["email"] as? String ?? "nil"
                    let user = UserModel(id: id, balance: balance, username: username, email: email)
                    self.delegate?.didUpdateUser(self, user: user)
                }
            }
        }
        task.resume()
        return false
    }
    
    func updateBalance(id: Int, balance: Int) {
        guard let url =  URL(string:"http://localhost:8080/api/user/updateBalance/\(id)/\(balance)")
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }

            if let safeData = data {
                print("updateBalanceRequest, safedata = \(safeData)")
            }
        }
        task.resume()
    }
}
