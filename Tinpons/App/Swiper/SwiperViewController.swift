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
    @IBOutlet weak var outOfTinponsStack: UIStackView!
    
    var userId: String?
    var tinponLoader = Tinpon()
    var tinpons : [Tinpon] = []
    var lastEvaluatedKey : [String: AWSDynamoDBAttributeValue]?
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        getCognitoID()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tinponLoader.loadNotSwipedItems(limit: 5, onComplete: { [weak self] (tinpons) in
            guard let strongSelf = self else { return }
            if tinpons.isEmpty {
                DispatchQueue.main.async {
                    strongSelf.outOfTinponsStack.isHidden = false
                }
            }
            print("loaded count: \(tinpons.count)")
            strongSelf.tinpons.append(contentsOf: tinpons)
            DispatchQueue.main.async {
                strongSelf.kolodaView.reloadData()
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
    
    // MARK: get Cognito ID
    func getCognitoID() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:8088e7da-a496-4ae3-818c-2b9025180888")
        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // Retrieve your Amazon Cognito ID
        credentialsProvider.getIdentityId().continueWith(block: { [weak self] (task) -> AnyObject? in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                let cognitoId = task.result!
                self?.userId = cognitoId as String
            }
            return task
        })
    }
    
    // MARK: swipe DynamoDB
    func saveSwipedTinpon(tinponId: String, liked: Bool) {
        let swipedTinpon = SwipedTinpons()
        swipedTinpon?.userId = userId
        swipedTinpon?.like = NSNumber(value: liked)
        swipedTinpon?.tinponId = tinponId
        swipedTinpon?.swipedAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
        
        swipedTinpon?.save()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let swipedTinponCore = SwipedTinponsCore(context: context)
        swipedTinponCore.tinponId = swipedTinpon?.tinponId
        swipedTinponCore.userId = swipedTinpon?.userId
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

//MARK: KolodaViewDelegate
extension SwiperViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        outOfTinponsStack.isHidden = false
        //kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
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
        return tinpons.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let cell = Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? CustomOverlayView
        //cell?.image.setImageWithUrl(url: NSURL(string: (tinpons?[index]._imgUrl)!)!)
        cell?.title.text = tinpons[index].name
        let resizedImageUrl = "http://tinpons-userfiles-mobilehub-1827971537.s3-website-eu-west-1.amazonaws.com/300x400/"+tinpons[index].imgUrl!
        cell?.image.imageFromServerURL(urlString: resizedImageUrl)
        return cell!
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        // save swipedTinpon
        var liked = false
        switch direction {
        case .right:
            liked = true
        default:
            liked = false
        }
        saveSwipedTinpon(tinponId: (tinpons[index].tinponId)!, liked: liked)
        
        // if less than 10 tinpons load next Tinpon
        if tinpons.count - koloda.currentCardIndex < 5 {
            print("load after swipe")
            tinponLoader.loadNotSwipedItems(limit: 5, onComplete: {[weak self] (tinpons) in
                guard let strongSelf = self else { return }
                print("loaded count: \(tinpons.count)")
                strongSelf.tinpons.append(contentsOf: tinpons)
                DispatchQueue.main.async {
                    strongSelf.kolodaView.reloadData()
                }
            })
        }
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

