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
import Whisper
import PromiseKit

class BasicsViewController: FormViewController, CLLocationManagerDelegate, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var progressView: UIProgressView!
    
    var tinpon = Tinpon()
    var colorTextFields = [UITextField]()
    var colorPicker = UIPickerView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // test tinpon
        let tinpon = Tinpon(testing: true)
        firstly {
            TinponsAPI.save(tinpon: tinpon)
            }.then {
                print("tinpon uploaded")
            }.catch { error in
                print("some error \(error)")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.isEditing = false
        
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
        form +++ Section("Basicos")
            <<< TextRow(){
                $0.title = "Nombre"
                $0.placeholder = "Shoes"
                $0.tag = "name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }.onChange{ [unowned self] in
                self.tinpon.name = $0.value
            }
            <<< PushRow<String>() {
                $0.title = "Categoría"
                $0.options = ["👕", "👖", "👞", "👜", "🕶"]
                $0.value = "👕"
                $0.selectorTitle = "Choose an Emoji!"
            }.cellSetup{ [unowned self] in
                self.tinpon.category = $1.value
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
                self.tinpon.category = $0.value
            }
            <<< DecimalRow() {
                $0.title = "Precio"
                $0.value = 5
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
                }.cellSetup { [unowned self] cell, row  in
                    cell.textField.keyboardType = .numberPad
                    self.tinpon.price = row.value
                }.onChange{ [unowned self] in
                    self.tinpon.price = $0.value
        }
            <<< ImageRow() {
                $0.title = "Imagen Principal"
                $0.sourceTypes = [.PhotoLibrary]
                $0.clearAction = .yes(style: .default)
                $0.tag = "mainImageRow"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                }.onChange{ [unowned self] in
                    self.tinpon.mainImage = $0.value
        }
        
        form +++ Section("") {
            $0.tag = "Continuar"
        }
            <<< ButtonRow() {
                $0.title = "Continuar"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] buttonCell, row in
                    guard let strongSelf = self else { return }
                    
                    if strongSelf.form.validate().isEmpty {
                        strongSelf.performSegue(withIdentifier: "segueToColorsAndSizes", sender: self)
                    } else {
                        let message = Message(title: "El formulario no es valido.", backgroundColor: .red)
                        Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                    }
        }
    }
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        tinpon.latitude = locValue.latitude
        tinpon.longitude = locValue.longitude
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let colorsAndSizesViewController = segue.destination as! ColorsAndSizesViewController
        colorsAndSizesViewController.tinpon = self.tinpon
    }
}




