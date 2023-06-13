//
//  PrintAPNSTokenApp.swift
//  PrintAPNSToken
//
//  Created by Lawrence Forooghian on 13/06/2023.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

@main
struct PrintAPNSTokenApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
#endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var remoteNotificationsRegistrationState: RemoteNotificationsRegistrationState = .inactive

    enum RemoteNotificationsRegistrationState {
        case inactive
        case registering
        case terminated(Result<Data, Error>)

        var isRegistering: Bool {
            if case .registering = self {
                return true
            } else {
                return false
            }
        }

        var isSuccess: Bool {
            if case .terminated(.success) = self {
                return true
            } else {
                return false
            }
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        remoteNotificationsRegistrationState = .terminated(.success(deviceToken))
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        remoteNotificationsRegistrationState = .terminated(.failure(error))
    }
}
#endif
