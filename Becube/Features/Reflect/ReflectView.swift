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

    var body: some View {
        NavigationStack{
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
                    NavigationLink(destination: ReflectHistoryView(viewModel:viewModel))
                    {
                        Image(systemName: "clock")
                    }
                }
            }
            .ignoresSafeArea()
        }
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

#Preview {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GardenState.self,
            Log.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    let gardenStore = GardenStore(context: sharedModelContainer.mainContext)
    
    return ReflectView(
        viewModel: ReflectViewModel(
            gardenStore: gardenStore,
            current: CopingSkill(
                id: "grounding",
                index: 8,
                name: "Grounding",
                image: "plant_akar_wangi",
                plantPhilosophy: "Vetiver is grown on slopes to stop the soil washing away.",
                info: [
                    "what": "Using your senses to pull your attention out of your head and back into the room.",
                    "how": "Name 5 things you can see\nName 4 things you can feel\nName 3 things you can hear\nName 2 things you can smell\nName 1 thing you can taste",
                    "when": "Panic, feeling unreal or detached, a memory surfacing.",
                    "why": "Attention is limited. Filling it with real things around you leaves less room for the spiral inside.\n\nThis exact exercise has not been tested on its own — it is used because clinicians consistently find it helps."
                ],
                plantName: "Hydrangaea"
            ),
                                   ),
        
    )
}

