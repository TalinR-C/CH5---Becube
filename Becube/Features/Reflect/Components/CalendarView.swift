//
//  CalendarVIew.swift
//  Becube
//
//  Created by David Paul Ong on 18/08/26.
//

import SwiftUI

struct CalendarView: View {
    @State var logs: [Log]
    
    @State private var currentMonth = Date.now
    @State private var selectedDate = Date.now
    @State private var selectedHour = Date.now
    @State private var days: [Day] = []
    
    let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SA"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        Image("CalendarBackground")
            .resizable()
            .frame(height: 440)
            .overlay{
                VStack(spacing: 10) {
                    // Month navigation
                    HStack {
                        Text(currentMonth.formatted(.dateTime.year().month()))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.darkBrown)
                        Spacer()
                        HStack(spacing: 20){
                            Button {
                                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                                updateDays()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundStyle(Color.darkBrown)
                            }
                            Button {
                                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                                updateDays()
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundStyle(Color.darkBrown)
                            }
                        }
                    }
                    
                    // Days of the week row
                    HStack {
                        ForEach(daysOfWeek.indices, id: \.self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.darkBrown    )
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Grid of days
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(days.indices, id: \.self) { index in
                            
                            let day = days[index]
                            Button {
                                if  day.date.monthInt == currentMonth.monthInt {
                                    selectedDate = day.date
                                    onDateSelected(selectedDate)
                                }
                                else if day.date.monthInt == currentMonth.monthInt - 1{
                                    selectedDate = day.date
                                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                                    updateDays()
                                }
                                else if day.date.monthInt == currentMonth.monthInt + 1{
                                    selectedDate = day.date
                                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                                    updateDays()
                                }
                            } label: {
                                Text(day.date.formatted(.dateTime.day()))
                                    .font(day.date.startOfDay == selectedDate.startOfDay
                                          ? .system(size: 17).bold()
                                          : .system(size: 14))
                                    .foregroundStyle(day.date.monthInt == currentMonth.monthInt ? .darkBrown : .darkBrown.opacity(0.3))
                                    .frame(minHeight: 35)
                                    .background(
                                        backgroundStyle(for: day)
                                    )
                            }
                            .overlay(
                                Circle()
                                    .foregroundStyle(
                                        day.hasEntry
                                        ? .brown : .clear
                                    )
                                    .frame(width: 4, height: 4)
                                    .offset(x: 0, y: 21)
                                
                            )
                        }
                    }
                    Spacer()
                }
                .padding(50)
                .onAppear {
                    updateDays()
                    onDateSelected(selectedDate)
                }
            }
        
    }
    
    private func updateDays() {
        var updatedDays: [Day] = []
        print(currentMonth.calendarDisplayDays)
        for date in currentMonth.calendarDisplayDays{
            let averageRating = getDayAverageRating(date: date)
//            let hasEntry = averageRating != 0.0 && !averageRating.isNaN ? true : false
            updatedDays.append(Day(
                date: date,
                averageRating: averageRating,
                hasEntry: hasEntry(date: date)
            ))
        }
        
        days = updatedDays
    }
    
    private func getDayAverageRating(date: Date) -> Double{
        let logsInDay = logs.filter{$0.date.startOfDay == date.startOfDay}
        if logsInDay.count <= 0 {return 0.0}
        print(logsInDay)
        let ratings = logsInDay.compactMap {r in r.rating}
        print(ratings)
        print(Double(ratings.reduce(0, +)))
        print(Double(ratings.count))
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        print(averageRating, Calendar.current.component(.day, from: date))
        print(hasRating(date: date))
        return averageRating
    }
    
    private func hasEntry(date:Date) -> Bool{
        let logsInDay = logs.filter{$0.date.startOfDay == date.startOfDay}
        return logsInDay.count > 0
    }
    
    private func hasRating(date:Date) -> Bool{
        let logsInDay = logs.filter{$0.date.startOfDay == date.startOfDay}
        if logsInDay.count <= 0 {return false}
        let ratings = logsInDay.compactMap {r in r.rating}
        print(ratings)
        print(!ratings.isEmpty)
        return !ratings.isEmpty
    }
    
    private func getRatingClassImage(rating: Double) -> Image{
        if rating <= 1.0 {return Image("rating_empty_color_1")}
        if rating <= 2.0 {return Image("rating_empty_color_2")}
        if rating <= 3.0 {return Image("rating_empty_color_3")}
        if rating <= 4.0 {return Image("rating_empty_color_4")}
        return Image("rating_5")
    }
    
    private func getRatingClass(rating: Double) -> Int{
        if rating <= 1.0, rating > 0.0 {return 1}
        if rating <= 2.0 {return 2}
        if rating <= 3.0 {return 3}
        if rating <= 4.0 {return 4}
        if rating <= 5.0 {return 5}
        return 0
    }
    
    @ViewBuilder
    private func backgroundStyle(for day: Day) -> some View {
        // Current date Background
        if day.date.startOfDay == Date().startOfDay {
            VStack{
                Spacer()
                Image("CurrentDateBackground")
            }
        }
        
        // Rating based background
        if hasRating(date: day.date) {
            Image("rating_empty_color_\(getRatingClass(rating: day.averageRating!))")
                .resizable()
                .frame(width: 35, height: 35)
        }
        
        // Selected date background
        if day.date.startOfDay == selectedDate.startOfDay && hasRating(date: selectedDate){
            Image("BorderBrown\(getRatingClass(rating: day.averageRating!))")
                .resizable()
                .frame(width: 35, height: 35)
        }
        
        else {
            Circle()
                .foregroundStyle(.clear)
        }
    }
}

#Preview {
    func twodates(date1:Date){
        print("Een twee datum")
    }
    
    let logs = [
            Log(id: UUID(), date: try! Date("21/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", rating: 4, journal: "first entry"),
            Log(id: UUID(), date: try! Date("18 /08/2026", strategy: .dateTime.day().month().year()), copingID: "123", rating: 2, journal: "first entry"),
            Log(id: UUID(), date: try! Date("18/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", rating: 4, journal: "first entry"),
            Log(id: UUID(), date: try! Date("23/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", rating: 1, journal: "first entry")
        ]
    
    return CalendarView(logs: logs, onDateSelected: twodates)
}
