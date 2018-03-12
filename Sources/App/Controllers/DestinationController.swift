//
//  DestinationController.swift
//  App
//
//  Created by Daniel Skevarp on 2018-03-12.
//


import Foundation
import Vapor
import HTTP
import AuthProvider
import MySQL



final class DestinationController : SuperController {

    func createNewDestination(forTrip _trip : Int?) throws -> ResponseRepresentable {
        do {
            let me = try self.request.user()
            let destData = try createNewDestinationPayload.init(json: (self.message?.payload.asJSON())!)
            
            let dest = try Destination.createNewDestination(startDate: destData.destinationStartDate,
                                                            endDate: destData.destinationEndDate,
                                                            isPrivate: destData.isPrivate,
                                                            creator: me,
                                                            trip: _trip,
                                                            name: destData.name)
            
            var myFollowers = [User]()
            for follower in (me.followers) {
                let user = try follower.getFollowerUser()
                myFollowers.append(user)
            }
            
            try me.createFeedData(feedObjectType: dest.objectType, feedObjectId: dest.objectIdentifier, timestamp: Date().timeIntervalSince1970, feedType: .destinationCreated, users: myFollowers)
            
            if let image = destData.destinationImage {
                guard let base64data = Data(base64Encoded: image.base64, options: .ignoreUnknownCharacters) else {
                    throw TriprAPIMessageError.invalidData(field: "destinationImage")
                }
                let file = try FileHandler.uploadBase64File(user:me, file: base64data, filename: image.filename)
                dest.destinationImage = file.id?.int
                try dest.save()
            }
            
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

}


