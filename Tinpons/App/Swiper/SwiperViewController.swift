//
//  BackgroundAnimationViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import pop
import AWSMobileHubHelper
import AWSDynamoDB
import AWSS3


private let numberOfCards: Int = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class SwiperViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: CustomKolodaView!
    
    var tinpons : [Tinpons]?
    var lastEvaluatedKey : [String: AWSDynamoDBAttributeValue]?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        getTinpons(5, onCompleted: { (tinpons) in
            for tinpon in tinpons {
                if self.tinpons?.append(tinpon) == nil {
                    self.tinpons = [tinpon]
                }
            }
            DispatchQueue.main.async {
                self.kolodaView.reloadData()
            }
        })
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        kolodaView?.swipe(.right)
    }
    @IBAction func undoButtonTapped(_ sender: UIButton) {
        kolodaView?.revertAction()
    }
    
    // MARK: reload Tinpons
    func getTinpons(_ limit: NSNumber, onCompleted: @escaping ([Tinpons]) -> Void) {
        let dynamoDBOBjectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.indexName = "CreatedAtSortIndex"
        queryExpression.limit = limit
        queryExpression.keyConditionExpression = "Category = :category"
        //queryExpression.expressionAttributeNames = [ "#name" : "name" ]
        queryExpression.expressionAttributeValues = [":category" : "Shoe" ]
        if lastEvaluatedKey != nil {
            queryExpression.exclusiveStartKey = lastEvaluatedKey!
        }
        
        dynamoDBOBjectMapper.query(Tinpons.self, expression: queryExpression).continueWith(block: { [weak self] (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Void in
            if let error = task.error as? NSError {
                print("Object download complete.")
                print("The request failed DYNAMODB. Error: \(error)")
            } else if let paginatedOutput = task.result {
               onCompleted(paginatedOutput.items as! [Tinpons])
            }
        })
    } 
}

//MARK: KolodaViewDelegate
extension SwiperViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

// MARK: KolodaViewDataSource
extension SwiperViewController: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        if tinpons != nil {
            return tinpons!.count
        } else {
            return 0
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cell = Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? CustomOverlayView
        //cell?.image.setImageWithUrl(url: NSURL(string: (tinpons?[index]._imgUrl)!)!)
        cell?.title.text = tinpons?[index]._name
        print(tinpons?[index]._imgUrl)
        cell?.image.imageFromServerURL(urlString: "https://s3-eu-west-1.amazonaws.com/tinpons-userfiles-mobilehub-1827971537/public/12C98393-0BA8-4350-B810-ED8B05DAFDA5")
        return cell!
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        getTinpons(1, onCompleted: {(tinpons) in
            for tinpon in tinpons {
                self.tinpons?.append(tinpon)
            }
            DispatchQueue.main.async {
                self.kolodaView.reloadData()
            }
        })
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

