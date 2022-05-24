//
//  MainPageViewController.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 27.01.2022.
//

import UIKit

import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapKit

import CoreLocation


class MainPageViewController: UIViewController {
    
    // rental view
    @IBOutlet weak var transportImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rentButton: UIButton!
    @IBOutlet weak var rentalView: UIView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    
    // controls view
    @IBOutlet weak var controlsView: UIView!
    
    // close transports view
    @IBOutlet weak var closeTransportsView: UIView!
    
    @IBOutlet weak var imageCT1: UIImageView!
    @IBOutlet weak var imageCT2: UIImageView!
    @IBOutlet weak var imageCT3: UIImageView!
    
    @IBOutlet weak var typeCT1: UILabel!
    @IBOutlet weak var typeCT2: UILabel!
    @IBOutlet weak var typeCT3: UILabel!
    
    
    @IBOutlet weak var distanceCT1: UILabel!
    @IBOutlet weak var distanceCT2: UILabel!
    @IBOutlet weak var distanceCT3: UILabel!
    
    // vars
    var mapView: MapView!
    
    var transportManager = TransportManager()
    let locationManager = CLLocationManager()
    var userManager = UserManager()
    var pointAnnotationManager: PointAnnotationManager? = nil

    var transports: [TransportModel] = []
    var myDictionary : [Int : String] = [:]
    var distances : [Int : Double] = [:]
    
    var userLocation = CLLocationCoordinate2D(latitude: 51.089858, longitude: 71.402174)
    var temp: PointAnnotation? = nil
    var myInt = 0
    var idx = 1
    var startMoving = false
    var lastCarDistance = 10000.0

    // user
    var id = -1
    var balance = 0
    var username = ""
    var email = ""
    
    
    var start = DispatchTime.now()
    
    // VIEWDIDLOAD
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let options = MapInitOptions(cameraOptions: CameraOptions(center: userLocation, zoom: 13.5, bearing: 12.7))
        
        transportManager.delegate = self
        transportManager.getTransport() // first time getting all transports
        
        userManager.delegate = self
        userManager.getUser(id: id)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        getCurrentLocation() // starts getting location. inner function
        
        pointAnnotationManager = self.mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager!.delegate = self
        
        view.addSubview(mapView)
        mapView.location.options.puckType = .puck2D()
        
