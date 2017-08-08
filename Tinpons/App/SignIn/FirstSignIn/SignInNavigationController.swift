//
//  FirstSignInNavigationController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 28/7/17.
//
//

import UIKit
import AWSMobileHubHelper
import PromiseKit



class SignInNavigationController: UINavigationController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationIndicator: UIActivityIndicatorView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationView: UIView!
    
    
    var progressView = UIProgressView()
    var user = User()
    var necessaryViewController = Array<String>()
    var nextViewController: String? {
        if let storyboardId = self.visibleViewController?.restorationIdentifier,
            let index = necessaryViewController.index(of: storyboardId) {
            return necessaryViewController[index+1]
        }
        return necessaryViewController[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        loadingAnimationView = self.view
        
        // prepare User for registration
        startLoadingAnimation()
        UserAPI.getCognitoIdTask().continueWith{ [weak self] task -> () in
            guard let strongSelf = self else { return }
            
            strongSelf.stopLoadingAnimation()
            if let error = task.error {
                print("SignInNavigationController ERROR : \(error)")
            } else {
                if let cognitoId = task.result as String? {
                    strongSelf.user.id = cognitoId
                }
            }
        }
        
        // position progressBar
        // Set up progress bar (right under the navigationController tob bar)
        let navBar = self.navigationBar
        let navBarHeight = navBar.frame.height
        let pSetX = CGFloat(0)
        let pSetY = CGFloat(navBarHeight)
        progressView.frame = CGRect(x: pSetX, y: pSetY, width: self.view.bounds.width, height: 3)
        self.view.addSubview(progressView)
        
        progressView.trackTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        progressView.progressTintColor = #colorLiteral(red: 0.5019607843, green: 0.6901960784, blue: 0.9725490196, alpha: 1)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 3)
        
        // hide navigation Bar
        self.navigationController?.isNavigationBarHidden = true
    }
    
    /**
     Sets missing VC depending on already provided user data
     */
    func setNecessaryViewController() {
        necessaryViewController.append(contentsOf: ["EmailViewController", "BirthdateViewController", "GenderViewController", "CategoriesViewController"])
        
        if user.birthdate != nil { necessaryViewController.remove(at: necessaryViewController.index(of: "BirthdateViewController")!) }
        if user.gender != nil { necessaryViewController.remove(at: necessaryViewController.index(of: "GenderViewController")!) }
        if user.email != nil { necessaryViewController.remove(at:  necessaryViewController.index(of: "EmailViewController")!) }
        // categories cannot be retrieved before user input
        
    }
    func pushNextViewController() {
        if let nextVCIdentifier = nextViewController {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let newVC = storyboard.instantiateViewController(withIdentifier: nextVCIdentifier)
            pushViewController(newVC, animated: true)
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


