//
//  Notifiable.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-08.
//

import Foundation
import FluentProvider

protocol Notifiable : ObjectIdentifiable{
    var notifications : [Notification] { get }
    func createNotification(notificationType : NotificationType, parameters _params: [NotificationParameter]?) throws -> Notification
}

extension Notifiable {
    
    var notifications : [Notification] {
        get {
            do {
                let notifications = try Notification.makeQuery().filter("receiver", .equals, self.objectIdentifier).sort("updated_at", .descending).all()
                return notifications
            }catch{
                return [Notification]()
            }
        }
    }
    
    func createNotification(notificationType _type: NotificationType, parameters _params: [NotificationParameter]?) throws -> Notification
    {
        let notif = Notification.init(receiver: self.objectIdentifier, notificationType: _type)
        try notif.save()
        if let notifparams = _params {
            for param in notifparams {
                let parameter = NotificationParameterData.init(notifcation_id: notif.id!,
                                                               parameter: param.paramId,
                                                               relatedObject: param.relatedObject,
                                                               relatedObjectId: param.relatedObjectId)
                try parameter.save()
            }
        }
        return notif
    }
}
