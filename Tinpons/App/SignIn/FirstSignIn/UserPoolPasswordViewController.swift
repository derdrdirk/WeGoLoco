//
//  UserPoolPasswordViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 8/8/17.
//
//

import UIKit
import AWSCognitoUserPoolsSignIn

class UserPoolPasswordViewController: PasswordViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func continueWithValidPassword() {
        let email = signInNavigationController.user.email
        
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
                        
                        let signInViewController = self?.navigationController?.viewControllers[0] as! SignInViewController
                        signInViewController.userNameRow?.staticText = self?.userId
                        signInViewController.passwordRow?.staticText = self?.passwordTextField.text
                    
                        strongSelf.performSegue(withIdentifier: "segueToUserPoolEmailConfirmationViewController", sender: self)
                    }
                }
            }
            return nil
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
