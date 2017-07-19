//
//  AddProductViewController.swift
//  Tinpons
//
//  Created by Dirk Hornung on 10/6/17.
//
//

import UIKit
import Eureka
import ImageRow
import AWSDynamoDB
import AWSMobileHubHelper
import AWSS3
import MapKit
import CoreLocation

class AddTinponViewController: FormViewController, CLLocationManagerDelegate, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var progressView: UIProgressView!
    
    struct TinponToAdd {
        init() {
            tinpon = Tinpon()
            tinpon.tinponId = UUID().uuidString
            tinpon.createdAt = Date().iso8601
            tinpon.active = NSNumber(value: 1)
            tinpon.imgUrl = tinpon.tinponId
            image = UIImage()
        }
        var tinpon: Tinpon!
        var image: UIImage
    }
    var tinponToAdd = TinponToAdd()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loadingAnimationProtocol
        loadingAnimationView = self.view
        
        // get location
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Set up progress bar (right under the navigationController tob bar)
        let navBar = self.navigationController?.navigationBar
        let navBarHeight = navBar?.frame.height
        let progressFrame = progressView.frame
        let pSetX = CGFloat(0)
        let pSetY = CGFloat(navBarHeight!)
        let pSetWidth = view.frame.size.width
        let pSetHeight = progressFrame.height
        progressView.frame = CGRect(x: pSetX, y: pSetY, width: pSetWidth, height: pSetHeight)
        self.navigationController?.navigationBar.addSubview(progressView)
        
        // Set up Eureka form
        form +++ Section("Product")
            <<< TextRow(){
                $0.title = "Name"
                $0.placeholder = "Shoes"
                $0.tag = "name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }.onChange{ [unowned self] in
                self.tinponToAdd.tinpon.name = $0.value
            }
            <<< ImageRow() {
                $0.title = "Image"
                $0.sourceTypes = [.PhotoLibrary]
                $0.clearAction = .yes(style: .default)
                $0.tag = "image"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.textLabel?.textColor = .red
                }
            }.onChange{ [unowned self] in
                self.tinponToAdd.image = $0.value!
            }
            <<< DecimalRow() {
                $0.title = "Price"
                $0.value = 5
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
            }.cellSetup { [unowned self] cell, row  in
                cell.textField.keyboardType = .numberPad
                self.tinponToAdd.tinpon.price = row.value as NSNumber?
            }.onChange{ [unowned self] in
                self.tinponToAdd.tinpon.price = $0.value as NSNumber?
            }
            <<< PushRow<String>() {
                $0.title = "Category"
                $0.options = ["👕", "👖", "👞", "👜", "🕶"]
                $0.value = "👕"
                $0.selectorTitle = "Choose an Emoji!"
            }.cellSetup{ [unowned self] in
                self.tinponToAdd.tinpon.category = $1.value
            }.onPresent { from, to in
                to.enableDeselection = false
                to.sectionKeyForValue = { option in
                    switch option {
                    case "👕", "👖", "👞": return "Clothing"
                    case "👜", "🕶": return "Accessoires"
                    default: return ""
                    }
                }
            }.onChange{ [unowned self] in
                self.tinponToAdd.tinpon.category = $0.value
            }
    }
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        tinponToAdd.tinpon.latitude = NSNumber(value: locValue.latitude)
        tinponToAdd.tinpon.longitude = NSNumber(value: locValue.longitude)
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (form.validate().count == 0) {
            startLoadingAnimation()
            
            tinponToAdd.tinpon.save(imageToUpload: tinponToAdd.image, progressView, onCompletionClosure: { [weak self] in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    
                    strongSelf.stopLoadingAnimation()
                    
                    strongSelf.performSegue(withIdentifier: "unwindToTinponManager", sender: strongSelf)
                }
                })
        } else {
            let alert = UIAlertController(title: "Form Invalid", message: "Check the red marked fields.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "es_ES_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    var DDMMyyyy: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        return formatter.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
