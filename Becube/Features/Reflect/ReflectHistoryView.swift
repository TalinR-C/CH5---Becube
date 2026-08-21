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
    
    var body: some View {
        ScrollView{
            Text("LOG HISTORY")
                .font(.system(size: 17))
                .foregroundStyle(.brown)
            
            // Flower Image and Stats
            HStack{
                VStack{
                    Spacer()
                    Text("Done")
                        .font(.system(size: 11))
                        .foregroundStyle(.brown)
                    ZStack{
                        Image("Star")
                        Text("\(viewModel.getCurrentPlantlogs().count)")
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                 
                Image("Flower") // Center Image
                
                VStack{
                    Spacer()
                    Text("Avg\nRating")
                        .font(.system(size: 11))
                        .foregroundStyle(.brown)
                        .multilineTextAlignment(.center)
                    ZStack{
                        Image("Star")
                        Image("rating_\(viewModel.currentRatingClass)")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            // Title and Flower Name
            VStack{
                Text(viewModel.current.name)
                    .font(.system(size: 24))
                    .textCase(.uppercase)
                    .foregroundStyle(.brown)
                Text("Flower Name: \(viewModel.current.plantName!)")
                    .font(.system(size: 13.75))
                    .foregroundStyle(.brown)
            }
            
            // Calendar
            CalendarView(
                logs: viewModel.logs,
                onDateSelected: onDateSelected
            )
            
            // Logs
            ForEach(viewModel.logs, id: \.self){ log in
                if log.rating != nil {
                    SingleLogView(viewModel: viewModel, log: log)
                }
            }
        }
        .background(.offWhite)
    }
    
    
    func onDateSelected(date: Date) {
        viewModel.getDayLogs(day: date)
    }
    
}


#Preview {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GardenState.self,
            Log.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    let gardenStore = GardenStore(context: sharedModelContainer.mainContext)
    
    return ReflectHistoryView(
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

