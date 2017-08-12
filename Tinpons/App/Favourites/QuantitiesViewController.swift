//
//  ColorsAndSizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 10/8/17.
//
//

import UIKit
import Eureka
import Whisper
import ImageRow
import TOCropViewController

class QuantitiesViewController: FormViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var tinpon: Tinpon!
    var editingImageRow: ImageRow?
    var editingColor: Color?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingAnimationView = navigationController?.view
        
        tableView.isEditing = false
        
        productSections()
    }
    
    
    
    // MARK: Sections
    
    private func productSections() {
        for productVariation in tinpon.productVariations {
            let color = productVariation.key
            form +++ colorSection(color: color)
        }
    }
    
    private func colorSection(color: Color) -> Section {
        let section = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                               header: color.spanishName,
                               footer: "Swipe a la izquierda para borrar fillas.")

        let colorVariation = tinpon.productVariations[color]!
        
        for sizeVariation in colorVariation.sizeVariations {
            section <<< IntRow() {
                $0.title = "Cuantidad - "+sizeVariation.size
                $0.add(rule: RuleRequired())
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        }
        
        section <<< recursiveImageRow(color: color)
        
        return section
    }
    
    // MARK: Rows
    func recursiveImageRow(color: Color) -> ImageRow {
        let imageRow = ImageRow() {
            $0.title = "Imagen"
            $0.sourceTypes = [.PhotoLibrary]
            $0.clearAction = .yes(style: .default)
            }.cellUpdate { [weak self] cell, row in
                guard let strongSelf = self else { return }
                if let image = row.value, strongSelf.editingImageRow == nil {
                    row.sourceTypes = [.Camera]
                    strongSelf.editingImageRow = row
                    strongSelf.editingColor = color
                    strongSelf.presentCropViewController(image: image)
                }
            }.onChange {
                var productVariation = self.tinpon.productVariations[color]!
                let rowIndex = $0.indexPath!.row
                let imageIndex = rowIndex - productVariation.sizeVariations.count
                if $0.value != nil {
                    // delete row
                    $0.section?.remove(at: rowIndex)
                }
        }
        
        return imageRow
    }
    
    // MARK : Actions
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if form.validate().isEmpty {
            print("nice continue")
        } else {
            let message = Message(title: "Faltan cuantidades.", backgroundColor: .red)
            Whisper.show(whisper: message, to: navigationController!, action: .show)
        }
    }
    
    
    // MARK : Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue")
    }
}

extension QuantitiesViewController:  TOCropViewControllerDelegate {
    func presentCropViewController(image: UIImage) {
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
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle angle: NSInteger) {
        dismiss(animated: false)
        presentFilterViewController(image: image)
    }
}

extension QuantitiesViewController: SHViewControllerDelegate {
    func presentFilterViewController(image: UIImage) {
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
    
    func shViewControllerImageDidFilter(image: UIImage) {
        let color = editingColor!
        let rowIndex = (editingImageRow?.indexPath?.row)!
        editingImageRow?.section?.insert(recursiveImageRow(color: color), at: rowIndex+1)
        
        editingImageRow?.value = image
        editingImageRow?.reload()
        editingImageRow = nil
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}
