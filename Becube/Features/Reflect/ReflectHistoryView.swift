//
//  ReflectHistoryView.swift
//  Becube
//
//  Created by David Paul Ong on 19/08/26.
//

import SwiftUI
import SwiftData

struct ReflectHistoryView: View {
    @State var viewModel: ReflectViewModel
    @State var current: CopingSkill
    @State var displayedLogs: [Log] = []
    
    var body: some View {
        Text("Log History")
        
        // Flower Image and Stats
        HStack{
            VStack{
                Text("Done")
                ZStack{
                    Image("Star")
                    Text("5x")
                }
            }
             
            Image("Flower") // Center Image
            
            VStack{
                Text("Avg\nRating")
                    .multilineTextAlignment(.center)
                ZStack{
                    Image("Star")
                    Image("rating_color_1")
                }
            }
            
        }
        
        // Title and Flower Name
        VStack{
            Text(current.name)
                .textCase(.uppercase)
            Text("flower name: (\(current.image))")
        }
        
        // Calendar
        CalendarView(onDateSelected: onDateSelected)
        
        // Logs
        ForEach(displayedLogs, id: \.self){ log in
            
        }
        
    }
    
    
    func onDateSelected(start: Date, end: Date) {
        print("Start: \(start), End: \(end)")
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
    
    return ReflectHistoryView(
        viewModel: ReflectViewModel(gardenStore: gardenStore),
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
            ]
        ),
    )
}

