// MARK: - ViewModel

// NotificationService.swift
import SwiftUI

protocol NotificationServiceProtocol: AnyObject {
    func requestPushAuthorization() async -> Bool
}

class NotificationService: NotificationServiceProtocol {
    func requestPushAuthorization() async -> Bool {
        do {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
        } catch {
            print("Error requesting push authorization:", error)
            return false
        }
    }
}
