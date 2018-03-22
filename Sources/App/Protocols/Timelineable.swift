//
//  Timelineable.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-05.
//

import Foundation
import FluentProvider

protocol Timelineable: Followable, Model {
    
    func createFeedData(feedObjectType _feedObjectType : String, feedObjectId _feedObjectId : Identifier, timestamp _time : Double, feedType _type : FeedType) 
    func getTimelineItems( startIndex _idx : Int , numberOfFeeds _limitation : Int) throws -> [Feed]
    func getTimelineItemsAsJSON( startIndex _idx : Int , numberOfFeeds _limitation : Int) throws -> JSON
    func createFeedData(feedObjectType _feedObjectType : String,feedObjectId _feedObjectId : Identifier,timestamp _time : Double,feedType _type : FeedType,users : [User]) throws
}


extension Timelineable {
    
    func getTimelineItemsAsJSON(startIndex _idx : Int = 0 , numberOfFeeds _limitation : Int = 25) throws -> JSON
    {
        var json = JSON()
        let feeds = try Feed.database?.raw("SELECT * FROM `feeds` INNER JOIN `feed_keyss` ON `feeds`.`id` = `feed_keyss`.`feedId` WHERE `feed_keyss`.`objectKey` = '\(self.objectKey)' ORDER BY `timestamp` DESC LIMIT \(_idx) , \(_limitation)")
        guard let data = feeds?.wrapped.array else{
            return json
        }
        
        var jsonArray = [JSON]()
        for feed in data {
            let row = Row.init(feed, in: feeds?.context)
            let afeed = try Feed.init(row: row)
            let jfeed = try afeed.getFullFeedDataAsJSON()
            jsonArray.append(jfeed)
        }
        try json.set("Feed", jsonArray)
        return json
    }
    
    func getTimelineItems( startIndex _idx : Int = 0 , numberOfFeeds _limitation : Int = 25) throws -> [Feed]
    {
        var feedArray = [Feed]()
        print(self.objectKey)
        let feeds = try Feed.database?.raw("SELECT * FROM `feeds` INNER JOIN `feed_keyss` ON `feeds`.`id` = `feed_keyss`.`feedId` WHERE `feed_keyss`.`objectKey` = '\(self.objectKey)' ORDER BY `timestamp` DESC LIMIT \(_idx) , \(_limitation)")
        guard let data = feeds?.wrapped.array else{
            return [Feed]()
        }
        
        for feed in data {
            let row = Row.init(feed, in: feeds?.context)
            let afeed = try Feed.init(row: row)
            feedArray.append(afeed)
        }
        return feedArray
    }
    
    func createFeedForMe(feedObjectType _feedObjectType : String,
                         feedObjectId _feedObjectId : Identifier,
                         timestamp _time : Double,
                         feedType _type : FeedType) throws {
        
        let feed = Feed.init(entryObjectType: self.objectType,
                             entryObjectId: self.objectIdentifier,
                             feedObjectType: _feedObjectType,
                             feedObjectId: _feedObjectId,
                             timestamp: _time,
                             feedType: _type)
        try feed.save()
        
        let feedKey = FeedKeys.init(objectKey: self.objectKey, feedId: feed.id!)
        try feedKey.save()
        
    }
    
    func createFeedData(feedObjectType _feedObjectType : String,
                        feedObjectId _feedObjectId : Identifier,
                        timestamp _time : Double,
                        feedType _type : FeedType,
                        users : [User]) throws {
        
        DispatchQueue.global(qos: .background).async {
            do{
                var feedSaved = false
                let feed = Feed.init(entryObjectType: self.objectType,
                                     entryObjectId: self.objectIdentifier,
                                     feedObjectType: _feedObjectType,
                                     feedObjectId: _feedObjectId,
                                     timestamp: _time,
                                     feedType: _type)
                
                
                for user in users {
                    if feedSaved == false {
                        try feed.save()
                        feedSaved = true
                    }
                    let feedKey = FeedKeys.init(objectKey: user.objectKey, feedId: feed.id!)
                    try feedKey.save()
                }
            }catch {
                
            }
        }
        
    }
    
    func createFeedData(feedObjectType _feedObjectType : String, feedObjectId _feedObjectId : Identifier, timestamp _time : Double, feedType _type : FeedType) {
        DispatchQueue.global(qos: .background).async {
            do{
                var feedSaved = false
                let feed = Feed.init(entryObjectType: self.objectType,
                                     entryObjectId: self.objectIdentifier,
                                     feedObjectType: _feedObjectType,
                                     feedObjectId: _feedObjectId,
                                     timestamp: _time,
                                     feedType: _type)
                
                
                for follower in self.followers {
                    if feedSaved == false {
                        try feed.save()
                        feedSaved = true
                    }
                    let feedKey = FeedKeys.init(objectKey: try follower.getFollowerUser().objectKey, feedId: feed.id!)
                    try feedKey.save()
                }
            }catch {
                
            }
        }
    }
    
}
