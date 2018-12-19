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

class MapView: UIViewController, UIGestureRecognizerDelegate {
    //
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!

    @IBOutlet weak var pullUpView: UIView!
    //
    
    var locationManager = CLLocationManager()
    
    let autorizationStatus = CLLocationManager.authorizationStatus()
    
    let regionRadious: Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    //Collection
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // MARK: - Delegate
            mapView.delegate = self
            locationManager.delegate = self
            configureLocationServices()
        
            addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource  = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        pullUpView.addSubview(collectionView!)
    }

    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate  = self
        mapView.addGestureRecognizer(doubleTap)
        
    }

        //MARK: - Add markPin on the mapView
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpiner()
        animateViewUp()
        swipeGesture()
        addSpiner()
        addProgressLbl()
        let touchPoint = sender.location(in: mapView)
        //Converting touchPoint into GPS coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        //Add annatation 
        let annotation = DroppablePin(coordinate: touchCoordinate, identifire: "droppablePin")
        mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: - Remove last Pin and add a new one
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //MARK: - Chnage annotation color
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation  is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
   
    func animateViewUp() {
        pullUpViewHeight.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.loadViewIfNeeded()
        }
    }
    
    func swipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown() {
        pullUpViewHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.loadViewIfNeeded()
        }
    }
    
    
    func addSpiner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 150)
        spinner?.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        spinner?.style = .whiteLarge
        spinner?.startAnimating()
        collectionView!.addSubview(spinner!)
    }
 
    
    func removeSpiner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    //Add progress Lbl on the pullupView
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: view.center.x - 100 , y: 175, width: 200, height: 40)
        progressLbl?.font = UIFont(name: "Avanir Next", size: 18)
        progressLbl?.textAlignment = .center
        progressLbl?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        progressLbl?.text = "12/444 pictures"
        collectionView!.addSubview(progressLbl!)
    }
    
    
    //CnterMap location when Btn is pressed
    @IBAction func centerMapBtnPressed(_ sender: Any) {
        centerMapOnUserLocation()
    }

}














   //MAKR: - Center User Location
extension MapView: MKMapViewDelegate {
    func centerMapOnUserLocation(){
        guard let cordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: cordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}



extension MapView: CLLocationManagerDelegate {
    func configureLocationServices() {
        if autorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
           return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


extension MapView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func  numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
        return cell!
    }
    
    
}
