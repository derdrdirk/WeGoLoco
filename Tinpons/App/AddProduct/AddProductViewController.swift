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

class AddProductViewController: FormViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var tinpon = Tinpon()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up progress bar (right under the navigationController tob bar)
        let navBar = self.navigationController?.navigationBar
        let navBarHeight = navBar?.frame.height
        let progressFrame = progressBar.frame
        let pSetX = CGFloat(0)
        let pSetY = CGFloat(navBarHeight!)
        let pSetWidth = view.frame.size.width
        let pSetHeight = progressFrame.height
        progressBar.frame = CGRect(x: pSetX, y: pSetY, width: pSetWidth, height: pSetHeight)
        self.navigationController?.navigationBar.addSubview(progressBar)
        
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
                }.onChange{ [weak self] in
                    self?.tinpon.name = $0.value
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
                }.onChange{ [weak self] in
                    self?.tinpon.image = $0.value
            }
            <<< DecimalRow() {
                $0.title = "Price"
                $0.value = 5
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
            }.cellSetup { [weak self] cell, row  in
                cell.textField.keyboardType = .numberPad
                self?.tinpon.price = row.value as NSNumber?
                }.onChange{ [weak self] in
                    self?.tinpon.price = $0.value as NSNumber?
            }
            <<< PushRow<String>() {
                $0.title = "Category"
                $0.options = ["👕", "👖", "👞", "👜", "🕶"]
                $0.value = "👕"
                $0.selectorTitle = "Choose an Emoji!"
                }.cellSetup{ [weak self] in
                    self?.tinpon.category = $1.value
                }.onPresent { from, to in
                    to.enableDeselection = false
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "👕", "👖", "👞": return "Clothing"
                        case "👜", "🕶": return "Accessoires"
                        default: return ""
                        }
                    }
                }.onChange{ [weak self] in
                    self?.tinpon.category = $0.value
        }
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (form.validate().count == 0) {
            tinpon.save()
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
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
