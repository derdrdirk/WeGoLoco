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
import AWSMobileHubHelper
import CoreLocation
import Whisper

class ProfileViewController: FormViewController, AuthenticationProtocol, ResetUIProtocol, LoadingAnimationProtocol {
    // MARK: Authentication Protocol
    var authenticationProtocolTabBarController: UITabBarController!
    var extensionNavigationController: UINavigationController!
    
    // MARK: AnimationLoader
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay : UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    // MARK: ResetUIProtocol
    var didAppear: Bool = false
    func resetUI() {
        if(didAppear) {
            updateUI()
        }
    }
    
    var user : DynamoDBUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        // AnimationLoader
        loadingAnimationView = self.view
        
        // Authentication Protocol
        extensionNavigationController = navigationController
        authenticationProtocolTabBarController = tabBarController
        presentSignInViewController()
        
        // Set up Eureka form
        form +++ Section("Profil")
            <<< DateRow() {
                $0.value = Date()
                $0.title = "Date of Birth"
                $0.tag = "Birthdate"
                }.onChange{[weak self] in
                    self?.user?.birthdate = $0.value?.iso8601
            }
            <<< SegmentedRow<String>() {
                $0.title = "Gender"
                $0.tag = "Gender"
                $0.options = ["👨‍💼", "👩‍💼"]
                }.onChange{[weak self] in
                    self?.user?.gender = $0.value
            }
            <<< SliderRow() {
                $0.title = "Height"
                $0.value = 1.0
                $0.tag = "Height"
                $0.minimumValue = 1.00
                $0.maximumValue = 2.00
                $0.steps = 100
                }.onChange{ [weak self] in
                    self?.user?.height = NSNumber(value: $0.value!)
        }
        form +++ Section("Tinpons")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Categories"
                $0.tag = "tinponCategories"
                $0.options = ["👕", "👖", "👞", "👜", "🕶"]
                $0.value = ["👕"]
                }
                .onPresent { from, to in
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "👕", "👖", "👞": return "Clothing"
                        case "👜", "🕶": return "Accessoires"
                        default: return ""
                        }
                    }
                    
                    to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(ProfileViewController.multipleSelectorDone(_:)))
                }.onChange{[weak self] in
                    self?.user?.tinponCategories = $0.value
                }
        form +++ Section("Distributor") {
            $0.tag = "Distributor"
            $0.hidden = true
        }
            <<< SwitchRow() {
                $0.title = "Distributor"
                $0.value = false
                $0.tag = "DistributorSwitch"
            }
            <<< TextRow() {
                $0.title = "Store Name"
                $0.placeholder = "Nike Store"
                $0.tag = "ShopName"
            }
            <<< LocationRow(){
                $0.title = "Store Location"
                $0.value = CLLocation(latitude: -34.91, longitude: -56.1646)
                $0.tag = "StoreLocation"
                }.onChange{
                    $0.reload()
        }
        form +++ Section("Logout")
            <<< ButtonRow() {
                $0.title = "Sign Out"
                }.onCellSelection{[weak self] _,_ in
                    guard let strongSelf = self else { return }
                    strongSelf.handleLogout()
        }
        
        // load User
        updateUI()
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateUI() {
        print("start loading")
        startLoadingAnimation()
        
        UserWrapper.getSignedInUser{ [weak self] user in
            guard let strongSelf = self else { return }
            
            strongSelf.user = user
            
            DispatchQueue.main.async {
                strongSelf.updateForm()
                strongSelf.presentingViewController?.dismiss(animated: true)
        
                strongSelf.stopLoadingAnimation()
            }
        }
        
        
    }
    
    func updateForm() {
        let birthdateRow = form.rowBy(tag: "Birthdate") as? DateRow
        birthdateRow?.value = user.birthdate?.dateFromISO8601
        birthdateRow?.reload()
        
        let genderRow = form.rowBy(tag: "Gender") as? SegmentedRow<String>
        genderRow?.value = user.gender
        genderRow?.reload()
        
        
        let heightRow = form.rowBy(tag: "Height") as? SliderRow
        if let height = user.height {
            heightRow?.value = height as? Float
        } else {
            heightRow?.value = 1.0
        }
        heightRow?.reload()
        
        let tinponCategoriesRow = form.rowBy(tag: "tinponCategories") as? MultipleSelectorRow<String>
        tinponCategoriesRow?.value = user.tinponCategories
        tinponCategoriesRow?.reload()

    }
    
    
    // MARK: save & cancel
    @IBAction func tabSaveButton(_ sender: UIBarButtonItem) {
        startLoadingAnimation()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(user!).continueWith(block: { [weak self] (task:AWSTask<AnyObject>!) -> Void in
            guard let strongSelf = self else { print("self fail"); return }
            if let error = task.error {
                print("The request failed. Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    strongSelf.stopLoadingAnimation()
                    
                    strongSelf.presentingViewController?.dismiss(animated: true)
                    
                    let message = Message(title: "Profile saved.", backgroundColor: .green)
                    // Show and hide a message after delay
                    Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                }
            }
        })
    }

}
