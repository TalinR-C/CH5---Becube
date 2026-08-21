//
//  BoxBreathingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

//still need to link and navigate the practice based on the skill ID
import Foundation
import SwiftUI

struct BoxBreathingView: View {
    @State var viewModel: BoxBreathingViewModel
    
    var body: some View {
        ZStack{
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("Warm Cream"),
                    Color("Light Cream")
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack {
                Text("BOX BREATHING")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.brown)
                    .padding(.bottom, 164)

                ZStack {
                    Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.boxBreathingCircle.opacity(1),
                                        Color.boxBreathingCircle.opacity(0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 135
                                )
                            )
                            .frame(width: 250, height: 250)
                            .blur(radius: 20)
                            .scaleEffect(viewModel.circleScale)
                    
                    Rectangle()
                        .stroke(Color.darkBrown, lineWidth: 1.86)
                        .frame(width: viewModel.squareSize, height: viewModel.squareSize)

                    Text(viewModel.currentPhase.label)
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundStyle(.brown)

                    Circle()
                        .fill(Color.darkBrown)
                        .frame(width: 23.15, height: 23.15)
                        .position(viewModel.dotPosition)
                        
                }
                .frame(width: viewModel.squareSize, height: viewModel.squareSize)

                Spacer()

                Button("Done") {
                    viewModel.stop()
                    // TODO: once PracticeSession/PracticeService exist, this is where
                    
                }
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.darkBrown)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                
            }
            .padding(30)
        }
        
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

#Preview {
    BoxBreathingView(viewModel: BoxBreathingViewModel(skillID: "box_breathing"))
}

