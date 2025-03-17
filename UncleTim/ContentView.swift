//
//  ContentView.swift
//  PingMe
//
//  Created by Mert Bulan on 06.12.24.
//

import SwiftUI
import CloudKit
import Combine

struct ContentView: View {
    @EnvironmentObject var notifications: Notifications
    @Environment(\.scenePhase) var scenePhase
    @State var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if notifications.lists.isEmpty {
                    Button("Request notification permission") {
                        requestNotificationPermissions()
                    }.buttonStyle(.borderedProminent)
                    
                    Button("Subscribe to notifications") {
                        subscribeToNotifications()
                    }.buttonStyle(.borderedProminent)
                } else {
                    if isLoading {
                        ProgressView()
                    }
                    List {
                        ForEach(notifications.lists) { notification in
                            VStack(alignment: .leading) {
                                HStack {
                                    Spacer()
                                    Text("\(notification.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.bottom, 8)
                                Text(notification.title).bold()
                                Text(notification.content)
                            }
                        }
                    }
                    .listRowSpacing(16.0)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    isLoading = true
                    fetchNotifications()
                    UIApplication.shared.applicationIconBadgeNumber = 0

                }
            }
            .navigationTitle("Notifications")
        }
    }
    
    private func fetchNotifications() {
        NotificationsManager.fetch { (results) in
            switch results {
            case .success(let newNotifications):
                self.notifications.lists = newNotifications
                isLoading = false
            case .failure(let error):
                print(error)
            }
        }
    }
}

func requestNotificationPermissions() {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
        if let error = error {
            print(error)
        } else if success {
            print("Notification permissions success!")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            print("Notification permissions failure.")
        }
    }
}

func subscribeToNotifications() {
    let predicate = NSPredicate(value: true)
    let subscription = CKQuerySubscription(recordType: "Notification", predicate: predicate, subscriptionID: "app_store_connect", options: .firesOnRecordCreation)
    let notification = CKSubscription.NotificationInfo()

    notification.titleLocalizationKey = "%1$@"
    notification.titleLocalizationArgs = ["title"]
    
    notification.alertLocalizationKey = "%1$@"
    notification.alertLocalizationArgs = ["content"]
        
    notification.shouldBadge = true
        
    notification.soundName = "default"
    
    subscription.notificationInfo = notification
    
    CKContainer.default().publicCloudDatabase.save(subscription) { returnedSubscription, returnedError in
        if let error = returnedError {
            print(error)
        } else {
            print("Successfully subscribed to notifications!")
        }
    }
}

#Preview {
    ContentView().environmentObject(NotificationsManager())
}
