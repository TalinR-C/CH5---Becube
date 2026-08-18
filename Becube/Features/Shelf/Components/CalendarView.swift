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
        LogTest(id: UUID(), date: try! Date("18/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 4, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("18/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 2, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("18/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 4, journal: "first entry"),
        LogTest(id: UUID(), date: try! Date("19/08/2026", strategy: .dateTime.day().month().year()), copingID: "123", score: 1, journal: "first entry")
    ]
    
    
    
    @State private var currentMonth = Date.now
    @State private var selectedDate = Date.now
    @State private var selectedHour = Date.now
    @State private var days: [Day] = []
    
    let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SA"]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var onDateSelected: (Date, Date) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Text(currentMonth.formatted(.dateTime.year().month()))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            
            // Days of the week row
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid of days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Button {
                        if  day.date.monthInt == currentMonth.monthInt {
                            selectedDate = day.date
                            onDateSelected(selectedDate, selectedHour)
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
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(foregroundStyle(for: day.date))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                backgroundStyle(for: day)
                            )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            updateDays()
            onDateSelected(selectedDate, selectedHour)
        }
        .background(Color.black)
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
    
    private func getRatingClass(rating: Double) -> Color{
        if rating <= 1.0 {return Color.red}
        if rating <= 2.0 {return Color.yellow}
        if rating <= 3.0 {return Color.orange}
        if rating <= 4.0 {return Color.green}
        return Color.blue
    }
    
    private func getRatingClassImage(rating: Double) -> Image{
        if rating <= 1.0 {return Image("rating_1")}
        if rating <= 2.0 {return Image("rating_2")}
        if rating <= 3.0 {return Image("rating_3")}
        if rating <= 4.0 {return Image("rating_4")}
        return Image("rating_5")
    }
    
    private func foregroundStyle(for day: Date) -> Color {
        let isDifferentMonth = day.monthInt != currentMonth.monthInt
        let isSelectedDate = day.formattedDate == selectedDate.formattedDate
        
        if isDifferentMonth {
            return isSelectedDate ? .black : .white.opacity(0.3)
        } else {
            return .black
        }
    }
    
    @ViewBuilder
    private func backgroundStyle(for day: Day) -> some View {
        // Selected date background
        if day.date.formattedDate == selectedDate.formattedDate{
            Circle()
                .foregroundStyle(Color.blue)
        }
        // Rating based background
        else if day.hasEntry {
            getRatingClassImage(rating: day.averageRating!)
        }
        else {
            Circle()
                .foregroundStyle(.clear)
        }
    }
}

#Preview {
    func twodates(date1:Date,date2:Date){
        print("Een twee datum")
    }
   return CalendarView(onDateSelected: twodates)
}
