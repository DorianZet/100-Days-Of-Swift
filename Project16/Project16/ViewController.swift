//
//  ViewController.swift
//  Project16
//
//  Created by MacBook on 22/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select map view", style: .plain, target: self, action: #selector(selectMapView))
       
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.", subtitle: "England")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", subtitle: "Norway")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", subtitle: "France")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", subtitle: "Italy")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.", subtitle: "US")
        
//        mapView.addAnnotation(london)
//        mapView.addAnnotation(oslo)
//        mapView.addAnnotation(paris)
//        mapView.addAnnotation(rome)
//        mapView.addAnnotation(washington)
//        OR:
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // The code below serves a purpose of reusing the annotation views, instead of creating them from scratch every time they are viewed on the screen. The identifier's name is not that important, as it serves purpose only for (withIdentifier:) and (reuseIdentifier:) methods. What's important here, is that the same identifier should be used in both of the methods.
        
        // In this case, once all of the 5 annotations are created, they will be reused every time they are viewed.
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView // If we typecase annotationView as MKPinAnnotationView, we can change the pin color of the annotationView.
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            print("The annotation was nil, creating a new one")
        } else {
            annotationView?.annotation = annotation
            print("Annotation reused.")
        }
        annotationView?.pinTintColor = .purple // We change the pin color to purple.
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        let placeName = capital.title
        let placeInfo = capital.info
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    // Right bar button, with which we can select how we view the map:
    @objc func selectMapView() {
    let ac = UIAlertController(title: "Select map view:", message: "", preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: mapViewStandard))
    ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: mapViewHybrid))
    ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: mapViewHybridFlyover))
    ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: mapViewSatellite))
    ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: mapViewSatelliteFlyover))
    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(ac, animated: true)
    }
    
    func mapViewStandard(action: UIAlertAction!) {
        mapView.mapType = MKMapType.standard
    }
    func mapViewHybrid(action: UIAlertAction!) {
        mapView.mapType = MKMapType.hybrid
    }
    func mapViewHybridFlyover(action: UIAlertAction!) {
        mapView.mapType = MKMapType.hybridFlyover
    }
    func mapViewSatellite(action: UIAlertAction!) {
        mapView.mapType = MKMapType.satellite
    }
    func mapViewSatelliteFlyover(action: UIAlertAction!) {
        mapView.mapType = MKMapType.satelliteFlyover
    }
    
}
    


