//
//  SingleLogView.swift
//  Becube
//
//  Created by David Paul Ong on 20/08/26.
//

import SwiftUI
import SwiftData

struct SingleLogView: View {
    @State var viewModel: ReflectViewModel
    @State var log: Log
    var body: some View {
        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Image("rating_\(log.rating ?? 0)")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(viewModel.ratingName(rating: log.rating ?? 0))
                    }
                    Text(log.journal ?? "No journal")
                        .padding(.leading, 10)
                }
                Spacer()
            }
            .frame(width: 300, height: 65)
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
    
    return SingleLogView(
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
        )
        ,
        log: Log(
            id: UUID(),
            date: Date(),
            copingID: "id",
            rating: 1,
            journal: "I like this but like the text lenght?"
        )
    )
}


