//
//  ReflectView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI
import SwiftData

struct ReflectView: View {
    @State var viewModel: ReflectViewModel
    @State var selectedRating: Int? = nil
    @State var currentLog: String = ""
    let logCharLimit = 200

    @Environment(Router.self) private var router

    // Reflect is pushed inside whichever tab's stack the user is already in, so
    // it must not carry a NavigationStack of its own.
    var body: some View {
        VStack {
            Image("Flower")
            Text(viewModel.current.name)
                .font(.system(size: 24)).bold(true)
                .foregroundStyle(Color.darkBrown)
                .padding(.bottom, 20)
            rating
            textbox
            Button{
                viewModel.submitLog(
                    log: Log(
                        id: UUID(),
                        date: .now,
                        copingID: viewModel.current.id,
                        rating: selectedRating ?? 0,
                        journal: currentLog
                    )
                )
                // Saving ends the loop, so this is a rewind rather than a push:
                // the whole Learn -> Practice -> Reflect stack is dropped and
                // the user lands on the skill's plant.
                router.finishReflection(skillID: viewModel.current.id)
            } label: {
                Text("Done")
                    .foregroundStyle(Color.white)
                    .font(Font.system(size: 16))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width: 300, height: 50)
                            .foregroundColor(.brown)
                            .shadow(color: Color.black.opacity(0.2), radius: 4)
                            .padding()
                    )
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightCream)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Route.reflectHistory(skillID: viewModel.current.id)) {
                    Image(systemName: "clock")
                }
            }
        }
        .ignoresSafeArea()
    }
    
    var rating: some View {
        VStack{
            Text("How do you feel about this skill?")
                .font(.system(size:17))
                .foregroundStyle(Color.brown)
            HStack(alignment: .top){
                ForEach(1..<6) { index in
                    VStack{
                        Button{
                            self.selectedRating = index
                        } label:{
                            Image(index == self.selectedRating ? "rating_\(index)" : "rating_empty_\(index)")
                        }
                        Text(viewModel.ratingName(rating: index))
                            .font(.system(size:12))
                            .foregroundStyle(Color.brown)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
        }
    }
    
    var textbox: some View{
        TextField("Write what you notice.", text: $currentLog, axis: .vertical)
            .frame(maxWidth: 300, maxHeight: 280, alignment: .topLeading)
            .padding(.vertical, 50)
            .padding(.horizontal, 70)
            .background(Image("LogTextBox").resizable().scaledToFit())
            .onChange(of: currentLog) { newValue, oldValue in
                if newValue.count + 1 > logCharLimit {
                    currentLog = String(newValue.prefix(logCharLimit))
                }
            }
    }

}

