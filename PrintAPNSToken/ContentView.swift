//
//  ContentView.swift
//  PrintAPNSToken
//
//  Created by Lawrence Forooghian on 13/06/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var authorizationResult: Result<Bool, Error>?

    var body: some View {
        VStack(spacing: 10) {
            if let authorizationResult {
                switch authorizationResult {
                case .success(true):
                    EmptyView()
                case .success(false):
                    Text("Authorization not granted to display notifications.")
                case .failure(let error):
                    Text("Failed to get permission to display notifications: \(error.localizedDescription)")
                }
            }

            switch appDelegate.remoteNotificationsRegistrationState {
            case .inactive:
                EmptyView()
            case .registering:
                Text("Registering for remote notifications…")
                ProgressView()
            case .terminated(.success(let tokenData)):
                Text("Registered for remote notifications; device token is \(tokenData.base64EncodedString())")
                ShareLink("Share Base64 device token", item: tokenData.base64EncodedString())
            case .terminated(.failure(let error)):
                Text("Failed to register for remote notifications: \(error.localizedDescription)")
            }

            Button(appDelegate.remoteNotificationsRegistrationState.isSuccess ? "Re-register for remote notifications" : "Register for remote notifications") {
#if os(iOS)
                Task { @MainActor in
                    do {
                        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: .alert)
                        authorizationResult = .success(granted)
                    } catch {
                        authorizationResult = .failure(error)
                        return
                    }

                    UIApplication.shared.registerForRemoteNotifications()
                    appDelegate.remoteNotificationsRegistrationState = .registering
                }
#endif
            }.disabled(appDelegate.remoteNotificationsRegistrationState.isRegistering)
        }
        .padding()
    }
}
