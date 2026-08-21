//
//  CalendarVIew.swift
//  Becube
//
//  Created by David Paul Ong on 18/08/26.
//

import SwiftUI

class LogTest{
    var id: UUID
    var date : Date
    var copingID : String
    var score : Int?
    var journal : String?
    
    init(id: UUID, date: Date, copingID: String, score: Int? = nil, journal: String? = nil) {
        self.id = id
        self.date = date
        self.copingID = copingID
        self.score = score
        self.journal = journal
    }
}

struct Day: Hashable{
    var date: Date
    var averageRating: Double?
    var hasEntry: Bool = false
    init(date: Date, averageRating: Double? = nil, hasEntry: Bool) {
        self.date = date
        self.averageRating = averageRating
        self.hasEntry = hasEntry
    }
}

struct CalendarView: View {
    @State var logs: [LogTest] = [
        LogTest(id: UUID(), date: try! Date("21/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 4, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("18 /08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 2, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("18/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 4, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("19/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 1, journal: "first entry")
    ]
    
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
            .frame(height: 395)
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
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(days, id: \.self) { day in
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
                                                ? .system(size: 18).bold()
                                                : .system(size: 14))
                                    .foregroundStyle(day.date.monthInt == currentMonth.monthInt ? .darkBrown : .darkBrown.opacity(0.3))
                                    .frame(maxWidth: .infinity, minHeight: 35)
                                    .background(
                                        backgroundStyle(for: day)
                                    )
                            }
                        }
                    }
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
        for date in currentMonth.calendarDisplayDays{
            let averageRating = getDayAverageRating(date: date)
            let hasEntry = averageRating != 0.0 ? true : false
            updatedDays.append(Day(
                date: date,
                averageRating: averageRating,
                hasEntry: hasEntry
            ))
        }
        
        days = updatedDays
    }
    
    private func getDayAverageRating(date: Date) -> Double{
        let logsInDay = logs.filter{$0.date.startOfDay == date.startOfDay}
        if logsInDay.count <= 0 {return 0.0}
        let ratings = logsInDay.compactMap {r in r.score}
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        print(date, "--- Rating:",averageRating)
        return averageRating
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
        return 5
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
        // Selected date background
        if day.date.startOfDay == selectedDate.startOfDay, day.hasEntry{
            Image("BorderBrown\(getRatingClass(rating: day.averageRating!))")
        }
        // Rating based background
        if day.hasEntry {
            getRatingClassImage(rating: day.averageRating!)
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
   return CalendarView(onDateSelected: twodates)
}
