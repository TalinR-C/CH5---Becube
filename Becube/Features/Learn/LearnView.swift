//
//  LearnView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI

struct LearnView: View {

    @State var viewModel: LearnViewModel

    @Environment(\.dismiss) private var dismiss
    // pulls the system's built-in "go back" action out of the environment
    

    var body: some View {
        ZStack{
            Color("LearnBackground")
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    
//                    captionCard(text: "Box Breathing", tailPosition: .bottomLeft)

                    header /// custom top row: back button + skill name
                    
                        ///Current state title
                        Text(viewModel.currentPage.title)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.brown)
                    

                    ScrollView{
                            if viewModel.skill != nil {
                                
                                pageContent
                                
                            } else {
                                
                                ProgressView()
                                
                            }
                    }
                    .id(viewModel.currentPage)
                    

                    progressBar /// the row of 3 capsule segments showing page progress

                    Group {
                        if viewModel.isLastPage {
                            NavigationLink {
                                PracticeDestinationView(skillID: viewModel.skillID)
                                // NOW this is correct — as a NavigationLink's destination closure,
                                // SwiftUI actually builds and pushes this view when tapped,
                                // instead of the value being silently discarded
                            } label: {
                                practiceButtonLabel(text: "Practice")
                            }
                        } else {
                            Button {
                                viewModel.goToNextPage()
                            } label: {
                                practiceButtonLabel(text: "Next")
                            }
                        }
                    }

                    NavigationLink {
                        
                        PracticeDestinationView(skillID: viewModel.skillID)
                        
                    } label: {
                        Text("Jump Straight to Practice")
                            .font(.footnote)
                            .underline()
                            .foregroundStyle(Color.brown)
                    }
                    .opacity(viewModel.isLastPage ? 0 : 1)
                    .disabled(viewModel.isLastPage)
                    
                }
                .padding()
            }

        .task {
            // runs automatically, once, the moment this View first appears on screen
            viewModel.loadSkill() // triggers the ViewModel to fetch the matching CopingSkill
        }
        .navigationBarBackButtonHidden(true)
        // hides the system's automatic back button, since we're drawing our own in "header"
        .toolbar(.hidden, for: .navigationBar)
        // hides the system's navigation bar entirely, so only our custom header shows
    }

    private var header: some View {
        ZStack{
            
            Text(viewModel.skillName)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.brown)
            
            HStack {
                Button {
                    if viewModel.isFirstPage {
                        dismiss()
                    } else {
                        viewModel.goToPreviousPage()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18.51, weight: .semibold))
                        .foregroundColor(Color(.systemBrown))
                        .frame(width: 46.75, height: 46.75)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.6))
                        )
                        .overlay(
                            Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }

                Spacer()
                
            }
        }
    }

    /// progress bar to show the learning state
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(Array(LearnViewModel.Page.allCases.enumerated()), id: \.offset) { index, _ in
                
                Capsule()
                    .fill(
                        index == viewModel.currentPageIndex
                        ? Color.brown   // filled color if this segment should be "lit up"
                        : Color.brown.opacity(0.3) // faded gray if it hasn't been reached yet
                    )
                    .frame(height: 7) // makes each segment a thin horizontal bar
            }
        }
    }

    @ViewBuilder
    // required whenever a computed property's different branches return different View types
    private var pageContent: some View {
        switch viewModel.currentPage {

        case .how:
            howStepsCard // shows the numbered steps card

        case .when:
            VStack(spacing: 25) {
                Image("BoxBreathingLearn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 346, height: 402)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            
                            .shadow(
                                color: Color("BlueShadow"),
                                radius: 4,
                                x: 0,
                                y: 4)
                    )

                captionCard(text: viewModel.currentPageText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.brown)
                
                // the small text box below the image, reused via a helper function
            }

        case .why:
            VStack(spacing: 12) {
                ForEach(Array(whyParagraphs.enumerated()), id: \.offset) { _, paragraph in
                    // loops over each separated paragraph string
                    captionCard(text: paragraph)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.brown)
                    // wraps each paragraph in its own card
                }
            }
        }
    }

    private var howStepsCard: some View {
        let steps = viewModel.currentPageText
            .split(separator: "\n")
        // breaks it into pieces wherever there's a line break, one piece per step
            .map(String.init)
        // converts each piece from Substring (what .split returns) into a plain String

        return stepsCard {
            // wraps everything below inside our reusable card-styling helper
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    // loops over each step, tracking both its position and its text
                    HStack(alignment: .center, spacing: 16) {
                        ZStack{
                            Image("Indicator")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38.58, height: 38.58)
                            Text("\(index + 1)")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.brown)
                               
                        }
                        

                        Text(step) // the actual step instruction text
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.brown)
                    }
                    if index < steps.count - 1 {
                        // true for every step except the very last one
                        Divider()
                            .background(Color.brown)
                            .padding(.vertical, 8)
                            .frame(width: 260)
                            .frame(maxWidth: .infinity, alignment: .center)
                        

                    }
                }
            }
            .padding(.leading, 10)
        }
    }

    private var whyParagraphs: [String] {
        viewModel.currentPageText
            .components(separatedBy: "\n\n")
        // splits it wherever there's a blank line (two newlines in a row), one chunk per paragraph
    }
    
    private func practiceButtonLabel(text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.darkBrown) // matches your current styling
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
    }

    private func captionCard(text: String, tailPosition: TailPosition = .none) -> some View {
        
        // a small reusable piece: takes any string, returns a styled text box
        Text(text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .padding()
//            .frame(maxWidth: .infinity)
            .background(
                BulgingCardShape(cornerRadius: 40, bulge: 4, tailPosition: tailPosition)
                    .stroke(Color.brown, lineWidth: 2)
            )
            
            .padding(8)
        
            .background(
                BulgingCardShape(cornerRadius: 48, bulge: 6, tailPosition: tailPosition)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
          
    }

    
    //reusable card for how to steps
    private func stepsCard<Content: View>(
        tailPosition: TailPosition = .none,
        @ViewBuilder content: () -> Content) -> some View {
            content()
                .padding(24)
                .background(
                    BulgingCardShape(cornerRadius: 40, bulge: 8, tailPosition: tailPosition)
                        .stroke(Color.brown, lineWidth: 2)
                )
                
                .padding(8)
                .background(
                    BulgingCardShape(cornerRadius: 48, bulge: 10, tailPosition: tailPosition)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
        
                .padding(.vertical, 10)
        }
}

//Struct to add buldge effect on stepscard

    

#Preview {
    let viewModel = LearnViewModel(skillID: "box_breathing")
    viewModel.skill = CopingSkill(
        id: "box_breathing",
        index: 8,
        name: "Grounding",
        image: "plant_akar_wangi",
        plantPhilosophy: "Vetiver is grown on slopes to stop the soil washing away.",
        info: [
            "what": "Using your senses to pull your attention out of your head and back into the room.",
            "how": "Name 5 things you can see\nName 4 things you can feel\nName 3 things you can hear\nName 2 things you can smell\nName 1 thing you can taste",
            "when": "Panic, feeling unreal or detached, a memory surfacing.",
            "why": "Attention is limited. Filling it with real things around you leaves less room for the spiral inside.\n\nThis exact exercise has not been tested on its own — it is used because clinicians consistently find it helps."
        ]
    )
    return LearnView(viewModel: viewModel)
}