        view.bringSubviewToFront(closeTransportsView)
        view.bringSubviewToFront(controlsView)
        view.bringSubviewToFront(rentalView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToPersonalCabinet" {
            let destinationVC = segue.destination as! PersonalCabinetViewController
            destinationVC.id = id
            destinationVC.balance = balance
            destinationVC.username = username
            destinationVC.email = email
            destinationVC.isRiding = startMoving
        }
    }
    
    @IBAction func personalCabinetTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SegueToPersonalCabinet", sender: self)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        rentalView.isHidden = true
    }
    
    
    // RENTAL VIEW
    
    @IBAction func rentPressed(_ sender: UIButton) {
        
        
        if balance < 50 {
            rentButton.tintColor = .red
            calculateDistance(location1: userLocation, transport: transports[idx])
            if lastCarDistance > 1500 {
                rentButton.setTitle("You are too far from the car", for: .normal)
                rentButton.tintColor = .red
            } else {
                rentButton.setTitle("You don't have enough money", for: .normal)
            }
        } else {
            if cancelButton.isHidden == false {
                
                // RESERVE
                
                calculateDistance(location1: userLocation, transport: transports[idx])
                
                if lastCarDistance > 1500 {
                    rentButton.setTitle("You are too far from the car", for: .normal)
                    rentButton.tintColor = .red
                } else {
                    start = DispatchTime.now()
                    
                    cancelButton.isHidden = true
                    rentButton.tintColor = .red
                    rentButton.setTitle("Stop Rental", for: .normal)
                    
                    startMoving = true
                    pointAnnotationManager!.annotations[idx] = PointAnnotation(coordinate: userLocation)
                }
            } else {
                // UNRESERVE
                
                var end = DispatchTime.now()
                
                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                print("Time was \(timeInterval) seconds")
                
                let fee = Int(timeInterval) * 50
                
                userManager.updateBalance(id: id, balance: balance - fee)
                
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: false) // runs for 1.5 seconds and then calls updateUI
                
                
                rentalView.isHidden = true
                
                startMoving = false
                
                transportManager.moveRequest(id: "\(idx)", latitude: "\(userLocation.latitude)", longitude: "\(userLocation.longitude)")
            }
        }
    }
    
    @objc func updateUI () {
        print("1")
        userManager.getUser(id: id)
    }
    
    
    
    // DRAW
    
    func draw(transport: TransportModel) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(transport.latitude) ?? 0.0, longitude: Double(transport.longitude) ?? 0.0)
        
        var customPointAnnotation = PointAnnotation(coordinate: coordinate)
        
        if transport.type == 2 {
            customPointAnnotation.image = .init(image: UIImage(named: "car")!, name: "\(transport.id)")
        } else if transport.type == 3 {
            customPointAnnotation.image = .init(image: UIImage(named: "truck")!, name: "\(transport.id)")
        } else {
            customPointAnnotation.image = .init(image: UIImage(named: "scooter")!, name: "\(transport.id)")
        }
        
        pointAnnotationManager!.annotations.append(customPointAnnotation)
        myDictionary[myInt] = customPointAnnotation.id
        
        myInt += 1
        if myInt >= transports.count {
            myInt = transports.count - 1
        }
    }
    
    
    // NOT NEEDED
    
    func calculateDistance(location1: CLLocationCoordinate2D, transport: TransportModel) {
        let latitude = (transport.latitude as NSString).doubleValue
        let longitude = (transport.longitude as NSString).doubleValue
        
        let location2 = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let r = 6371000
        let fi1 = location1.latitude * Double.pi / 180
        let fi2 = location2.latitude * Double.pi / 180
        let deltaFi = (location2.latitude - location1.latitude) * Double.pi / 180
        let deltaLambda = (location2.longitude - location1.longitude) * Double.pi / 180
        
        let a = sin(deltaFi/2) * sin(deltaFi/2) + cos(fi1) * cos(fi2) * sin(deltaLambda/2) * sin(deltaLambda/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let d = Double(r) * c
        
        print("distance of user and transport \(transport.id) = \(d)")
        
        distances[transport.id] = d
        
        lastCarDistance = d
    }
    
    func getCurrentLocation() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.cameraState.zoom + 0.7))
    }
    
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: mapView.cameraState.zoom - 0.7))
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        mapView.mapboxMap.setCamera(to: CameraOptions(center: userLocation, zoom: 13.5))
    }
    
    @IBAction func closeTransportsTapped(_ sender: UIButton) {
        
        for transport in transports {
            self.calculateDistance(location1: self.userLocation, transport: transport)
        }
        
        let sortedTwo = distances.sorted {
            return $0.1 < $1.1
        }
        
        // close transport 1
        
        if transports[sortedTwo[0].key - 1].type == 2 {
            imageCT1.image = UIImage(named: "car")
        } else if transports[sortedTwo[0].key - 1].type == 3 {
            imageCT1.image = UIImage(named: "truck")
        } else  {
            imageCT1.image = UIImage(named: "scooter")
        }
        typeCT1.text = transports[sortedTwo[0].key - 1].brand
        distanceCT1.text = "\(Int(sortedTwo[0].value))"
        
        // close transport 2
        if (transports[sortedTwo[1].key - 1].type == 2) {
            imageCT2.image = UIImage(named: "car")
        } else if transports[sortedTwo[1].key - 1].type == 3 {
            imageCT2.image = UIImage(named: "truck")
        } else  {
            imageCT2.image = UIImage(named: "scooter")
        }
        typeCT2.text = transports[sortedTwo[1].key - 1].brand
        distanceCT2.text = "\(Int(sortedTwo[1].value))"
        
        // close transport 3
        if (transports[sortedTwo[2].key - 1].type == 2) {
            imageCT3.image = UIImage(named: "car")
        } else if transports[sortedTwo[2].key - 1].type == 3 {
            imageCT3.image = UIImage(named: "truck")
        } else  {
            imageCT3.image = UIImage(named: "scooter")
        }
        typeCT3.text = transports[sortedTwo[2].key - 1].brand
        
        closeTransportsView.isHidden = !closeTransportsView.isHidden
    }
}

