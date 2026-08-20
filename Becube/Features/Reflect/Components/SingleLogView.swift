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
    @State var log: Log?
    var body: some View {
        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Image("rating_\(log?.rating ?? 0)")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(viewModel.ratingName(rating: log?.rating ?? 0))
                    }
                    Text(log?.journal ?? "No journal")
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
        viewModel: ReflectViewModel(gardenStore: gardenStore),
        log: Log(
            id: UUID(),
            date: Date(),
            copingID: "id",
            rating: 3,
            journal: "I like this"
        )
    )
}


