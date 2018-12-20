//
//  PopVC.swift
//  City_app
//
//  Created by Georgi Malkhasyan on 12/19/18.
//  Copyright © 2018 Adamyan. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage?
    
    //Function to get indexPath row image 
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        popImageView.image = passedImage
        
        addDoubleTap()
        
    }
    
    //MARK: - AddDouble tap to dismiss PopVc
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    
   @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }


}
