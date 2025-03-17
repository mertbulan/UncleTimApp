//
//  CloudKitUtility.swift
//  PingMe
//
//  Created by Mert Bulan on 06.12.24.
//

import Foundation
import CloudKit

struct CKNotification: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var title: String = ""
    var content: String = ""
    var date: Date = Date.now
}

class Notifications: ObservableObject {
    @Published var lists: [CKNotification] = []
}

class NotificationsManager: ObservableObject {
    static let database = CKContainer.default().publicCloudDatabase
    
    class func fetch(completion: @escaping (Result<[CKNotification], Error>) -> ()) {
        let predicate = NSPredicate(value: true)
        let name = NSSortDescriptor(key: "date", ascending: false)
        let query = CKQuery(recordType: "Notification", predicate: predicate)
        query.sortDescriptors = [name]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "content", "date"]
        operation.resultsLimit = 20
        
        var newNotifications = [CKNotification]()
        
        operation.recordMatchedBlock = { recordId, result in
            switch result {
               case let .success(record):
                    var notification = CKNotification()
                    notification.recordID = recordId
                    notification.title = record["title"] as! String
                    notification.content = record["content"] as! String
                    notification.date = record["date"] as! Date
                    newNotifications.append(notification)
               case let .failure(error):
                    print("Error: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success(newNotifications))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
        
        database.add(operation)
    }
}
