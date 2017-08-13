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
import PromiseKit

class ProfileViewController: FormViewController, AuthenticationProtocol, ResetUIProtocol, LoadingAnimationProtocol {
    // MARK: Authentication Protocol
    var authenticationProtocolTabBarController: UITabBarController!
    var authenticationNavigationController: UINavigationController!
    
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
    
    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        // AnimationLoader
        loadingAnimationView = self.view
        
        // Authentication Protocol
        authenticationNavigationController = navigationController
        authenticationProtocolTabBarController = tabBarController
        presentSignInViewController()
        
        // Set up Eureka form
        form +++ Section("Profil")
            <<< DateRow() {
                $0.value = Date()
                $0.title = "Cumpleaños"
                $0.tag = "Birthdate"
                }.onChange{[weak self] in
                    self?.user?.birthdate = $0.value
            }
            <<< SegmentedRow<String>() {
                $0.title = "Sexo"
                $0.tag = "Gender"
                $0.options = ["👱", "👩"]
                }.cellSetup { segmentedCell, segmentedRow in
                    segmentedCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onChange{[weak self] in
                    self?.user?.gender = $0.value
            }

        form +++ Section("Tinpons")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Categorías"
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
                    self?.user?.categories = $0.value!
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
                $0.title = "Desconectar"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
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
        startLoadingAnimation()
        
        firstly {
            UserAPI.getSignedInUser()
        }.then { user -> Void in
            self.user = user
            
            DispatchQueue.main.async {
                self.updateForm()
                self.presentingViewController?.dismiss(animated: true)
                self.stopLoadingAnimation()
            }
        }
    }
    
    func updateForm() {
        let birthdateRow = form.rowBy(tag: "Birthdate") as? DateRow
        birthdateRow?.value = user.birthdate
        birthdateRow?.reload()
        
        let genderRow = form.rowBy(tag: "Gender") as? SegmentedRow<String>
        genderRow?.value = user.gender
        genderRow?.reload()
        
        let categoriesRow = form.rowBy(tag: "tinponCategories") as? MultipleSelectorRow<String>
        categoriesRow?.value = user.categories
        categoriesRow?.reload()

    }
    
    
    // MARK: save & cancel
    @IBAction func tabSaveButton(_ sender: UIBarButtonItem) {
        startLoadingAnimation()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        firstly {
            UserAPI.update(user)
        }.then {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.presentedViewController?.dismiss(animated: true)
                
                let message = Message(title: "Profile saved.", backgroundColor: .green)
                Whisper.show(whisper: message, to: self.navigationController!, action: .show)
            }
        }
    }

}
