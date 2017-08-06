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
    var necessaryViewController = ["BirthdateViewController", "GenderViewController", "CategoriesViewController"]
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
    
    func checkRegistration() {
        firstly {
            UserAPI.getSignedInUser()
        }.then { user -> Void in
            // if user exists - check if registration complete
            self.user = user
            print(user)
            if self.isUserRegistered(user: user) {
                print("login")
            } else {
                // not complete registration
                firstly {
                    self.setNecessaryViewController()
                }.then {
                    DispatchQueue.main.async {
                        self.pushNextViewController()
                    }
                }
            }
        }.catch { error in
            // user does not exist
            let identityManager = AWSIdentityManager.default()
            let identityProfil = identityManager.identityProfile as! FacebookIdentityProfile
            
            self.user.email = identityProfil.email
            if let gender = identityProfil.gender {
                if gender == "male" {
                    self.user.gender = "👨‍💼"
                } else {
                    self.user.gender = "👩‍💼"
                }
            }
            
            firstly {
                self.setNecessaryViewController()
            }.then {
                UserAPI.save(user: self.user)
            }.then {
                DispatchQueue.main.async {
                    self.pushNextViewController()
                }
            }
        }
    }
    
    /**
     Sets missing VC depending on already provided user data
    */
    func setNecessaryViewController(completion: @escaping ()->() ) {
        necessaryViewController.append(contentsOf: ["EmailViewController", "BirthdateViewController", "GenderViewController", "CategoriesViewController"])
        
        if user.birthdate != nil { necessaryViewController.remove(at: necessaryViewController.index(of: "BirthdateViewController")!) }
        if user.gender != nil { necessaryViewController.remove(at: necessaryViewController.index(of: "GenderViewController")!) }
        // categories cannot be retrieved before user input
        
        if let email = user.email {
            firstly {
                UserAPI.isEmailAvailable(email: email)
            }.then { isEmailAvailable -> Void in
                if isEmailAvailable {
                    self.necessaryViewController.remove(at:  self.necessaryViewController.index(of: "EmailViewController")!)
                }
                completion()
            }
        } else {
            completion()
        }
    }
    func setNecessaryViewController() -> Promise<Void> {
        return PromiseKit.wrap(setNecessaryViewController)
    }
    
    func pushNextViewController() {
        if let nextVCIdentifier = nextViewController {
            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
            let newVC = storyboard.instantiateViewController(withIdentifier: nextVCIdentifier)
            pushViewController(newVC, animated: true)
        }
    }
    
    /**
     checks if user is "completly" registered
    */
    func isUserRegistered(user: User) -> Bool {
        if user.email != nil && user.birthdate != nil && user.gender != nil && user.categories != nil {
            return true
        } else {
            return false
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


