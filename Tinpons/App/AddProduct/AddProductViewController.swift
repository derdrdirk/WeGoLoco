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

class AddProductViewController: FormViewController, CLLocationManagerDelegate, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var progressView: UIProgressView!
    
    var tinpon = Tinpon()
    
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
        
        form +++ Section("Imagenes") {
            $0.tag = "imageSection"
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
                if $0.value != nil {
                    self.form.sectionBy(tag: "imageSection")! <<< self.additionalImageRow()
                }
        }

        
        form +++ Section("Variaciónes") {
            $0.tag = "Variations"
        }
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "Añadir Variación del Producto"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] _,_ in
                    guard let strongSelf = self else { return }
                    
                    
                    strongSelf.form.sectionBy(tag: "Variations")! <<< ProductVariationRow()
        }
    }
    
    private func additionalImageRow() -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Imagen Addicional"
            $0.sourceTypes = [.PhotoLibrary]
            $0.clearAction = .yes(style: .default)
        }.onChange {
            print("on change add image")
            print($0.indexPath?.row)
            if let image = $0.value {
                // add (wOw one line arrray initelizer!)
                (self.tinpon.additionalImages?.append(image)) ?? (self.tinpon.additionalImages = [image])
                if self.tinpon.additionalImages?.count ?? 0 < 3 {
                    self.form.sectionBy(tag: "imageSection")! <<< self.additionalImageRow()
                }
            } else {
                // delete
                let index = $0.indexPath!.row
                self.tinpon.additionalImages?.remove(at: index-1)
                $0.section?.remove(at: index)
            }
            print("additional images count \(self.tinpon.additionalImages?.count)")
        }
        
        return imageRow
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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (form.validate().count == 0) {
//            startLoadingAnimation()
            
//            tinponToAdd.tinpon.save(imageToUpload: tinponToAdd.image, progressView, onCompletionClosure: { [weak self] in
//                DispatchQueue.main.async {
//                    guard let strongSelf = self else { return }
//                    
//                    strongSelf.stopLoadingAnimation()
//                    
//                    strongSelf.performSegue(withIdentifier: "unwindToTinponManager", sender: strongSelf)
//                }
//            })
        } else {
            let alert = UIAlertController(title: "Form Invalid", message: "Check the red marked fields.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}



