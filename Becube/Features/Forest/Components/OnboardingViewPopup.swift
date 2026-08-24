import SwiftUI
import Combine

struct OnboardingPopupView: View {
    // The three phrases to cycle through
    let benefits = [
        "Give you more choices when\nhandling difficult situations",
        "Help you understand\nyourself better",
        "Help you build healthier\nhabits"
    ]
    
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    // Action to trigger when the user proceeds
    var onLearnSkillTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text("Build your skill garden.")
                .font(.title2)
                .fontWeight(.bold)
            
            // Central Info Card
            VStack(spacing: 16) {
                Text("Coping skills can help you")
                    .font(.headline)
                    .fontWeight(.bold)
                
                // Animated Text Area
                Text(benefits[currentIndex])
                    .multilineTextAlignment(.center)
                    .frame(height: 50) // Fixed height prevents the UI from bouncing
                    .id(currentIndex)  // Forces SwiftUI to transition the view change
                    .transition(.opacity)
                
                // Gray Placeholder Area
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .frame(height: 180)
            }
            .padding()
            .overlay(
                // The red border shown in the diagram
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 1)
            )
            .padding(.horizontal)
            
            // Primary Button
            Button(action: onLearnSkillTapped) {
                Text("Learn your first skill")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 30)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
        // Cycles the text animation every 3 seconds
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % benefits.count
            }
        }
    }
}
