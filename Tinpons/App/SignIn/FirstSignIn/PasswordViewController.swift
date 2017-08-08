//
//  PasswordViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 3/8/17.
//
//

import UIKit
import Validator
import AWSCognitoUserPoolsSignIn
import AWSMobileHubHelper


class PasswordViewController: UIViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationIndicator: UIActivityIndicatorView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationView: UIView!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var pool: AWSCognitoIdentityUserPool?
    var userId = UUID().uuidString
    
    enum ValidationErrors: String, Error {
        case minLength = "Contraseña es obligtorio"
        case passwordInvalid = "Contraseñna no válida."
        var message: String { return self.rawValue }
    }
    
    let minLengthRule = ValidationRuleLength(min: 8, error: ValidationErrors.minLength)
    var validationRules = ValidationRuleSet<String>()
    var signInNavigationController: SignInNavigationController!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.progressView.progress = 0.28
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInNavigationController = navigationController as! SignInNavigationController
        
        self.pool = AWSCognitoIdentityUserPool.default()
        
        // AnimationLoaderProtocol
        loadingAnimationView = self.navigationController?.view
        
        passwordTextField.becomeFirstResponder()
        passwordTextField.useUnderline(color: UIColor.lightGray)
        
        // Validation
        validationRules.add(rule: minLengthRule)
        
        continueButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        continueButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonTouch(_ sender: UIButton) {
        let validationResult = passwordTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
            onContinue()
        case .invalid( _ ):
            ()
        }
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        let validationResult = passwordTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
            passwordTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
            continueButton.isEnabled = true
        case .invalid( _ ):
            passwordTextField.useUnderline(color: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
            continueButton.isEnabled = false
        }
        
        if passwordTextField.text == "" {
            passwordTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
        }
    }

    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: UITextField) {
        let validationResult = passwordTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
             onContinue()
        case .invalid( _ ):
            ()
        }
    }
    
    func onContinue() {}
    
    func guardUserId() {
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.user.id = userId
        }
    }
    
    func guardPassword() {
        signInNavigationController.user.password = passwordTextField.text
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardUserId()
        guardPassword()
        
        if let signUpConfirmationViewController = segue.destination as? EmailConfirmationViewController {
            signUpConfirmationViewController.user = self.pool?.getUser(userId)
        }
    }


}
