//
//  CustomOverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/27/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import MapKit

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"
private let overlayFavouriteImageName = "kolodaFavouriteOverlay"

class CustomOverlayView: OverlayView {
    
    var tinpon: Tinpon? {
        didSet {
            title.text = tinpon?.name
            priceLabel.text = (tinpon?.category)!+" | "+String(describing: (tinpon?.price)!)+" €"
            let resizedImageUrl = "http://tinpons-userfiles-mobilehub-1827971537.s3-website-eu-west-1.amazonaws.com/300x400/"+(tinpon?.imgUrl)!
            image.imageFromServerURL(urlString: resizedImageUrl)
        }
    }
    
    @IBOutlet weak var descriptionStack: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapMarkerButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
    }()
    
    @IBAction func tabMapMarkerButton(_ sender: UIButton) {
        openMapForPlace()
    }
    
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = (tinpon?.latitude)!
        let longitude: CLLocationDegrees = (tinpon?.longitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = tinpon?.name
        mapItem.openInMaps(launchOptions: options)
    }
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            case .down? :
                overlayImageView.image = UIImage(named: overlayFavouriteImageName)
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // round corner
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        // add Gradient
        let mGradient = CAGradientLayer()
        mGradient.frame = self.bounds
        var colors = [CGColor]()
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor)
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor)
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor)
        mGradient.locations = [0, 0.2, 1]
        mGradient.startPoint = CGPoint(x: 0, y: 0.45)
        mGradient.endPoint = CGPoint(x: 0, y: 1)
        mGradient.colors = colors
        self.layer.addSublayer(mGradient)
        

        self.bringSubview(toFront: descriptionStack)
    }
    
}
