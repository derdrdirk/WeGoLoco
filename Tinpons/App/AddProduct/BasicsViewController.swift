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
import TOCropViewController


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
                $0.tag = "nameRow"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }.onChange{ [unowned self] in
                self.tinpon.name = $0.value
            }
            <<< SegmentedRow<String>() {
                $0.title = "Sexo"
                $0.tag = "Gender"
                $0.options = ["👱", "👩"]
                $0.value = "👱"
                }.cellSetup { segmentedCell, segmentedRow in
                    segmentedCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }
            <<< DecimalRow() {
                $0.title = "Precio"
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
                $0.add(rule: RuleRequired())
                $0.tag = "priceRow"
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }.cellSetup { [unowned self] cell, row  in
                    cell.textField.keyboardType = .numberPad
                    self.tinpon.price = row.value
                }.onChange{ [unowned self] in
                    self.tinpon.price = $0.value
        }
            <<< recursiveImageRow()
        
        form +++ Section("") {
            $0.tag = "Continuar"
        }
            <<< ButtonRow() {
                $0.title = "Continuar"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] buttonCell, row in
                    guard let strongSelf = self else { return }
                    if strongSelf.validateForm() {
                        strongSelf.performSegue(withIdentifier: "segueToSelectProductCategory", sender: self)
                    }
        }
    }
    
    // MARK: guard Tinpon Basics
    fileprivate func guardTinponBasics() {
        tinpon.name = (form.rowBy(tag: "nameRow") as! TextRow).value
        tinpon.price = (form.rowBy(tag: "priceRow") as! DecimalRow).value

        for row in form.allRows {
            if let image = (row as? ImageRow)?.value {
                tinpon.images.append(image)
                
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
    
    // MARK: RecursiveImageRow
    var editingImageRow: ImageRow?
    
    func recursiveImageRow() -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Añadir Imagen"
            $0.sourceTypes = [.PhotoLibrary, .Camera]
            $0.clearAction = .yes(style: UIAlertActionStyle.destructive)
            }.cellUpdate { [weak self] cell, row in
                guard let strongSelf = self else { return }
                
                if row.title != "Imagen" {
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                } else {
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.03529411765, blue: 0.0862745098, alpha: 1)
                }
                
                if let image = row.value, strongSelf.editingImageRow == nil {
                    strongSelf.editingImageRow = row
                    strongSelf.presentCropViewController(image)
                }
            }.onChange { [weak self] row in
                guard let strongSelf = self else { return }
                let rowIndex = row.indexPath!.row
                if row.value == nil {
                    // delete row
                    row.section?.remove(at: rowIndex)
                } else if row.title != "Imagen" {
                    // add row
                    row.title = "Imagen"
                    row.section?.insert(strongSelf.recursiveImageRow(), at: rowIndex+1)
                }
        }
        
        return imageRow
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tinpon = Tinpon()
        guardTinponBasics()
        
        let selectCategoryViewController = segue.destination as! SelectCategoryViewController
        selectCategoryViewController.gender = getGender()
        selectCategoryViewController.isMultipleSelection = false
    }
    
    // MARK: - Helper
    fileprivate func removeRow(row: BaseRow) {
        let rowIndex = row.indexPath!.row
        form.allSections[0].remove(at: rowIndex)
        if editingImageRow != nil {
            editingImageRow = nil
        }
    }
    
    fileprivate func getGender() -> Gender {
        let genderRow = form.rowBy(tag: "Gender") as! SegmentedRow<String>
        if genderRow.value == "👱" {
            return .male
        } else {
            return .female
        }
    }
    
    private func validateForm() -> Bool {
        if !form.validate().isEmpty {
            let message = Message(title: "El formulario no es valido.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return false
        } else if imageCount() == 0 {
            let message = Message(title: "Hay que añadir un imagen.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return false
        }
        return true
    }
    
    private func imageCount() -> Int {
        var i = -1 // there will be always one empty ImageRow to add an image
        for row in form.allRows {
            if let imageRow = row as? ImageRow {
                i += 1
            }
        }
        return i
    }
    
    @objc private func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}



extension BasicsViewController:  TOCropViewControllerDelegate {
    func presentCropViewController(_ image: UIImage) {
        let image = image
        
        let cropViewController = TOCropViewController(image: image)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.delegate = self
        startLoadingAnimation()
        self.present(cropViewController, animated: true, completion: {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: NSInteger) {
        dismiss(animated: false)
        presentFilterViewController(image)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: {
          self.removeRow(row: self.editingImageRow!)
        })
    }
    
    
}

extension BasicsViewController: SHViewControllerDelegate {
    func presentFilterViewController(_ image: UIImage) {
        let imageToBeFiltered = image
        let vc = SHViewController(image: imageToBeFiltered)
        vc.delegate = self
        startLoadingAnimation()
        present(vc, animated:true, completion: {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
        })
        
    }
    
    func shViewControllerImageDidFilter(_ image: UIImage) {
        editingImageRow?.value = image
        
        editingImageRow?.reload()
        editingImageRow = nil
    }
    
    func shViewControllerDidCancel() {
        removeRow(row: editingImageRow!)
    }
}




