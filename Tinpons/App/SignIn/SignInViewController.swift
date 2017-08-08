//
//  SignInViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//
//

import UIKit
import AWSMobileHubHelper
import FBSDKLoginKit
import AWSFacebookSignIn
import PromiseKit

let backgroundImageColor =  UIColor.darkGray

class SignInViewController : UIViewController {
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var tableFormView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var logoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orSignInWithLabel: UILabel!
    
    var canCancel : Bool = true
    var didCompleteSignIn: ((_ success: Bool) -> Void)? = nil
    var passwordRow : FormTableCell?
    var userNameRow : FormTableCell?
    var tableDelegate : FormTableDelegate?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    let smallLogoName = "logo-aws-small"
    let bigLogoName = "logo-aws-big"
    
    var signInNavigationController: SignInNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInNavigationController = navigationController as! SignInNavigationController
        
        // set up the logo in image view
        self.setUpLogo()
        // set up username and password UI if user pools enabled
        self.setUpUserPoolsUI()
        // set up background
        self.setUpBackground()
        // set up facebook button if enabled
        self.setUpFacebookButton()
        // set up google button if enabled
        self.setUpGoogleButton()
        
    }
    
    func setUpUserPoolsUI() {
        passwordRow = FormTableCell(placeHolder: "Password", type: InputType.password)
        userNameRow = FormTableCell(placeHolder: "User Name", type: InputType.text)
        tableDelegate = FormTableDelegate()
        tableDelegate?.add(cell: userNameRow!)
        tableDelegate?.add(cell: passwordRow!)
        tableView?.delegate = tableDelegate
        tableView?.dataSource = tableDelegate
        tableView.reloadData()
        UserPoolsUIHelper.setUpFormShadow(view: tableFormView)
        self.setUpResponders()
    }
    
    func setUpLogo() {
        logoView.contentMode = UIViewContentMode.center
        logoView.image = UIImage(imageLiteralResourceName: smallLogoName)
    }
    
    func setUpBackground() {
        self.view.backgroundColor = UIColor.white
        let backgroundImageView = UIImageView(frame: CGRect(x: 0, y:0, width: self.view.frame.width, height: self.tableFormView.center.y))
            backgroundImageView.backgroundColor = backgroundImageColor
        backgroundImageView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    func setUpFacebookButton() {
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile", "email", "user_birthday"])
        // Facebook UI Setup
        let facebookComponent = AWSFacebookSignInButton(frame: CGRect(x: 0, y: 0, width: facebookButton.frame.size.width, height: facebookButton.frame.size.height))
        facebookComponent.buttonStyle = .large // use the large button style
        facebookComponent.delegate = self // set delegate to respond to user actions
        facebookButton.addSubview(facebookComponent)
    }
    
    func setUpGoogleButton() {
        // Hide google button
        googleButton.removeFromSuperview()
    }
    
    func barButtonClosePressed() {
        // log out
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                print("logged out")
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }

//        self.dismiss(animated: true, completion: nil)
//        if let didCompleteSignIn = self.didCompleteSignIn {
//            didCompleteSignIn(false)
//        }
    }
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName, completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
            print("result = \(result), error = \(error)")
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
//                print("Signed in with: \(signInProvider)")
                
                self.login()
                
                return
            }
            self.showErrorDialog(signInProvider.identityProviderName, withError: error as! NSError)
        })
    }
    
    func showErrorDialog(_ loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Sign-in Provider Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Label to cancel sign-in failure."), style: .cancel, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setUpResponders() {
        signInButton.addTarget(self, action: #selector(handleUserPoolSignIn), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleUserPoolForgotPassword), for: .touchUpInside)
    }
    
    @IBAction func touchedSignUpButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UserPoolEmailViewController")
        self.navigationController?.pushViewController(viewController, animated:true);
    }
    
    /**
     checks user registration status and logs in if OK
     */
    func login() {
        firstly {
            UserAPI.getSignedInUser()
        }.then { user -> Void in
            // check registration status
            if self.isUserCompletelyRegistered(user: user) {
                print("login")
            } else {
                self.signInNavigationController.user = user
                
                self.signInNavigationController.setNecessaryViewController()
                self.signInNavigationController.pushNextViewController()
            }
        }.catch { error in
            // User logged in but does not exist in RDS (e.g. FacebookSignIn)
            // => Create User with all possible information
            
            let profilIdentity = AWSIdentityManager.default().identityProfile as! FacebookIdentityProfile
            let user = User()
            
            
            if let gender = profilIdentity.gender {
                if gender == "male" {
                    user.gender = "👨‍⚕️"
                } else {
                    user.gender = "👩‍⚕️"
                }
            }
            
            if let email = profilIdentity.email {
                user.email = email
                
                firstly {
                    // if email is already taken => get new Email, else registrationVCSerie
                    UserAPI.isEmailAvailable(email: user.email!)
                    }.then { isEmailAvailable in
                        if !isEmailAvailable {
                            user.email = nil
                        }
                        return UserAPI.save(user: user)
                    }.then { () -> () in
                        self.signInNavigationController.user = user
                        self.signInNavigationController.setNecessaryViewController()
                        self.signInNavigationController.pushNextViewController()
                }

            } else {
                firstly {
                    UserAPI.save(user: user)
                }.then { () -> () in
                    self.signInNavigationController.user = user
                    self.signInNavigationController.setNecessaryViewController()
                    self.signInNavigationController.pushNextViewController()
                }
            }
            
        }
    }
    
    /**
     checks if user is "completly" registered
     */
    func isUserCompletelyRegistered(user: User) -> Bool {
        if user.email != nil && user.birthdate != nil && user.gender != nil && user.categories.count > 0 {
            return true
        } else {
            return false
        }
    }
}

extension SignInViewController: AWSSignInDelegate {
    // delegate handler for facebook / google sign in.
    func onLogin(signInProvider: AWSSignInProvider, result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) {
        // dismiss view controller if no error
        if error == nil {
//            print("Signed in with: \(signInProvider)")
            
            self.login()
            
//            if let didCompleteSignIn = self.didCompleteSignIn {
//                didCompleteSignIn(true)
//
//            }
            return
        }
        self.showErrorDialog(signInProvider.identityProviderName, withError: error as! NSError)
    }
}
