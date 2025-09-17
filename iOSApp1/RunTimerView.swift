import SwiftUI
import UserNotifications

struct RunTimerView: View {
    @State private var secondsRemaining: Int = 10 * 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 24) {
            Text("Coffee Run Timer")
                .font(.title.bold())

            Text(timeString(from: secondsRemaining))
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 16) {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning ? pause() : start()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") { reset() }
                    .buttonStyle(.bordered)

                Menu("Preset") {
                    Button("5 min") { setPreset(5 * 60) }
                    Button("10 min") { setPreset(10 * 60) }
                    Button("15 min") { setPreset(15 * 60) }
                }
            }
            .font(.title3)
            .padding(.top, 8)

            Text("Start the timer and collect orders before it hits 0.")
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .onAppear { requestNotifPermission() }
        .onDisappear { invalidate() }
    }

    private func start() {
        guard timer == nil else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                invalidate()
                isRunning = false
                notifyTimerDone()
                Haptics.success()
            }
        }
    }

    private func pause() { invalidate(); isRunning = false }
    private func reset() { invalidate(); secondsRemaining = 10 * 60; isRunning = false }
    private func setPreset(_ s: Int) { secondsRemaining = s }
    private func invalidate() { timer?.invalidate(); timer = nil }
    private func timeString(from s: Int) -> String { String(format: "%02d:%02d", s/60, s%60) }

    // MARK: - Notifications (optional)
    private func requestNotifPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    private func notifyTimerDone() {
        let content = UNMutableNotificationContent()
        content.title = "Coffee Run"
        content.body = "Timer finished — place the order!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
}

#Preview { RunTimerView() }
