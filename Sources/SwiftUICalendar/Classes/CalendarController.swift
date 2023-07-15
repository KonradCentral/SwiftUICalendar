//
//  CalendarProxy.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/25.
//

import SwiftUI
import Combine

public class CalendarController: ObservableObject {
    @Published public var isLocked: Bool
    @Published private var scope: ViewMode
    public var date: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let today = Date()
        var buffer: Date
        let componentsToAdd: DateComponents
        
        
        let majorScopeComponent = gregorian.component(.year, from: today)
        switch scope {
        case .week:
            buffer = gregorian.date(from:DateComponents(year: majorScopeComponent, weekOfYear: gregorian.component(.weekOfYear, from: today)))!
            componentsToAdd = DateComponents(weekOfYear: datePeriodsFromNow)
        case .month:
            buffer = gregorian.date(from: DateComponents(year: majorScopeComponent, month: gregorian.component(.month, from: today)))!
            componentsToAdd = DateComponents(month: datePeriodsFromNow)
        }
        
        buffer = gregorian.date(byAdding: componentsToAdd, to: buffer)!
        
        return buffer
    }
    @Published public var datePeriodsFromNow: Int = 0
    
    internal let orientation: Orientation
    internal let columnCount = 7
    internal var rowCount: Int {
        get {
            switch scope {
            case .month:
                return 6
                
            case .week:
                return 1
            }
        }
    }
    
    public init(_ scope: ViewMode = .month, orientation: Orientation = .horizontal, isLocked: Bool = false) {
        self.scope = scope
        
        self.orientation = orientation
        self.isLocked = isLocked
    }
    
    //TODO: Find a way to turn this function into a {set} method
    public func setScope(_ scope: ViewMode) {
        self.scope = scope
        //self.objectWillChange.send()
    }
    
    private var dateFormat: String {
            switch scope {
            case .week:
                return "MMM yyyy 'Week #'W"
            case .month:
                return "MMM yyyy"
            }
    }
    
    public func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: self.date)
    }
    
    
    public func offsetedFocus(by: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        
        let componentsToAdd: DateComponents
        switch scope {
        case .week:
            componentsToAdd = DateComponents(weekOfYear: by)
        case .month:
            componentsToAdd = DateComponents(month: by)
        }

        let addedDate = gregorian.date(byAdding: componentsToAdd, to: self.date)!
        
        return addedDate
    }
}
