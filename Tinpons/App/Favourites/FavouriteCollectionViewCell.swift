//
//  FavouriteCollectionViewCell.swift
//  Tinpons
//
//  Created by Dirk Hornung on 17/7/17.
//
//

import UIKit
import MapKit

class FavouriteCollectionViewCell: UICollectionViewCell {
    
    var tinpon: Tinpon? {
        didSet {
            if let tinpon = tinpon {
                nameLabel.text = tinpon.name
                priceLabel.text = tinpon.category!+" | "+(tinpon.price?.stringValue)!+" €"
                let resizedImageUrl = "http://tinpons-userfiles-mobilehub-1827971537.s3-website-eu-west-1.amazonaws.com/300x400/"+tinpon.imgUrl!
                tinponImageView.imageFromServerURL(urlString: resizedImageUrl)
            }
        }
    }
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var descriptionStack: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tinponImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func tabMapMarker(_ sender: UIButton) {
        openMapForPlace()
    }
    
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = (tinpon?.latitude?.doubleValue)!
        let longitude: CLLocationDegrees = (tinpon?.longitude?.doubleValue)!
        
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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // add Gradient
        let mGradient = CAGradientLayer()
        mGradient.frame = self.bounds
        var colors = [CGColor]()
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor)
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor)
        colors.append(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor)
        mGradient.locations = [0, 0.3, 1]
        mGradient.startPoint = CGPoint(x: 0, y: 0.7)
        mGradient.endPoint = CGPoint(x: 0, y: 1)
        mGradient.colors = colors
        gradientView.layer.addSublayer(mGradient)
    }
}
