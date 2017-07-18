//
//  TinponWrapper.swift
//  Tinpons
//
//  Created by Dirk Hornung on 18/7/17.
//
//

import Foundation
import AWSDynamoDB

class TinponWrapper {
    
    var swiperViewController: SwiperViewController!
    var tinponsLoader = Array<TinponLoader>()
    
    init(swiperViewController: SwiperViewController) {
        self.swiperViewController = swiperViewController
    }
    
    class TinponLoader {
        var tinponWrapper: TinponWrapper!
        var limit = 5
        var noMoreTinponsInDatabase = false
        var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]? = nil
        var onComplete: ([Tinpon]) -> Void
        
        init(performClosureOnComplete onComplete: @escaping ([Tinpon]) -> Void, tinponWrapper: TinponWrapper) {
            self.onComplete = onComplete
            self.tinponWrapper = tinponWrapper
        }
        
        // load x=limit Items
        // 1. query x tinpons
        // 2. filter with SwipedTinponsCore
        // 3. if x >= limit: done! | else repeat
        // update lastEvaluated key to dont query same objects
        func loadNotSwipedItems(forCategory category: String) {
            if noMoreTinponsInDatabase {
                return
            } else {
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
                
                let queryExpression = AWSDynamoDBQueryExpression()
                queryExpression.indexName = "category-tinponId-index"
                
                queryExpression.limit = limit as NSNumber
                queryExpression.keyConditionExpression = "category = :category"
                queryExpression.expressionAttributeValues = [":category" : category]
                if lastEvaluatedKey != nil {
                    queryExpression.exclusiveStartKey = lastEvaluatedKey
                }
                
                dynamoDBObjectMapper.query(DynamoDBTinpon.self, expression: queryExpression).continueWith(block: { [weak self] (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                    guard let strongSelf = self else {return nil}
                    
                    if let error = task.error as NSError? {
                        print("The request failed. Error: \(error)")
                    } else if let paginatedOutput = task.result {
                        var tinpons = [Tinpon]()
                        for dynamoDBTinpon in (paginatedOutput.items as? [DynamoDBTinpon])! {
                            tinpons.append(Tinpon.castDynamoDBTinponToTinpon(dynamoDBTinpon: dynamoDBTinpon))
                        }
                        
                        
                        // filter already swiped Tinpons
                        tinpons = strongSelf.tinponWrapper.filterAlreadySwipedTinpons(tinpons: tinpons)
 
                        // check if more tinpons available
                        if let lastEvaluatedKey = task.result?.lastEvaluatedKey {
                            if tinpons.count >= strongSelf.limit {
                                strongSelf.onComplete(tinpons)
                                return nil
                            } else {
                                strongSelf.onComplete(tinpons)
                                strongSelf.lastEvaluatedKey = lastEvaluatedKey
                                strongSelf.loadNotSwipedItems(forCategory: category)
                            }
                        } else {
                            // no more Tinpons in Database
                            strongSelf.noMoreTinponsInDatabase = true
                            strongSelf.onComplete(tinpons)
                            return nil
                        }
                    }
                    return nil
                })
            }
        }
    }
    
    func loadNotSwipedTinponsFromUserCategories(performClousreOnComplete onComplete: @escaping ([Tinpon]) -> Void) {
        let cognitoId = AWSMobileClient.cognitoId
        UserWrapper.getUserAWSTask(cognitoId: cognitoId).continueOnSuccessWith(block: { task in
            let user = task.result as! User
            
            // get Tinpons for every category
            user.tinponCategories?.forEach {category in
                self.tinponsLoader.append(TinponLoader(performClosureOnComplete: onComplete, tinponWrapper: self))
                self.tinponsLoader.last?.loadNotSwipedItems(forCategory: category)
            }
            
            return nil
        })
    }
    
    
    // MARK : Helper
    
    func filterAlreadySwipedTinpons(tinpons: [Tinpon]) -> [Tinpon] {
        var filteredTinpons: [Tinpon] = []
        let context = AppDelegate.viewContext
        
        outerFor: for tinpon in tinpons {
            // filter from already swiped
            let alreadyLoadedTinpons = swiperViewController.tinpons
            for alreadyLoadedTinpon in alreadyLoadedTinpons {
                //print("already tinponName: \(alreadyLoadedTinpon.name)")
                if tinpon.tinponId == alreadyLoadedTinpon.tinponId {
                    print("and equal name: \(tinpon.name)")
                    continue outerFor
                }
            }
            
            print("not EQUAL")
            // filter from CORE
            var fetchSwipedTinpons : [SwipedTinponsCore] = []
            do {
                let fetchRequest : NSFetchRequest<SwipedTinponsCore> = SwipedTinponsCore.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "(tinponId == %@)", tinpon.tinponId!)
                fetchSwipedTinpons = try context.fetch(fetchRequest)
                if fetchSwipedTinpons.count < 1 {
                    filteredTinpons.append(tinpon)
                }
            } catch {
                print("filterTinpons: Fetching Failed")
            }
        }
        return filteredTinpons
    }
    


}
