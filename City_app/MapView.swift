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
import Alamofire
import AlamofireImage


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
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    
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
        removeProgressLbl()
        cancelAllSessions()
        animateViewUp()
        swipeGesture()
        addSpiner()
        addProgressLbl()
        
        imageArray = []
        imageUrlArray = []
        
        self.collectionView?.reloadData()
        
        let touchPoint = sender.location(in: mapView)
        //Converting touchPoint into GPS coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        //Add annatation 
        let annotation = DroppablePin(coordinate: touchCoordinate, identifire: "droppablePin")
        mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImage(handler: { (finished) in
                    if  finished {
                        //hide spinner
                        self.removeSpiner()
                        //hide label
                        self.removeProgressLbl()
                        // reload collectionView
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    //MARK: - Remove last Pin and add a new one
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    //MARK: Using Alamofire to download URLS
    func retrieveUrls(forAnnotation annotations: DroppablePin, handler: @escaping(_ status: Bool) -> () ) {
        
        Alamofire.request(flickerUrl(forApiKey: apiKey, withAnnotation: annotations, numberPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImage(handler: @escaping (_ status : Bool) -> ()) {
  
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 Images Downloading"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    
    //Using this function we just canceled all of the sessions that we need.
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, dowloadData) in
            sessionDataTask.forEach({$0.cancel()})
            dowloadData.forEach({$0.cancel()})
            
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
        cancelAllSessions()
        pullUpViewHeight.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.loadViewIfNeeded()
        }
    }
    
    //Add spinder function
    func addSpiner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 150)
        spinner?.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        spinner?.style = .whiteLarge
        spinner?.startAnimating()
        collectionView!.addSubview(spinner!)
    }
 
    //Remove Spinner function
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
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
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
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell () }
        let imageIndex = imageArray[indexPath.row]
        let cellImage = UIImageView(image: imageIndex)
        cell.addSubview(cellImage)
        return cell
    }
    
    
}
