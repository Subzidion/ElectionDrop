import SwiftUI

struct ContentView: View {
    init() {
        requestPushAuthorization();
    }
    
    var body: some View {
        VStack {
            ElectionView()
        }
    }
}

func requestPushAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Push notifications allowed")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
