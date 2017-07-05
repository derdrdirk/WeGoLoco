//
//  Profile.swift
//  Tinpons
//
//  Created by Dirk Hornung on 5/7/17.
//
//

import UIKit
import Eureka
import AWSCore
import AWSDynamoDB

class ProfileViewController: FormViewController {
    
    var user : Users?
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Eureka form
        form +++ Section("Profil")
            <<< DateRow() { $0.value = Date(); $0.title = "Birthday" }
            <<< SegmentedRow<String>() {
                $0.title = "Gender"
                $0.options = ["👨‍💼", "👩‍💼"]
                $0.value = "👨‍💼"
            }
            <<< SliderRow() {
                $0.title = "Height"
                $0.value = 1.70
                $0.minimumValue = 1.00
                $0.maximumValue = 2.00
                $0.steps = 100
        }
        form +++ Section("Tinpons")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Categories"
                $0.tag = "tinponCategories"
                $0.options = ["👕", "👖", "👞", "👜", "🕶"]
                //$0.value = user?._tinponCategories
                }
                .onPresent { from, to in
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "👕", "👖", "👟": return "Clothing"
                        case "👜", "🕶": return "Accessoires"
                        default: return ""
                        }
                    }
        }
        
        // load User
        getUserProfile()
    }
    
    func updateUI() {
        print("updating")
        
        let tinponCategories = form.rowBy(tag: "tinponCategories") as? MultipleSelectorRow<String>
        tinponCategories?.value = user?._tinponCategories
        tinponCategories?.reload()
    }

    // MARK: get Cognito ID
    func getUserProfile() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:8088e7da-a496-4ae3-818c-2b9025180888")
        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Retrieve your Amazon Cognito ID
        credentialsProvider.getIdentityId().continueWith(block: { [weak self] (task) -> AnyObject? in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                let cognitoId = task.result!
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                dynamoDBObjectMapper.load(Users.self, hashKey: cognitoId, rangeKey:nil).continueWith(block: {[weak self] (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? Error {
                        print("The request failed. Error: \(error)")
                    } else if let resultUser = task.result as? Users {
                        // Do something with task.result.
                        self?.user = resultUser
                        DispatchQueue.main.async {
                            self?.updateUI()
                        }
                    }
                    return nil
                })

            }
            return task
        })
    }

    
    // MARK: save & cancel
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    
    
   }
