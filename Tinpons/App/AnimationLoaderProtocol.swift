//
//  LoaderProtocol.swift
//  Tinpons
//
//  Created by Dirk Hornung on 19/7/17.
//
//

import Foundation
import UIKit

protocol LoadingAnimationProtocol: class {
    var loadingAnimationView: UIView! { get set }
    var loadingAnimationOverlay: UIView! {get set}
    var loadingAnimationIndicator: UIActivityIndicatorView! { get set } //UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
}

extension LoadingAnimationProtocol {
    
    func startLoadingAnimation() {
        loadingAnimationOverlay = UIView(frame: loadingAnimationView.frame)
        loadingAnimationOverlay.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loadingAnimationOverlay.alpha = 0.7
        loadingAnimationView.addSubview(loadingAnimationOverlay)
        
        // Set up activity indicator
        loadingAnimationIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingAnimationIndicator.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        loadingAnimationIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        loadingAnimationIndicator.center = loadingAnimationView.center
        loadingAnimationView.addSubview(loadingAnimationIndicator)
        loadingAnimationIndicator.bringSubview(toFront: loadingAnimationView)
        loadingAnimationIndicator.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopLoadingAnimation() {
        loadingAnimationIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        loadingAnimationOverlay.removeFromSuperview()
    }
    
}
