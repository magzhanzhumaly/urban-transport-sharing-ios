import Foundation
import CoreLocation

protocol TransportManagerDelegate {
    func didUpdateTransport(_ transportManager: TransportManager, transport: TransportModel)
    func didFailWithError(error: Error)
}


struct TransportManager  {
    var delegate: TransportManagerDelegate?

    func getTransport() {
        guard let url =  URL(string:"http://localhost:8080/api/transport")
        else { return }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }

            if let safeData = data {
                let transports: [TransportData] = try! JSONDecoder().decode([TransportData].self, from: safeData)
                print("transports.count = \(transports.count)") // Prints: 5
                for transport in transports {
//                    print("transport = \(transport)")
                    let transportModel = TransportModel(id: transport.id, latitude: transport.latitude, longitude: transport.longitude, type: transport.type, brand: transport.brand)
                    self.delegate?.didUpdateTransport(self, transport: transportModel)
//                    print("delegated")
                }
            }
        }
        task.resume()
    }
    
    func deleteTransport(_ id: Int) {
        guard let url =  URL(string:"http://localhost:8080/api/transport/delete/\(id)")
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }

            if let safeData = data {
                print("delete, safedata = \(safeData)")
            }
        }
        task.resume()
    }
    
    func moveRequest(id: String, latitude: String, longitude: String) -> Bool {
        guard let url =  URL(string:"http://localhost:8080/api/transport/move")
        else { return false }
        
        let session = URLSession(configuration: .default)
        
        let body: [String: String] = ["id": id, "latitude": latitude, "longitude": longitude]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data {
                print("moveRequest, safedata = \(safeData)")
            }
        }
        task.resume()
        return false
    }
    
    func reserveRequest(_ id: Int) {
        guard let url =  URL(string:"http://localhost:8080/api/transport/reserve/\(id)")
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }

            if let safeData = data {
                print("reserveRequest, safedata = \(safeData)")
            }
        }
        task.resume()
    }

}
