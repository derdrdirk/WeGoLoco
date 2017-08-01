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
    var cognitoId: String!
    
    init(swiperViewController: SwiperViewController) {
        self.swiperViewController = swiperViewController
    }
    
    class TinponLoader {
        var tinponWrapper: TinponWrapper!
        var limit = 5
        var noMoreTinponsInDatabase = false
        var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]? = nil
        var onComplete: ([DynamoDBTinpon]) -> Void
        
        init(performClosureOnComplete onComplete: @escaping ([DynamoDBTinpon]) -> Void, tinponWrapper: TinponWrapper) {
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
                queryExpression.indexName = "category-active-index"
                
                queryExpression.limit = limit as NSNumber
                queryExpression.keyConditionExpression = "category = :category AND active = :active"
                queryExpression.expressionAttributeValues = [":category" : category, ":active": NSNumber(value: 1)]
                if lastEvaluatedKey != nil {
                    queryExpression.exclusiveStartKey = lastEvaluatedKey
                }
                
                dynamoDBObjectMapper.query(DynamoDBTinpon.self, expression: queryExpression).continueWith(block: { [weak self] (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                    guard let strongSelf = self else {return nil}
                    
                    if let error = task.error as NSError? {
                        print("The request failed. Error: \(error)")
                    } else if let paginatedOutput = task.result {
                        var tinpons = paginatedOutput.items as! [DynamoDBTinpon]
                        
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
    
    func loadNotSwipedTinponsFromUserCategories(performClousreOnComplete onComplete: @escaping ([DynamoDBTinpon]) -> Void) {
//        UserWrapper.getUserIdAWSTask().continueOnSuccessWith{ [weak self] task in
//            guard let strongSelf = self else { return nil }
//            let cognitoId = task.result! as String
//            strongSelf.cognitoId = cognitoId
//            return UserWrapper.getUserAWSTask(cognitoId: cognitoId)
//        }.continueWith(block: { task in
//            if let error = task.error {
//                print("ERROR---TinponWrapper-loadNotSwipedTinponsFromUserCategories: \(error)")
//            } else {
//                let user = task.result as! DynamoDBUser
//                
//                // get Tinpons for every category
//                user.tinponCategories?.forEach {category in
//                    self.tinponsLoader.append(TinponLoader(performClosureOnComplete: onComplete, tinponWrapper: self))
//                    self.tinponsLoader.last?.loadNotSwipedItems(forCategory: category)
//                }
//            }
//            
//            return nil
//        })
    }
    
    static func loadAllTinponsForSignedInUser(onComplete: @escaping (([DynamoDBTinpon]) -> ())) {
        UserWrapper.getUserIdAWSTask().continueOnSuccessWith{ task in
            let cognitoId = task.result! as String
            
            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.indexName = "userId-index"
            
            queryExpression.keyConditionExpression = "userId = :userId"
            queryExpression.expressionAttributeValues = [":userId" : cognitoId]
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            return dynamoDBObjectMapper.query(DynamoDBTinpon.self, expression: queryExpression)
        }.continueWith{ task in
            if let error = task.error {
                print("loading user Tinpons failed. Error: \(error.localizedDescription)")
            } else if let paginatedOutput = task.result! as? AWSDynamoDBPaginatedOutput {
                let tinpons = paginatedOutput.items as! [DynamoDBTinpon]
                onComplete(tinpons)
            }
            return nil
        }
    }
    
    
    // MARK : Helper
    
    func filterAlreadySwipedTinpons(tinpons: [DynamoDBTinpon]) -> [DynamoDBTinpon] {
        var filteredTinpons: [DynamoDBTinpon] = []
        let context = AppDelegate.viewContext
        
//        outerFor: for tinpon in tinpons {
//            // filter from already swiped
//            let alreadyLoadedTinpons = swiperViewController.tinpons
//            for alreadyLoadedTinpon in alreadyLoadedTinpons {
//                //print("already tinponName: \(alreadyLoadedTinpon.name)")
//                if tinpon.tinponId == alreadyLoadedTinpon.tinponId {
//                    continue outerFor
//                }
//            }
//            
//            // filter from CORE
//            var fetchSwipedTinpons : [SwipedTinponsCore] = []
//            do {
//                let fetchRequest : NSFetchRequest<SwipedTinponsCore> = SwipedTinponsCore.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "(tinponId == %@ AND userId == %@) ", tinpon.tinponId!, self.cognitoId)
//                fetchSwipedTinpons = try context.fetch(fetchRequest)
//                if fetchSwipedTinpons.count < 1 {
//                    filteredTinpons.append(tinpon)
//                } else {
//                   //print("Tinpon filtered \(tinpon.name)")
//                }
//            } catch {
//                print("filterTinpons: Fetching Failed")
//            }
//        }
        return filteredTinpons
    }
    


}
