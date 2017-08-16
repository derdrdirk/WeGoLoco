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
import AWSAPIGateway
import AWSCognitoUserPoolsSignIn
import AWSCognitoIdentityProvider
import PromiseKit


private let numberOfCards: Int = 5
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class SwiperViewController: UIViewController, AuthenticationProtocol, ResetUIProtocol {
    
    // MARK: AuthenticationProtocol
    var authenticationNavigationController: UINavigationController!
    var authenticationProtocolTabBarController: UITabBarController!
    
    // MARK: ResetUIProtocol
    var didAppear: Bool = false
    func resetUI() {
        TinponsAPI.getNotSwipedTinpons({ [weak self] (tinpons) in
            guard let strongSelf = self else { return }
            if let tinpons = tinpons {
                DispatchQueue.main.async {
                    strongSelf.outOfTinponsStack.isHidden = false
                }
                
                strongSelf.tinpons.append(contentsOf: tinpons)
                DispatchQueue.main.async {
                    (strongSelf.tinpons.count > 0) ? strongSelf.outOfTinponsStack.isHidden = true : ()
                    strongSelf.kolodaView.resetCurrentCardIndex()
                    strongSelf.kolodaView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.outOfTinponsStack.isHidden = true
                }
            }
        })
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
//        getCognitoID()
        
        //TinponsAPI.getFavouriteTinpons(onComplete: {_ in })
        
        //TinponsAPI.getNotSwipedTinpons(onComplete: { _ in ()})
//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:0dfac2e7-dc9e-4146-a0b8-885e50a545e0")
//        
//        let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
//        
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//        print("initialize swiper")
                //        UserAPI.getSignedInUser{ user in
//            print("Download User \(user?.toJSON())")
//        }
        
//        var user = User()
//        user.birthdate = Date()
//        print(user.toJSON()!)
//        UserAPI.save(preparedObject: user, onCompletionClosure: { print("saved") })
//        UserAPI.update(preparedObject: user, onCompletionClosure: { print("updated") })
        
        
//        let firstSignInStoryboard = UIStoryboard(name: "FirstSignIn", bundle: nil)
//        let firstSignInController: EmailViewController = firstSignInStoryboard.instantiateViewController(withIdentifier: "EmailViewController") as! EmailViewController
//        let navController: FirstSignInNavigationController = firstSignInStoryboard.instantiateViewController(withIdentifier: "FirstSignInNavigationController") as! FirstSignInNavigationController
//        extensionNavigationController.present(navController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ResetUIProtocol
        didAppear = true
        
        // AuthenticationProtocol
        authenticationNavigationController = navigationController
        authenticationProtocolTabBarController = tabBarController
        presentSignInViewController()

        
        // load Tinpons
        loadTinpons()
        
        //resetUI()
        
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
    
    func loadTinpons() {
        firstly {
            TinponsAPI.getNotSwipedTinpons()
            }.then { tinpons -> () in
                var getSwiperImagePromises = [Promise<UIImage>]()
                for tinpon in tinpons {
                    self.tinpons.append(tinpon)
                    getSwiperImagePromises.append(TinponsAPI.getSwiperImage(for: tinpon))
                }
                when(fulfilled: getSwiperImagePromises).then { images -> () in
                    for index in 0..<tinpons.count {
                        tinpons[index].images.append(images[index])
                    }
                    self.kolodaView.reloadData()
                }
            }.catch { error in
                print("SwiperVC.loadTinpons : not swiped tinpons error : \(error)")
        }
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
        var liked = 0
        switch direction {
        case .right:
            liked = 1
            TinponsAPI.saveSwipe(for: tinpons[index], liked: liked)
        case .left:
            liked = 0
            TinponsAPI.saveSwipe(for: tinpons[index], liked: liked)
        case .down:
            liked = 3
            TinponsAPI.saveSwipe(for: tinpons[index], liked: liked)
        default: ()
        }
        
        // if less than 10 tinpons load next Tinpon
        if tinpons.count - koloda.currentCardIndex < 5 {
            TinponsAPI.getNotSwipedTinpons({ [weak self] (tinpons) in
                guard let strongSelf = self else { return }
                
                if let tinpons = tinpons {
                    strongSelf.tinpons.append(contentsOf: tinpons)
                    DispatchQueue.main.async {
                        strongSelf.kolodaView.reloadData()
                    }
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

