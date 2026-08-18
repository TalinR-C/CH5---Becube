//
//  ShelfListView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

struct ShelfListView: View {
    @State var viewModel: ShelfListViewModel
    
    init(gardenStore: GardenStore) {
        _viewModel = State(initialValue: ShelfListViewModel(gardenStore: gardenStore))
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("David's Shelf")
                    .font(Font.largeTitle.bold())
                VStack {
                    HStack {
                        VStack {
                            Text("Box Breath")
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.50))
                                )
                            Image("Flower")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                        }
                    }
                    Rectangle()
                        .fill(Color.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 10)
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search Skills", text: $viewModel.searchText)
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(viewModel.filteredSkills, id: \.id) { skill in
                            VStack {
                                Image(skill.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                Text(skill.name)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                }

                NavigationLink("View Plant") {
                    SinglePlantView()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isEditing ? "Done" : "Edit") {
                        viewModel.isEditing.toggle()
                    }
                }
            }
        }
    }
}
