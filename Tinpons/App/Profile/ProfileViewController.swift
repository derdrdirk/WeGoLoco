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

class ProfileViewController: FormViewController {
    
    var overlay : UIView?
     var indicator: UIActivityIndicatorView?
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self?.performSegue(withIdentifier: "unwindProfileViewController", sender: nil)
                    
        }
        
        // load User
        getUserProfile()
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func updateUI() {
        print("update User")
        let birthdateRow = form.rowBy(tag: "Birthdate") as? DateRow
        birthdateRow?.value = user?.birthdate?.dateFromISO8601
        birthdateRow?.reload()
        
        let genderRow = form.rowBy(tag: "Gender") as? SegmentedRow<String>
        genderRow?.value = user?.gender
        genderRow?.reload()
        
        
        let heightRow = form.rowBy(tag: "Height") as? SliderRow
        if let height = user?.height {
            heightRow?.value = height as? Float
        } else {
            heightRow?.value = 1.0
        }
        heightRow?.reload()
        
        let tinponCategoriesRow = form.rowBy(tag: "tinponCategories") as? MultipleSelectorRow<String>
        tinponCategoriesRow?.value = user?.tinponCategories
        tinponCategoriesRow?.reload()

        
        
    }
    
    // MARK: get Cognito ID
    func getUserProfile() {
        // Set up overlay
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        overlay!.alpha = 0.7
        view.addSubview(overlay!)
        
        // Set up activity indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator!.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        indicator!.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        indicator!.center = view.center
        view.addSubview(indicator!)
        indicator!.bringSubview(toFront: view)
        indicator!.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true


        let cognitoId = AWSMobileClient.cognitoId
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.load(User.self, hashKey: cognitoId, rangeKey:nil).continueWith(block: {[weak self] (task:AWSTask<AnyObject>!) -> Any? in
            guard let strongSelf = self else { return nil }
            if let error = task.error {
                print("The request failed. Error: \(error)")
            } else if let resultUser = task.result as? User {
                // Do something with task.result.
               strongSelf.user = resultUser
                DispatchQueue.main.async {
                    strongSelf.indicator!.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    strongSelf.presentingViewController?.dismiss(animated: true)
                    strongSelf.overlay?.removeFromSuperview()

                    strongSelf.updateUI()
                }
            }
            return nil
        })
    }

    
    // MARK: save & cancel
    @IBAction func tabSaveButton(_ sender: UIBarButtonItem) {
        // Set up overlay
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        overlay!.alpha = 0.7
        view.addSubview(overlay!)
        
        // Set up activity indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator!.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        indicator!.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        indicator!.center = view.center
        view.addSubview(indicator!)
        indicator!.bringSubview(toFront: view)
        indicator!.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(user!).continueWith(block: { [weak self] (task:AWSTask<AnyObject>!) -> Void in
            guard let strongSelf = self else { print("self fail"); return }
            if let error = task.error {
                print("The request failed. Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    strongSelf.indicator!.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    strongSelf.presentingViewController?.dismiss(animated: true)
                    strongSelf.overlay?.removeFromSuperview()
                    
                    let message = Message(title: "Profile saved.", backgroundColor: .green)
                    // Show and hide a message after delay
                    Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                }
            }
        })
    }
    
    
    
   }
