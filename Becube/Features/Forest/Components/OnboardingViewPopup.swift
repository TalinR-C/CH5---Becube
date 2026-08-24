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
        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
            VStack(spacing: 30) {
                
                Text("Build your skill garden.")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Central Info Card
                VStack(spacing: 16) {
                    Text("Coping skills can help you")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 5){
                        HStack{Text("1."); Text("Give you more choices when handling difficult situations")}
                        HStack{Text("2."); Text("Help you understand yourself better")}
                        HStack{Text("3."); Text("Help you build healthier habits")}
                    }.font(.system(size: 14))
                }
                .padding()
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
            .padding()
            // Cycles the text animation every 3 seconds
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentIndex = (currentIndex + 1) % benefits.count
                }
            }
        }
        .frame(width: 380)
        
        
    }
}
