//
//  ViewController.swift
//  City_app
//
//  Created by Georgi Malkhasyan on 12/11/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    let autorizationStatus = CLLocationManager.authorizationStatus()
    //MARK: Radion for location
    var regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - Delegate
        mapView.delegate = self
        locationManager.delegate = self
        
        
        
        
        configureLocation()
        addDoubleTap()
    }

    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //MARK: - Add markPin on the mapView
    @objc func dropin(sender: UITapGestureRecognizer) {
        removePin()
        let touchPoint = sender.location(in: mapView)
        let touchCordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCordinate, identifire: "droppablePin")
        mapView.addAnnotation(annotation)

        let coridantRegion = MKCoordinateRegion(center: touchCordinate,  latitudinalMeters: regionRadius * 2.0,  longitudinalMeters: regionRadius * 2.0 )

        mapView.setRegion(coridantRegion, animated: true)
        
       
    }
    
    
    //MARK:  - Delete the mark on mapView
    func removePin() {
        for  annotattionn in mapView.annotations {
            mapView.removeAnnotation(annotattionn)
        }
    }
    
    
    
    //MARK: - Center location when LocationBtn is tapped
    @IBAction func MapBtnTapped(_ sender: Any) {
        if autorizationStatus == .authorizedAlways || autorizationStatus == .authorizedWhenInUse {
            centerMapOurLocation()
        }
    }
    
}


extension ViewController: MKMapViewDelegate {
    
    //MARK: - Change mapView annotation Color
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        return pinAnnotation
    }
    
    
    
    //MAKR: - Center User Location
    func centerMapOurLocation() {
        guard let cordinate = locationManager.location?.coordinate else {return}
        let coridantRegion = MKCoordinateRegion(center: cordinate, latitudinalMeters: Double(regionRadius) * 2.0, longitudinalMeters: Double(regionRadius) * 2.0 )
        mapView.setRegion(coridantRegion, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate{
    func configureLocation() {
        if autorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
            return
        }
    
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOurLocation()
    }
}
