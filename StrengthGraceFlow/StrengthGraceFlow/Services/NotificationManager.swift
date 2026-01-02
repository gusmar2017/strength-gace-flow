//
//  NotificationManager.swift
//  StrengthGraceFlow
//
//  Manages local notifications for period end tracking
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    // Notification identifiers
    private let periodEndNotification1ID = "period_end_attempt_1"
    private let periodEndNotification2ID = "period_end_attempt_2"

    // UserDefaults keys
    private let attemptsKeyPrefix = "periodEndAttempts_"

    private init() {}

    // MARK: - Authorization

    /// Request notification authorization from user
    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Period End Notifications

    /// Schedule period end notifications (2 attempts)
    /// - Parameters:
    ///   - periodStartDate: The date when the period started
    ///   - avgPeriodLength: Average period length in days
    ///   - cycleId: The cycle ID for tracking attempts
    func schedulePeriodEndNotifications(periodStartDate: Date, avgPeriodLength: Int, cycleId: String) async {
        // Cancel any existing period end notifications
        await cancelPeriodEndNotifications()

        // Check authorization
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            print("Notifications not authorized, skipping scheduling")
            return
        }

        // Calculate expected end date
        let calendar = Calendar.current
        guard let expectedEndDate = calendar.date(byAdding: .day, value: avgPeriodLength, to: periodStartDate) else {
            print("Failed to calculate expected end date")
            return
        }

        // Schedule notification 1: (expectedEnd + 1 day) @ 10 AM
        if let notification1Date = calendar.date(byAdding: .day, value: 1, to: expectedEndDate) {
            await scheduleNotification(
                identifier: periodEndNotification1ID,
                title: "Period End Check-In",
                body: "Has your period ended? Tap to record your period end date for more accurate predictions.",
                triggerDate: notification1Date,
                hour: 10,
                minute: 0
            )
        }

        // Schedule notification 2: (expectedEnd + 3 days) @ 10 AM
        if let notification2Date = calendar.date(byAdding: .day, value: 3, to: expectedEndDate) {
            await scheduleNotification(
                identifier: periodEndNotification2ID,
                title: "Period End Check-In",
                body: "Last reminder: Track your period end date to help us personalize your cycle insights.",
                triggerDate: notification2Date,
                hour: 10,
                minute: 0
            )
        }

        // Reset attempt count for this cycle
        resetAttemptCount(for: cycleId)

        print("Scheduled period end notifications for cycle \(cycleId)")
    }

    /// Schedule a single notification at a specific date and time
    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        triggerDate: Date,
        hour: Int,
        minute: Int
    ) async {
        // Only schedule if the date is in the future
        guard triggerDate > Date() else {
            print("Skipping notification \(identifier) - date is in the past")
            return
        }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "PERIOD_END"
        content.userInfo = ["type": "period_end"]

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            print("Scheduled notification: \(identifier) for \(triggerDate)")
        } catch {
            print("Error scheduling notification \(identifier): \(error)")
        }
    }

    /// Cancel all period end notifications
    func cancelPeriodEndNotifications() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            periodEndNotification1ID,
            periodEndNotification2ID
        ])
        print("Cancelled period end notifications")
    }

    // MARK: - Attempt Tracking

    /// Check if we should show the period end prompt for a given cycle
    /// - Parameter cycleId: The cycle ID to check
    /// - Returns: True if attempts < 2, false otherwise
    func shouldShowPeriodEndPrompt(for cycleId: String) -> Bool {
        let attempts = getAttemptCount(for: cycleId)
        return attempts < 2
    }

    /// Increment attempt count for a cycle
    /// - Parameter cycleId: The cycle ID to increment
    func incrementAttemptCount(for cycleId: String) {
        let key = attemptsKeyPrefix + cycleId
        let currentCount = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(currentCount + 1, forKey: key)
        print("Incremented attempt count for cycle \(cycleId): \(currentCount + 1)")
    }

    /// Get current attempt count for a cycle
    /// - Parameter cycleId: The cycle ID to check
    /// - Returns: Number of attempts (0 if no attempts yet)
    private func getAttemptCount(for cycleId: String) -> Int {
        let key = attemptsKeyPrefix + cycleId
        return UserDefaults.standard.integer(forKey: key)
    }

    /// Reset attempt count for a cycle (called when scheduling new notifications)
    /// - Parameter cycleId: The cycle ID to reset
    private func resetAttemptCount(for cycleId: String) {
        let key = attemptsKeyPrefix + cycleId
        UserDefaults.standard.set(0, forKey: key)
        print("Reset attempt count for cycle \(cycleId)")
    }
}
