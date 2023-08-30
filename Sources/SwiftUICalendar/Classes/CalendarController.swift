//
//  CalendarProxy.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/25.
//

import SwiftUI
import Combine
import InfiniteSwipeView


public class CalendarController: ObservableObject {
    @Published public var viewMode: ViewMode
    @Published public var year: Int
    @Published public var yearInterval: Int
    @Published public var isLocked: Bool
    
    @Published internal var offsetIntervals: Int
    
    private var date: Date {
        let gregorian = Calendar(identifier: .gregorian)
        //let interval: DateComponents
        
        
        var focusDate: Date
        switch viewMode {
        case .week:
            focusDate = gregorian.date(
                from: DateComponents(
                    year: year,
                    weekOfYear: yearInterval// + offsetIntervals
                    //gregorian.component(.weekOfYear, from: today)
                )
            )!
            //interval = DateComponents(weekOfYear: offsetIntervals)
        case .month:
            focusDate = gregorian.date(
                from: DateComponents(
                    year: year,
                    month: yearInterval// + offsetIntervals
                    //month: gregorian.component(.month, from: Date())
                )
            )!
            //interval = DateComponents(month: offsetIntervals)
        }
        
        //focusDate = gregorian.date(byAdding: interval, to: focusDate)!
        
        return focusDate
    }
    
    internal let orientation: Orientation
    internal let columnCount = 7
    internal var rowCount: Int {
        get {
            switch viewMode {
            case .month:
                return 6
                
            case .week:
                return 1
            }
        }
    }
    
    public init(_ viewMode: ViewMode = .month, year: Int = 0, yearInterval: Int = 0, orientation: Orientation = .horizontal, isLocked: Bool = false) {
            let now = Date()
            let calendar = Calendar(identifier: .gregorian)
            
            self.viewMode = viewMode
            
            if year > 0 {
                self.year = year
            }
            else {
                self.year = calendar.component(.year, from: now)
            }
            
            if yearInterval > 0 {
                self.yearInterval = yearInterval
            }
            else {
                switch viewMode {
                case .month:
                    self.yearInterval = calendar.component(.month, from: now)
                case .week:
                    self.yearInterval = calendar.component(.weekOfYear, from: now)
                }
            }
            self.orientation = orientation
            self.isLocked = isLocked
            
            
            self.offsetIntervals = 0
    }
    
    private var dateFormat: String {
        switch viewMode {
        case .week:
            return "MMM yyyy 'Week #'W"
        case .month:
            return "MMM yyyy"
        }
    }
    
    public func dateString(format: String? = nil) -> String {
        let formatter = DateFormatter()
        if let format {
            formatter.dateFormat = format
        }
        else {
            formatter.dateFormat = dateFormat
        }
        
        return formatter.string(from: offsetedDate(intervals: offsetIntervals))
        //return formatter.string(from: self.date)
    }
    
    public func offsetedDate(intervals: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        
        let componentsToAdd: DateComponents
        switch viewMode {
        case .week:
            componentsToAdd = DateComponents(weekOfYear: intervals)
        case .month:
            componentsToAdd = DateComponents(month: intervals)
        }

        let addedDate = gregorian.date(byAdding: componentsToAdd, to: self.date)!
        
        return addedDate
    }
}
