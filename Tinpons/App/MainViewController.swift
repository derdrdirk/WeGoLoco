//
//  MainViewController.swift
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

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB
import SwiftIconFont

class MainViewController: SwiperViewController {
    
    //fileprivate let loginButton: UIBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)

    // MARK: - View lifecycle

    func onSignIn (_ success: Bool) {
        // handle successful sign in
        if (success) {
            createUserAccountIfNotExisting()
            self.setupLeftBarButtonItem()
        } else {
            // handle cancel operation from user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLeftBarButtonItem()
        
        presentSignInViewController()
    }

    func setupLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Profile", style: .done, target: self, action: #selector(profileButtonTapped))
            navigationItem.leftBarButtonItem?.icon(from: .Ionicon, code: "person", ofSize: 20)
            
        
//            if (AWSSignInManager.sharedInstance().isLoggedIn) {
//                navigationItem.leftBarButtonItem!.title = NSLocalizedString("Sign-Out", comment: "Label for the logout button.")
//                navigationItem.leftBarButtonItem!.action = #selector(MainViewController.handleLogout)
//            }
    }
    
    func profileButtonTapped() {
        performSegue(withIdentifier: "presentProfile", sender: nil)
    }
    
    func presentSignInViewController() {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let loginStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            let loginController: SignInViewController = loginStoryboard.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            loginController.canCancel = false
            loginController.didCompleteSignIn = onSignIn
            let navController = UINavigationController(rootViewController: loginController)
            navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
    func handleLogout() {
        if (AWSSignInManager.sharedInstance().isLoggedIn) {
            ColorThemeSettings.sharedInstance.wipe()
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
                self.navigationController!.popToRootViewController(animated: false)
                self.setupLeftBarButtonItem()
                    self.presentSignInViewController()
            })
            // print("Logout Successful: \(signInProvider.getDisplayName)");
        } else {
            assert(false)
        }
    }


    
    func createUserAccountIfNotExisting() {
        //check if User Account exists
        let dynamoDBOBjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBOBjectMapper.load(Users.self, hashKey: userId, rangeKey: nil).continueWith(block: { [weak self] (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultUser = task.result as? Users {
                print("found something")
                print(resultUser._userId)
            } else if task.result == nil {
                // User does not exist => create
                let user = Users()
                user?._userId = self?.userId
                user?._createdAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
                user?._tinponCategories = ["👕", "👖", "👞"]
                dynamoDBOBjectMapper.save(user!).continueWith(block: { (task:AWSTask<AnyObject>!) -> Void in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else {
                        print("User created")
                        // Do something with task.result or perform other operations.
                    }
                })
            }
            return nil
        })
    }
    
    
    // MARK: Unwind Profile
    @IBAction func unwindProfileViewController(segue: UIStoryboardSegue) {
        handleLogout()
    }
}
