//
//  EmailConfirmationViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 3/8/17.
//
//

import UIKit
import Validator
import AWSCognitoUserPoolsSignIn
import Whisper
import PromiseKit

class EmailConfirmationViewController: UIViewController, LoadingAnimationProtocol {

    // MARK: LoadingAnimationProtocol
    var loadingAnimationIndicator: UIActivityIndicatorView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationView: UIView!
    
    var user: AWSCognitoIdentityUser?
    
    enum ValidationErrors: String, Error {
        case minLength = "Dirección de e-mail es obligtorio"
        case emailInvalid = "Dirección de e-mail no válida."
        var message: String { return self.rawValue }
    }
    
    let rangeLengthRule = ValidationRuleLength(min: 6, max: 6, error: ValidationErrors.minLength)
    var validationRules = ValidationRuleSet<String>()
    var signInNavigationController: SignInNavigationController!

    
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let myNavigationController = self.navigationController as? SignInNavigationController {
            myNavigationController.progressView.progress = 0.42
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInNavigationController = navigationController as! SignInNavigationController
        
        // LoadingAnimationProtocol
        self.loadingAnimationView = self.navigationController?.view
        
        confirmationCodeTextField.becomeFirstResponder()
        confirmationCodeTextField.useUnderline(color: UIColor.lightGray)
        
        // Validation
        validationRules.add(rule: rangeLengthRule)
        
        continueButton.setTitleColor(#colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1), for: .disabled)
        continueButton.setTitleColor(#colorLiteral(red: 0.5695158243, green: 0.7503048182, blue: 0.9790232778, alpha: 1), for: .normal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resendConfirmationCode(_ sender: UIButton) {
        startLoadingAnimation()
        self.user?.resendConfirmationCode().continueWith(block: {[weak self] (task: AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse>) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                strongSelf.stopLoadingAnimation()
                if let error = task.error as? NSError {
                    let message = Message(title: "No podia enviar el codigo. Pruebalo otra vez.", backgroundColor: .red)
                    Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                } else if let result = task.result as AWSCognitoIdentityUserResendConfirmationCodeResponse! {
                    let message = Message(title: "Código enviado.", backgroundColor: .green)
                   Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)                }
            })
            return nil
        })
    }
    
    @IBAction func confirmationCodeTextFieldEditingChanged(_ sender: UITextField) {
        let validationResult = confirmationCodeTextField.validate(rules: validationRules)
        
        switch validationResult {
        case .valid:
            confirmationCodeTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
            continueButton.isEnabled = true
        case .invalid( _ ):
            confirmationCodeTextField.useUnderline(color: #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1))
            continueButton.isEnabled = false
        }
        
        if confirmationCodeTextField.text == "" {
            confirmationCodeTextField.useUnderline(color: #colorLiteral(red: 0.9646058058, green: 0.9646058058, blue: 0.9646058058, alpha: 1))
        }

    }
    
    @IBAction func confirmationCodeTextFieldPrimaryActionTriggered(_ sender: UITextField) {
       confirmCode()
    }
    
    @IBAction func continueButtonTouch(_ sender: UIButton) {
        confirmCode()
    }

    func confirmCode() {
        self.user?.confirmSignUp(confirmationCodeTextField.text!, forceAliasCreation: true).continueWith(block: {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    let message = Message(title: "Código incorrecto.", backgroundColor: .red)
                    Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                } else {
                    firstly {
                        UserAPI.save(user: strongSelf.signInNavigationController.user)
                    }.then {
                        DispatchQueue.main.async {
                            let message = Message(title: "Registración completado!. Bienvenido 😊", backgroundColor: .green)
                            Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                            
                            // User Pool SingUp completed
                            // delete email + password views + start with additional account signUp
                            let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
                            let newVc = storyboard.instantiateViewController(withIdentifier: "BirthdateViewController") as! BirthdateViewController
                            var vcArray = strongSelf.navigationController?.viewControllers
                            vcArray!.removeLast(3)
                            vcArray!.append(newVc)
                            strongSelf.navigationController?.setViewControllers(vcArray!, animated: false)
                        }

                    }
                    
                                                        // save To RDS
//                                UserAPI.save(preparedObject: myNavigationController.user, onCompletionClosure: {
//                                    print("user created")
//                                    DispatchQueue.main.async {
//                                        let message = Message(title: "Registración completado!. Bienvenido 😊", backgroundColor: .green)
//                                        Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
//                                        
//                                        // User Pool SingUp completed
//                                        // delete email + password views + start with additional account signUp
//                                        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
//                                        let newVc = storyboard.instantiateViewController(withIdentifier: "BirthdateViewController") as! BirthdateViewController
//                                        var vcArray = strongSelf.navigationController?.viewControllers
//                                        vcArray!.removeLast(3)
//                                        vcArray!.append(newVc)
//                                        strongSelf.navigationController?.setViewControllers(vcArray!, animated: false)
//                                    }
//                                })
                    

                
                }
            })
            return nil
        })
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }


}
