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

class SwiperViewController: UIViewController, AuthenticationProtocol, ResetUIProtocol {
    
    // MARK: AuthenticationProtocol
    var extensionNavigationController: UINavigationController!
    var authenticationProtocolTabBarController: UITabBarController!
    
    // MARK: ResetUIProtocol
    var didAppear: Bool = false
    func resetUI() {
        if(didAppear) {
            print("reset Swiper")
            tinpons = []
            
            tinponWrapper = TinponWrapper(swiperViewController: self)
            tinponWrapper.loadNotSwipedTinponsFromUserCategories(performClousreOnComplete: { [weak self] (tinpons) in
                guard let strongSelf = self else { return }
                if tinpons.isEmpty {
                    DispatchQueue.main.async {
                        strongSelf.outOfTinponsStack.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.outOfTinponsStack.isHidden = true
                    }
                }
                strongSelf.tinpons.append(contentsOf: tinpons)
                DispatchQueue.main.async {
                    (strongSelf.tinpons.count > 0) ? strongSelf.outOfTinponsStack.isHidden = true : ()
                    strongSelf.kolodaView.resetCurrentCardIndex()
                    strongSelf.kolodaView.reloadData()
                }
            })
        }
    }
    
    
    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var outOfTinponsStack: UIStackView!
    
    var tinponWrapper: TinponWrapper!
    var userWrapper = UserWrapper()
    
    var userId: String?
    var tinpons : [Tinpon] = []
    var lastEvaluatedKey : [String: AWSDynamoDBAttributeValue]?
    
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        getCognitoID()
        
//        UserAPI.getSignedInUser{ user in
//            print(user.toJSON()!)
//        }
        
        var user = User()
        user.birthdate = Date()
        print(user.toJSON()!)
        UserAPI.save(preparedObject: user, onCompletionClosure: { print("saved") })
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        // AuthenticationProtocol
        extensionNavigationController = navigationController
        authenticationProtocolTabBarController = tabBarController
        presentSignInViewController()

        
        tinponWrapper = TinponWrapper(swiperViewController: self)
        
        resetUI()
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    }
    
    //MARK: IBActions
    @IBAction func tryAgain(_ sender: UIButton) {
        resetUI()
    }
    @IBAction func leftButtonTapped(_ sender: Any) {
        kolodaView.swipe(.down)
        //kolodaView?.swipe(.left)
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
        let swipedTinpon = SwipedTinpon()
        swipedTinpon.userId = userId
        swipedTinpon.like = NSNumber(value: liked)
        swipedTinpon.tinponId = tinponId
        swipedTinpon.swipedAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
        
        swipedTinpon.save()
        SwipedTinponsCore.save(swipedTinpon: swipedTinpon)
    }
    
    func favouriteTinpon(tinponId: String) {        
        let swipedTinpon = SwipedTinpon()
        swipedTinpon.userId = userId
        swipedTinpon.like = NSNumber(value: true)
        swipedTinpon.tinponId = tinponId
        swipedTinpon.swipedAt = Date().iso8601.dateFromISO8601?.iso8601 // "2017-03-22T13:22:13.933Z"
        swipedTinpon.favourite = NSNumber(value: 1)
        
        swipedTinpon.save()
        SwipedTinponsCore.save(swipedTinpon: swipedTinpon)
    }
}

//MARK: KolodaViewDelegate
extension SwiperViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        outOfTinponsStack.isHidden = false
        //kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left, .right, .down]
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
        cell?.tinpon = tinpons[index]
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
            saveSwipedTinpon(tinponId: (tinpons[index].tinponId)!, liked: liked)
        case .left:
            liked = false
            saveSwipedTinpon(tinponId: (tinpons[index].tinponId)!, liked: liked)
        case .down:
            favouriteTinpon(tinponId: (tinpons[index].tinponId)!)
        default: ()
        }
        
        // if less than 10 tinpons load next Tinpon
        if tinpons.count - koloda.currentCardIndex < 5 {
//            tinponLoader.loadNotSwipedItems(limit: 5, onComplete: {[weak self] (tinpons) in
            tinponWrapper.loadNotSwipedTinponsFromUserCategories(performClousreOnComplete: {[weak self] (tinpons) in
                guard let strongSelf = self else { return }
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

