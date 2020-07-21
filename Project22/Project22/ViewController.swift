//
//  ViewController.swift
//  Project22
//
//  Created by MacBook on 07/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var beaconLabel: UILabel!
    @IBOutlet var circle: UIImageView!
    
    var locationManager: CLLocationManager?
   
    var isDetectedE = false
    var isDetectedF = false
    
    var scanStoppedWhenUnknown = false
    var scanStartedWhenUnknown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        circle.layer.zPosition = -1
        
        beaconLabel.textAlignment = .center
        
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12, options: [], animations: {
            self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        })
        view.backgroundColor = .gray
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("App launched, scanning started")
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        // Scanning for ID ending with "E":
        let uuidE = UUID(uuidString: "B0702880-A295-A8AB-F734-031A98A512DE")!
        let beaconRegionE = CLBeaconRegion(uuid: uuidE, major: 123, minor: 456, identifier: "MyBeaconE")
        let beaconRegionConstraintsE = CLBeaconIdentityConstraint(uuid: uuidE, major: 123, minor: 456)
        
        locationManager?.startMonitoring(for: beaconRegionE)
        locationManager?.startRangingBeacons(satisfying: beaconRegionConstraintsE)
        
        // Scanning for ID ending with "F":
        let uuidF = UUID(uuidString: "B0702880-A295-A8AB-F734-031A98A512DF")!
        let beaconRegionF = CLBeaconRegion(uuid: uuidF, major: 123, minor: 456, identifier: "MyBeaconF")
        let beaconRegionConstraintsF = CLBeaconIdentityConstraint(uuid: uuidF, major: 123, minor: 456)
        
        locationManager?.startMonitoring(for: beaconRegionF)
        locationManager?.startRangingBeacons(satisfying: beaconRegionConstraintsF)
    }
    
    func stopScanning(){
        stopScanningE()
        stopScanningF()
    }
    
    func stopScanningE() {
        let uuidE = UUID(uuidString: "B0702880-A295-A8AB-F734-031A98A512DE")!
        let beaconRegionE = CLBeaconRegion(uuid: uuidE, major: 123, minor: 456, identifier: "MyBeaconE")
        let beaconRegionConstraintsE = CLBeaconIdentityConstraint(uuid: uuidE, major: 123, minor: 456)
        
        locationManager?.stopMonitoring(for: beaconRegionE)
        locationManager?.stopRangingBeacons(satisfying: beaconRegionConstraintsE)
    }
    
    func stopScanningF() {
        let uuidF = UUID(uuidString: "B0702880-A295-A8AB-F734-031A98A512DF")!
        let beaconRegionF = CLBeaconRegion(uuid: uuidF, major: 123, minor: 456, identifier: "MyBeaconF")
        let beaconRegionConstraintsF = CLBeaconIdentityConstraint(uuid: uuidF, major: 123, minor: 456)
        
        locationManager?.stopMonitoring(for: beaconRegionF)
        locationManager?.stopRangingBeacons(satisfying: beaconRegionConstraintsF)
    }
    
    func update(distance: CLProximity) {
        
        switch distance {
            
        case .far:
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12, options: [], animations: {
                self.circle.transform = CGAffineTransform(scaleX: 1.7, y: 1.7) // scales the imageView x2.
            })
                
        case .near:
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12, options: [], animations: {
                self.circle.transform = CGAffineTransform(scaleX: 1, y: 1) // scales the imageView x2.
            })
                
        case .immediate:
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = .red
                    self.distanceReading.text = "RIGHT HERE"
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12, options: [], animations: {
                self.circle.transform = CGAffineTransform(scaleX: 0.03, y: 0.03) // scales the imageView x2.
            })
                
        case .unknown:
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.beaconLabel.text = ""
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001) // scales the imageView x2.
            })
            stopScanning()
            print("Scanning stopped (UNKNOWN)")
            startScanning()
            print("Scanning started (UNKNOWN)")
                
        @unknown default:
            UIView.animate(withDuration: 1) {
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        if let beacon = beacons.first {
            if beacons.first?.uuid.uuidString == "B0702880-A295-A8AB-F734-031A98A512DE" {
                beaconLabel.text = "Tracking beacon: \"MyBeacon E\""
                
                stopScanningF()
                
                if isDetectedE == false {
                        let ac = UIAlertController(title: "iBeacon found", message: "Tracking beacon: \"MyBeacon E\"", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                        isDetectedE = true
                }
            }
            
            if beacons.first?.uuid.uuidString == "B0702880-A295-A8AB-F734-031A98A512DF" {
                beaconLabel.text = "Tracking beacon: \"MyBeacon F\""
                
                stopScanningE()
                
                if isDetectedF == false {
                        let ac = UIAlertController(title: "iBeacon found", message: "Tracking beacon: \"MyBeacon F\"", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                        isDetectedF = true
                }
            }
            
            // Here we can add another beacons (if we have any other to be found):
//            if beacons.first?.uuid.uuidString == "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" {
//                if isDetected == false {
//                        let ac = UIAlertController(title: "iBeacon found", message: "Tracking beacon: \"HereWePutBeaconIdentifierForTheAboveUUIDString\"", preferredStyle: .alert)
//                        ac.addAction(UIAlertAction(title: "OK", style: .default))
//                        present(ac, animated: true)
//                        isDetected = true
//                }
//            }
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

}
