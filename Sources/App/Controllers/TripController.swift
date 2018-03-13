//
//  TripController.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-06.
//

import Foundation
import Vapor
import HTTP
import AuthProvider
import MySQL



final class TripController : SuperController {
    
    
    func createNewDestination() throws -> ResponseRepresentable {
        do {
            let me = try self.request.user()
            guard let trip = try? request.parameters.next(Trip.self) else {
                return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
            }
            
            let destData = try createNewDestinationPayload.init(json: (self.message?.payload.asJSON())!)
            
            let dest = try Destination.createNewDestination(arrivalDate: destData.arrivalDate,
                                                            departureDate: destData.departureDate,
                                                            isPrivate: destData.isPrivate,
                                                            creator: me,
                                                            trip: trip.id?.int,
                                                            name: destData.name)
            
            ///create , save and add the destination image if it exists
            if let image = destData.destinationImage {
                guard let base64data = Data(base64Encoded: image.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "destinationImage")
                }
                let file = try FileHandler.uploadBase64File(user:me, file: base64data, filename: image.filename)
                dest.destinationImage = file.id?.int
                try dest.save()
            }
            
            ///All notification stuff and that
            //            we want to add this event to the trips timeline
            try trip.createFeedForMe(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .destinationCreated)
            
            //            as well as the trips followers
            var myFollowers = [User]()
            for follower in (trip.followers) {
                let user = try follower.getFollowerUser()
                myFollowers.append(user)
            }
            
            try me.createFeedData(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .destinationCreated, users: myFollowers)
            
            ///Create notifications for them as well
            try trip.notifyFollowers(notificationType: .DestinationAdded ,
                                     parameters: [(1, trip.objectType, trip.objectIdentifier.int!),
                                                  (2, dest.objectType, dest.objectIdentifier.int!),
                                                  (3, me.objectType, me.objectIdentifier.int!)])
            
            
            return try self.createResponse(payload: try dest.makeJSON(), status: (.ok, "Destination created"))
            
        }catch let error as TriprAPIMessageError{
            return try self.createResponse(payload: "", status: (.error, error.getErrorCode()))
        }catch let error as MySQLError {
            var errorReason = error.reason
            if error.code == MySQL.MySQLError.Code.dupEntry {
                errorReason = "Destination already exists"
            }
            return try self.createResponse(payload: "", status: (.error, errorReason))
        }
        
    }
    
    func inviteUser() throws -> ResponseRepresentable {
        let me = try request.user()
        guard let trip = try? request.parameters.next(Trip.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
        }
        
        guard let user = try? request.parameters.next(User.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "User doesnt exists"))
        }
        
        if !trip.isUserTiedToTrip(user: me){
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "You cant invite to this trip"))
        }
        
        return try self.createResponse(payload: (self.request.json)!, status: (.ok, "Invite sent"))
    }
    
    func updateTrip() throws -> ResponseRepresentable {
        let user = try request.user()
        guard let trip = try? request.parameters.next(Trip.self) else {
             return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
        }
        
        try trip.updateTripFromJSON((self.message?.payload.asJSON())!)
        trip.createFeedData(feedObjectType: trip.objectType, feedObjectId: trip.objectIdentifier, timestamp: Date().timeIntervalSinceNow, feedType: .tripUpdated)
        
        /// Save an return the updated trip.
        try trip.save()
        try trip.notifyFollowers(notificationType: .TripUpdated, parameters: [(paramId : 1, relatedObject: trip.objectType, relatedObjectId: trip.objectIdentifier.int!)])
        
        return try self.createResponse(payload: try trip.getTripDataForUser(user: user), status: (.ok, "Trip updated successfully"))
    }
    
    func addComment() throws -> ResponseRepresentable {
        let user = try self.request.user()
        guard let trip = try? self.request.parameters.next(Trip.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
        }
        
        let commentData = try addCommentPayload.init(json: (self.message?.payload.asJSON())!)
        
        let comment = try trip.addComment(by: user.id!, commment: commentData.text, timestamp: commentData.timestamp)
        
        if let attachments =  commentData.attachments {
            for attachment in attachments{
                guard let base64data = Data(base64Encoded: attachment.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "attachment")
                }
                let file = try FileHandler.uploadBase64File(user:user, file: base64data, filename: attachment.filename)
                let _ = try comment.addAttachment(file: file)
            }
        }
        
        var notifUsers = [User]()
        for follower in trip.followers {
            notifUsers.append(try follower.getFollowerUser())
        }
        
        try trip.createFeedForMe(feedObjectType: comment.objectType, feedObjectId: comment.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .commentAdded)
        
        try trip.notifyFollowers(notificationType: .CommentAdded ,
                                 parameters: [(1, trip.objectType, trip.objectIdentifier.int!),
                                              (2, comment.objectType, comment.objectIdentifier.int!)])
        
        return try self.createResponse(payload: try trip.getTripDataForUser(user: user), status: (.ok, "Comment added"))
    }
    
    func getTripTimeline(request : Request) throws -> ResponseRepresentable {
        guard let trip = try? request.parameters.next(Trip.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
        }
        do {
            let timelineData = try tripTimelineRequestPayload.init(json: (self.message?.payload.asJSON())!)
            
            let data = try trip.getTimelineItems(startIndex: timelineData.startIndex, numberOfFeeds: timelineData.numberOfFeeds)
            
            return try self.createResponse(payload: try data.makeJSON(), status: (.ok, "Trip updated successfully"))
            
        }catch let error{
            return try self.createResponse(payload: (self.request.json)!, status: (.error, error.localizedDescription))
        }
    }
    
    func acceptFollow() throws -> ResponseRepresentable {
        guard let trip = try? self.request.parameters.next(Trip.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "Trip doesnt exists"))
        }
        
        guard let follower = try? self.request.parameters.next(User.self) else {
            return try self.createResponse(payload: (self.request.json)!, status: (.error, "User doesnt exists"))
        }
        
        do {
            let me = try self.request.user()
            try trip.acceptFollowRequest(from: follower.id!, by: me.id!)
            return try self.createResponse(payload: "", status: (.ok, "You have accepted follow request from \(follower.username!) in trip \(trip.name!)"))
            
        }catch let error as TripErrors{
            return try self.createResponse(payload: "", status: (.error, error.errorMessage))
        }
        
        
    }
    
    func getUsersTrips() throws -> ResponseRepresentable {
        guard let user = try? self.request.parameters.next(User.self) else {
            return try self.createResponse(payload: "", status: (.error, "User doesnt exists"))
        }
        
        let me = try self.request.user()
        return try self.createResponse(payload: try Trip.getUsersTrips(user: user, requester: me).makeJSON(), status: (.ok, "Users trips"))
    }
    
    func getTrip() throws -> ResponseRepresentable {
        let user = try self.request.user()
        guard let trip = try? self.request.parameters.next(Trip.self) else {
            return try self.createResponse(payload: "", status: (.error, "Trip doesnt exists"))
        }
        return try trip.getTripDataForUser(user: user)
    }
    
    func createTrip() throws -> ResponseRepresentable {
        do {
            let me = try self.request.user()
            let tripData = try createNewTripPayload.init(json: (self.message?.payload.asJSON())!)
            
            let trip = try Trip.createNewTrip(tripStartDate: tripData.tripStartDate,
                                              tripEndDate: tripData.tripEndDate,
                                              isPrivate: tripData.isPrivate,
                                              creator: me,
                                              name: tripData.name)
            
            var myFollowers = [User]()
            for follower in (me.followers) {
                let user = try follower.getFollowerUser()
                myFollowers.append(user)
            }
            
            try me.createFeedData(feedObjectType: trip.objectType, feedObjectId: trip.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .tripCreated, users: myFollowers)
            
            if let image = tripData.tripImage {
                guard let base64data = Data(base64Encoded: image.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "tripImage")
                }
                let file = try FileHandler.uploadBase64File(user:me, file: base64data, filename: image.filename)
                trip.tripImage = file.id?.int
                try trip.save()
            }
            
            return try self.createResponse(payload: try trip.makeJSON(), status: (.ok, "Trip created"))
            
        }catch let error as TriprAPIMessageError{
            return try self.createResponse(payload: "", status: (.error, error.getErrorCode()))
        }catch let error as MySQLError {
            var errorReason = error.reason
            if error.code == MySQL.MySQLError.Code.dupEntry {
                errorReason = "Trip already exists"
            }
            return try self.createResponse(payload: "", status: (.error, errorReason))
        }
    }
    
}
