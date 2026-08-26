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
    @State var showAvgRatingInfo: Bool = false
    var body: some View {
        ZStack{
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
                        Button{
                            showAvgRatingInfo = true
                        }
                        label: {
                            Text("Avg\nRating")
                                .font(.system(size: 11))
                                .foregroundStyle(.brown)
                                .multilineTextAlignment(.center)
                            }
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
                    logs: viewModel.getCurrentPlantlogs(),
                    onDateSelected: onDateSelected
                )
                
                // Logs
                ForEach(viewModel.logs.reversed(), id: \.self){ log in
                    if log.rating != nil {
                        SingleLogView(viewModel: viewModel, log: log)
                    }
                }
            }
            .background(.offWhite)
            
            if showAvgRatingInfo {

                Color.black.opacity(0.2)
                    .onTapGesture { } // absorbs taps, does nothing, makes anything below not interactable
                    .ignoresSafeArea()
                ZStack{
                    Image("RatingInfo_bg")
                        .overlay(alignment: .topLeading){
                            Button{
                                showAvgRatingInfo = false
                            }
                            label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color.brown)
                            }
                            .font(Font.system(size: 20)).bold()
                            .buttonStyle(PlainButtonStyle())
                            .padding(50)
                        }
                    VStack{
                        Text("What's The Rating?")
                            .font(.system(size: 15)).bold()
                            .foregroundStyle(.brown)
                        HStack(alignment: .top){
                            ForEach(1..<6) { index in
                                VStack{
                                    Image("rating_\(index)")
                                    Text(viewModel.ratingName(rating: index, withNewline: true))
                                        .font(.system(size:12))
                                        .foregroundStyle(Color.brown)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }

                    }
                }
            }
        }
    }
    
    
    func onDateSelected(date: Date) {
        viewModel.getDayLogs(day: date)
    }
    
}
