import SwiftUI
import shared

struct HomeView: View {
    private let greeting = Greeting().greet()

    var body: some View {
        VStack(spacing: 16) {
            Text("Apricot")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(greeting)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
}
