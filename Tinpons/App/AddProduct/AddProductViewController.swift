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
        
        form +++ Section("Variaciónes")
        
        form +++ Section("") {
            $0.tag = "variationInserter"
        }
            <<< ButtonRow() {
                $0.title = "Añadir Color"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] _,_ in
                    guard let strongSelf = self else { return }
                    
                    let variationSectionIndex = (strongSelf.form.sectionBy(tag: "variationInserter")?.index)!
                    strongSelf.form.insert(strongSelf.productVariationSection(), at: variationSectionIndex)

        }
    }
    
    
    // MARK: Special Rows
    
    private func productVariationSection() -> Section {
        var section = MultivaluedSection(multivaluedOptions: [.Insert, .Delete]) {
            $0.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: super.view.bounds.width, height: 40))
                    let label = UILabel(frame: CGRect(x: 15, y: 0, width: super.view.bounds.width, height: 40))
                    label.text = "Rojo"
                    label.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                    view.addSubview(label)
                    return view
                }))
                return header
            }()
            $0.footer = {
                var footer = HeaderFooterView<UIView>(.callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: super.view.bounds.width, height: 0))
                    return view
                }))
                return footer
            }()
            $0.addButtonProvider = { section in
                return ButtonRow(){
                    $0.title = "Añadir Tamaño"
                }.cellSetup { buttonCell, _ in
                        buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }
            }
            $0.multivaluedRowToInsertAt = { index in
                return ProductVariationRow()
            }
            $0 <<< ProductVariationRow()
        }
        
        section.insert(recursiveImageRow(), at: 0)
        
        return section
    }
    
    private func colorImageSection() -> Section {
        let section = Section() {
            $0.setEmptyHeaderOfHeight(height: 0, width: view.bounds.width)
            $0.footer = {
                var footer = HeaderFooterView<UIView>(.callback({
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: super.view.bounds.width, height: 0))
                    view.layer.addBorder(edge: [.bottom], color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), thickness: 3)
                    return view
                }))
                return footer
            }()
        }
        
        return section <<< recursiveImageRow()
    }
    
    private func recursiveImageRow() -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Imagen"
            $0.sourceTypes = [.PhotoLibrary]
            $0.clearAction = .yes(style: .default)
        }.onChange {
            let index = $0.indexPath!.row
            if let image = $0.value {
                // add (wOw one line arrray initelizer!)
                //(self.tinpon.additionalImages?.append(image)) ?? (self.tinpon.additionalImages = [image])
                $0.section?.insert(self.recursiveImageRow(), at: index+1)
            } else {
                // delete (only if not last)
                if self.tinpon.additionalImages?.count ?? 0 > 1 {
                    $0.section?.remove(at: index)
                }
                self.tinpon.additionalImages?.remove(at: index-1)
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

extension Section {
    func setEmptyHeaderOfHeight(height: CGFloat, width: CGFloat) {
        self.header = HeaderFooterView<UIView>(HeaderFooterProvider.callback {
            return UIView(frame: CGRect(x: 0,y: 0,width: width,height: height))
        } )
    }
}

