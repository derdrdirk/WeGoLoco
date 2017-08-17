//
//  TinponDetailViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 17/8/17.
//
//

import UIKit
import FSPagerView
import PromiseKit

class TinponDetailViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate, LoadingAnimationProtocol {
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpon: Tinpon!
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = tinpon?.images.count ?? 0
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.setFillColor(#colorLiteral(red: 0, green: 0.03529411765, blue: 0.0862745098, alpha: 1), for: .normal)
            self.pageControl.setFillColor(#colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1), for: .selected)
            
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // LoadingAnimationProtocoll
        loadingAnimationView = self.view
        
        loadTinpon(tinponId: tinpon.id!)
        
        pagerView.delegate = self
        pagerView.dataSource = self
    }
    
    private func loadTinpon(tinponId: Int) {
        startLoadingAnimation()
        firstly {
            TinponsAPI.getTinpon(fromId: tinponId)
        }.then { tinpon -> () in
            var imagePromises = [Promise<UIImage>]()
            for index in 1...tinpon.mainImageCount! {
                let s3Key = "Tinpons/\(tinpon.id!)/main/\(index).png"
                print(s3Key)
                imagePromises.append(TinponsAPI.getImage(fromS3Key: s3Key))
            }
            when(fulfilled: imagePromises).then { images -> () in
                for image in images {
                    tinpon.images.append(image)
                }
                DispatchQueue.main.async {
                    self.tinpon = tinpon
                    self.pagerView.reloadData()
                    self.pageControl.numberOfPages = tinpon.images.count
                    self.stopLoadingAnimation()
                }
            }
        }
    }
    
    // MARK: - FSPagerView DataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return tinpon?.images.count ?? 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image =  tinpon?.images[index]
        return cell
    }
    
    // MARK: - FSPagerView Delegate
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
        self.pageControl.currentPage = index
    }

    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
