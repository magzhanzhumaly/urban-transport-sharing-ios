//
//  InitialPageViewController.swift
//  Urban Transport Sharing
//
//  Created by Magzhan Zhumaly on 21.03.2022.
//

import UIKit

class WelcomePageViewController: UIViewController {
  
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "Urban\nTransport\nSharing"
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
                // code writen here will be triggered here every time interval
            }
            charIndex += 1
        }
    }
}

/*
 extension MKMapView {
 func centerLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
 let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
 setRegion(coordinateRegion, animated: true)
 }
 }
 */
