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
    var webPageToLoad: String?
    var webPageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Capitals Map"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select map view", style: .plain, target: self, action: #selector(selectMapView))
       
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.", subtitle: "England", webpage: "en.wikipedia.org/wiki/London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", subtitle: "Norway", webpage: "en.wikipedia.org/wiki/Oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", subtitle: "France", webpage: "en.wikipedia.org/wiki/Paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", subtitle: "Italy", webpage: "en.wikipedia.org/wiki/Rome")
        let washington = Capital(title: "Washington, D.C.", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.", subtitle: "US", webpage: "en.wikipedia.org/wiki/Washington,_D.C.")
        let radom = Capital(title: "Radom", coordinate: CLLocationCoordinate2D(latitude: 51.4027, longitude: 21.1471), info: "Truly inspiring, a city of smiles, happiness and alcoholic demoralisation.", subtitle: "Poland", webpage: "en.wikipedia.org/wiki/Radom")
        
//        mapView.addAnnotation(london)
//        mapView.addAnnotation(oslo)
//        mapView.addAnnotation(paris)
//        mapView.addAnnotation(rome)
//        mapView.addAnnotation(washington)
//        OR:
        
        mapView.addAnnotations([london, oslo, paris, rome, washington, radom])

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // The code below serves a purpose of reusing the annotation views, instead of creating them from scratch every time they are viewed on the screen. The identifier's name is not that important, as it serves purpose only for (withIdentifier:) and (reuseIdentifier:) methods. What's important here, is that the same identifier should be used in both of the methods.
        // In this case, once all of the 5 annotations are created, they will be reused every time they are viewed.
        guard annotation is Capital else { return nil } // 'annotation' has to be of Capital.type, otherwise we bail out.
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView // If we typecase annotationView as MKPinAnnotationView, we can change the pin color of the annotationView.
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            print("The annotation was nil, creating a new one")
        } else {
            annotationView?.annotation = annotation // If the annotation can be reused, do it.
            print("Annotation reused.")
        }
        annotationView?.pinTintColor = .purple // We change the pin color to purple.
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        webPageToLoad = capital.webpage
        webPageTitle = capital.title
        let placeName = capital.title
        let placeInfo = capital.info
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        ac.addAction(UIAlertAction(title: "Visit website", style: .default, handler: visitWebsite))
        present(ac, animated: true)
    }
    
    func visitWebsite(action: UIAlertAction! = nil) {
        let vc = DetailViewController()
        vc.pageToLoad = webPageToLoad
        vc.title = webPageTitle
        // Fade-out animation when leaving the view:
        UIView.animate(withDuration: 0.6, animations: {
            self.view.backgroundColor = .black
            self.mapView.alpha = 0
            self.navigationController?.navigationBar.alpha = 0
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.navigationController?.pushViewController(vc, animated: false)
            self?.mapView.alpha = 1
            self?.view.backgroundColor = .white // If we didn't do this, the navBar color would be greyish-black when going back to the main view controller, because we set the view.backgroundColor = .black right before the animation and it would stay like this. Making it .white resets it color.
        }
    }
    
    // Right bar button, with which we can select how we view the map:
    @objc func selectMapView() {
    let ac = UIAlertController(title: "Select map view:", message: "", preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: mapViewStandard))
    ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: mapViewHybrid))
    ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default, handler: mapViewHybridFlyover))
    ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: mapViewSatellite))
    ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default, handler: mapViewSatelliteFlyover))
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
    


