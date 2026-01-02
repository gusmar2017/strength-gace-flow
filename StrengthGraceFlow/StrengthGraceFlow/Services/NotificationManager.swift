//
//  NotificationManager.swift
//  StrengthGraceFlow
//
//  Manages period start reminder notifications
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager {
    static let shared = NotificationManager()

    // MARK: - Test Mode
    // Set this to true to schedule notifications 1-2 minutes in the future for testing
    // ⚠️ REMEMBER TO SET BACK TO FALSE BEFORE PRODUCTION
    var testMode = false

    private init() {}

    // MARK: - Authorization

    /// Request notification permission from user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            return false
        }
    }

    /// Check current notification authorization status
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        let status = await getAuthorizationStatus()
        return status == .authorized || status == .provisional
    }

    // MARK: - Period Start Notifications

    /// Schedule period start reminder notifications
    /// - Parameters:
    ///   - periodStartDate: The date when the current period started
    ///   - avgCycleLength: Average cycle length in days
    ///   - cycleId: The cycle ID for tracking attempts
    func schedulePeriodStartNotifications(
        periodStartDate: Date,
        avgCycleLength: Int,
        cycleId: String
    ) async {
        // Cancel any existing period start notifications
        await cancelPeriodStartNotifications()

        let attempt1Date: Date
        let attempt2Date: Date

        if testMode {
            // TEST MODE: Schedule notifications 1 and 2 minutes from now
            print("🧪 TEST MODE: Scheduling notifications 1-2 minutes in the future")
            guard let date1 = Calendar.current.date(byAdding: .minute, value: 1, to: Date()),
                  let date2 = Calendar.current.date(byAdding: .minute, value: 2, to: Date()) else {
                print("Failed to calculate test dates")
                return
            }
            attempt1Date = date1
            attempt2Date = date2
        } else {
            // PRODUCTION MODE: Normal scheduling
            // Calculate predicted next period start
            guard let predictedStartDate = Calendar.current.date(
                byAdding: .day,
                value: avgCycleLength,
                to: periodStartDate
            ) else {
                print("Failed to calculate predicted period start date")
                return
            }

            // Schedule Attempt 1: Day AFTER predicted start (+1 day)
            guard let date1 = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: predictedStartDate
            ) else {
                print("Failed to calculate attempt 1 date")
                return
            }

            // Schedule Attempt 2: 3 days after predicted start (+3 days)
            guard let date2 = Calendar.current.date(
                byAdding: .day,
                value: 3,
                to: predictedStartDate
            ) else {
                print("Failed to calculate attempt 2 date")
                return
            }

            attempt1Date = date1
            attempt2Date = date2
        }

        await scheduleNotification(
            date: attempt1Date,
            attemptNumber: 1,
            cycleId: cycleId
        )

        await scheduleNotification(
            date: attempt2Date,
            attemptNumber: 2,
            cycleId: cycleId
        )

        print("✅ Scheduled 2 period start notifications for cycle \(cycleId)")
        print("   Attempt 1: \(attempt1Date)")
        print("   Attempt 2: \(attempt2Date)")
    }

    /// Schedule a single notification
    private func scheduleNotification(
        date: Date,
        attemptNumber: Int,
        cycleId: String
    ) async {
        let content = UNMutableNotificationContent()

        // Warm, supportive notification text aligned with brand voice
        if attemptNumber == 1 {
            content.title = "Checking in 💜"
            content.body = "Has your period started? Tap to log and stay in sync with your cycle."
        } else {
            content.title = "Period tracking check-in"
            content.body = "Just checking - time to log your period? Staying consistent helps us support you better."
        }

        content.sound = .default
        content.badge = 1

        // Add metadata for notification handling
        content.userInfo = [
            "type": "period_start",
            "cycleId": cycleId,
            "attemptNumber": attemptNumber
        ]

        let trigger: UNNotificationTrigger

        if testMode {
            // TEST MODE: Use time interval trigger (fires in X seconds)
            let timeInterval = date.timeIntervalSinceNow
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(timeInterval, 1), // Minimum 1 second
                repeats: false
            )
            print("🧪 Notification will fire in \(Int(timeInterval)) seconds")
        } else {
            // PRODUCTION MODE: Use calendar trigger (fires at specific date/time)
            // Set notification time to 9 AM
            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: date
            )
            dateComponents.hour = 9
            dateComponents.minute = 0

            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )
        }

        let identifier = "period_start_attempt_\(attemptNumber)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled notification: \(identifier) for \(date)")
        } catch {
            print("❌ Error scheduling notification: \(error.localizedDescription)")
        }
    }

    /// Cancel all period start notifications
    func cancelPeriodStartNotifications() async {
        let identifiers = [
            "period_start_attempt_1",
            "period_start_attempt_2"
        ]

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )

        print("🗑️ Cancelled all period start notifications")
    }

    /// Check if we should show the period start prompt based on current state
    /// This is used to determine if we should show UI prompts in the app
    func shouldShowPeriodStartPrompt(lastPeriodStart: Date, avgCycleLength: Int) -> Bool {
        let calendar = Calendar.current

        // Calculate predicted next period start
        guard let predictedStartDate = calendar.date(
            byAdding: .day,
            value: avgCycleLength,
            to: lastPeriodStart
        ) else {
            return false
        }

        // Show prompt if we're past the predicted start date
        let today = calendar.startOfDay(for: Date())
        let predictedStart = calendar.startOfDay(for: predictedStartDate)

        return today >= predictedStart
    }
}