extension MainPageViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // Handle changes if location permissions
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            userLocation.latitude = latitude
            userLocation.longitude = longitude
            if startMoving {
                var end = DispatchTime.now()
                
                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                print("Time was \(Int(timeInterval)) seconds")
                
                
                if transports[idx].id == 7 {
                    rentButton.setTitle("Your fee is \(Int(timeInterval) * 75). Tap to stop rental", for: .normal)
                } else {
                    rentButton.setTitle("Your fee is \(Int(timeInterval) * 50). Tap to stop rental", for: .normal)
                }
                pointAnnotationManager!.annotations[idx] = PointAnnotation(coordinate: userLocation)
                pointAnnotationManager!.annotations[idx].image = .init(image: UIImage(named: "scooter")!, name: "\(2)")
                
            }
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
    }
}



// TRANSPORT DELEGATE

extension MainPageViewController: TransportManagerDelegate {
    func didUpdateTransport(_ transportManager: TransportManager, transport: TransportModel) {
        
        DispatchQueue.main.async {  // if this transport doesn't exist
            let index = self.transports.firstIndex(of: transport)
                self.transports.append(transport)
                self.calculateDistance(location1: self.userLocation, transport: transport)
                self.draw(transport: transport)
        }
    }
    
    func didFailWithError(error: Error) {
        print("didFailWithError")
        print(error)
    }
}


// ANNOTATION MANAGER

extension MainPageViewController: AnnotationInteractionDelegate {
    
    public func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        
        userManager.getUser(id: id)

        rentalView.isHidden = false
        cancelButton.isHidden = false
        rentButton.tintColor = UIColor(red: 0.13, green: 0.91, blue: 0.81, alpha: 1.00)
        
        let annotation = annotations[0]
        let myID = annotation.id // id of annotation for deletion.
        
        if let idx = pointAnnotationManager!.annotations.firstIndex(where: { $0.id == myID }) {
            
            print("idx = \(idx)")
            self.idx = idx
            
            let pricePerMinute = 50 * transports[idx].type
            
            if transports[idx].type == 3 {
                transportImageView.image = UIImage(named: "truck")
                typeLabel.text = "Truck"
                rentButton.setTitle("Rent for \(pricePerMinute) tenge per minute", for: .normal)
            } else if transports[idx].type == 2 {
                transportImageView.image = UIImage(named: "car")
                typeLabel.text = "Car"
                rentButton.setTitle("Rent for \(pricePerMinute) tenge per minute", for: .normal)
            } else {
                transportImageView.image = UIImage(named: "scooter")
                typeLabel.text = "Scooter"
                rentButton.setTitle("Rent for \(pricePerMinute) tenge per minute", for: .normal)
                
                if transports[idx].id == 7 {
                    rentButton.setTitle("Rent for \(75) tenge per minute", for: .normal)
                } else {
                    rentButton.setTitle("Rent for \(pricePerMinute) tenge per minute", for: .normal)
                }

            }
            print("tranport.idx = \(transports[idx])")
            brandLabel.text = transports[idx].brand
            idLabel.text = myID
        }
    }
}



extension MainPageViewController: UserManagerDelegate {
    func didUpdateUser(_ userManager: UserManager, user: UserModel) {
        DispatchQueue.main.async {
            self.id = user.id
            self.balance = user.balance
            self.username = user.username
            self.email = user.email
        }
    }
}
