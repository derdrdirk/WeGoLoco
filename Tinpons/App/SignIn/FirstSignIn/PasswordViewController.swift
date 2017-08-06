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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.progressView.progress = 0.28
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            userPoolSignUp()
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
             userPoolSignUp()
        case .invalid( _ ):
            ()
        }
    }
    
    func userPoolSignUp() {
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            let email = myNavigationController.user.email!
            
            var attributes = [AWSCognitoIdentityUserAttributeType]()
            
            // email
            let emailAttribute = AWSCognitoIdentityUserAttributeType()
            emailAttribute?.name = "email"
            emailAttribute?.value = email
            attributes.append(emailAttribute!)
            
            self.startLoadingAnimation()
            
            //sign up the user
            self.pool?.signUp(userId, password: passwordTextField.text!, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task: AWSTask<AWSCognitoIdentityUserPoolSignUpResponse>) -> AnyObject? in
                guard let strongSelf = self else { return nil }
                if let error = task.error as? NSError {
                    print("Email UserPool Error: \(error)")
                } else {
                    if let result = task.result as AWSCognitoIdentityUserPoolSignUpResponse! {
                        DispatchQueue.main.async {
                            strongSelf.stopLoadingAnimation()
                            strongSelf.performSegue(withIdentifier: "segueToEmailConfirmation", sender: strongSelf)
                        }
                    }
                }
                return nil
            }
        }
    }
    
    func guardUserId() {
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.user.id = userId
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guardUserId()
        if let signUpConfirmationViewController = segue.destination as? EmailConfirmationViewController {
            signUpConfirmationViewController.user = self.pool?.getUser(userId)
        }
    }


}
