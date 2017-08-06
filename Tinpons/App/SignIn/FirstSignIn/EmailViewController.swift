//
//  EmailViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 28/7/17.
//
//

import UIKit
import Validator
import AWSCognitoIdentityProvider
import AWSCognitoUserPoolsSignIn
import Whisper
import PromiseKit

class EmailViewController: UIViewController, LoadingAnimationProtocol{
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationIndicator: UIActivityIndicatorView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationView: UIView!
    
    var saveEmail = false
    
    var signInNavigationController: SignInNavigationController!
    
    enum ValidationErrors: String, Error {
        case minLength = "Dirección de e-mail es obligtorio"
        case emailInvalid = "Dirección de e-mail no válida."
        var message: String { return self.rawValue }
    }
    
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid)
    let minLengthRule = ValidationRuleLength(min: 1, error: ValidationErrors.minLength)
    var validationRules = ValidationRuleSet<String>()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.progressView.progress = 0.14
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        signInNavigationController = navigationController as! SignInNavigationController
        
        // AnimationLoaderProtocol
        loadingAnimationView = self.navigationController?.view
        
        emailTextField.becomeFirstResponder()
        emailTextField.useUnderline(color: UIColor.lightGray)
        
        // Validation
        validationRules.add(rule: emailRule)
        validationRules.add(rule: minLengthRule)
        
        registerButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        registerButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        let validationResult = emailTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
            emailTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
            guardEmail()
            registerButton.isEnabled = true
        case .invalid( _ ):
            emailTextField.useUnderline(color: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
            registerButton.isEnabled = false

        }
        
        if emailTextField.text == "" {
            emailTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
        }
    }
    
    @IBAction func emailTextFieldPrimaryActionTriggered(_ sender: UITextField) {
        let validationResult = emailTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
            performSegue(withIdentifier: "segueToPassword", sender: self)
        case .invalid( _ ):
            ()
        }
    }
   
    @IBAction func continueButtonTouch(_ sender: UIButton) {
        startLoadingAnimation()
        guardEmail()
        firstly {
            UserAPI.isEmailAvailable(email: signInNavigationController.user.email!)
        }.then { isEmailAvailable -> Void in
            if isEmailAvailable {
                firstly {
                    // try save email - could be from userPool => user does not exist and cannot be updated
                    UserAPI.update(user: self.signInNavigationController.user)
                }.then { Void -> Void in
                    DispatchQueue.main.async {
                        self.stopLoadingAnimation()
                        self.signInNavigationController.pushNextViewController()
                    }
                }.catch { error in
                    // if we pushed register button and came from userPool just go to password
                    DispatchQueue.main.async {
                        self.stopLoadingAnimation()
                        self.performSegue(withIdentifier: "segueToPassword", sender: self)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    let message = Message(title: "Email existe ya.", backgroundColor: .red)
                    self.emailTextField.useUnderline(color: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
                    self.registerButton.isEnabled = false
                    Whisper.show(whisper: message, to: self.navigationController!, action: .show)
                }
            }
        }
    }

    func guardEmail() {
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.user.email = emailTextField.text!
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardEmail()
    }

}
