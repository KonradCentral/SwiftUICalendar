//
//  Struct.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/21.
//

import Foundation
import SwiftUI

public enum Week: Int, CaseIterable {
    case sun = 0
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
    
    public var shortString: String {
        get {
            return DateFormatter().shortWeekdaySymbols[self.rawValue]
        }
    }
    
    public func shortString(locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter.shortWeekdaySymbols[self.rawValue]
    }
}

public enum Orientation {
    case horizontal
    case vertical
}

public enum HeaderSize {
    case zero
    case ratio
    case fixHeight(CGFloat)
}

public protocol Interval {
    var year: Int { get set }
    var focus: Int { get set }
    var dateComponents: DateComponents { get }
    var monthShortString: String { get }
    
    func shifted(by: Int) -> Interval
    func diffInterval(value: Interval) -> Int
    func cellToDate(_ cellIndex: Int) -> Date/*YearMonthDay*/
    
    init(year: Int, focus: Int)
}
extension Interval {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return Calendar.current.isDate(
            Calendar.current.date(from: lhs.dateComponents)!,
            equalTo: Calendar.current.date(from: rhs.dateComponents)!,
            toGranularity: .day
        )
    }
    
    public static var currentWeek: Interval {
        get {
            let today = Date()
            return WeekInterval(
                year: Calendar.current.component(.year, from: today),
                focus: Calendar.current.component(.weekOfYear, from: today)
            )
        }
    }
    
}
public struct MonthInterval: Interval {
    public var year: Int
    public var focus: Int
    public var dateComponents: DateComponents {
        get {
            var components = DateComponents()
            components.year = year
            components.month = focus
            components.day = 1
            
            return components
        }
    }
    
    public init() {
        let today = Date()
        self.init(
            year: Calendar.current.component(.year, from: today),
            focus: Calendar.current.component(.month, from: today)
        )
    }
    
    public init(year: Int, focus: Int) {
        self.year = year
        self.focus = focus
    }
    
    public var monthShortString: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            
            return formatter.string(from: Calendar.current.date(from: dateComponents)!)
        }
    }
    
    public func shifted(by: Int) -> Interval {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        var toAdd = DateComponents()
        toAdd.month = by

        let addedDate = Calendar.current.date(byAdding: toAdd, to: gregorianCalendar.date(from: dateComponents)!)!
        
        return MonthInterval(
            year: Calendar.current.component(.year, from: addedDate),
            focus: Calendar.current.component(.month, from: addedDate)
        )
    }
    
    public func diffInterval(value: Interval) -> Int {
        var origin = self.dateComponents
        origin.hour = 0
        origin.minute = 0
        origin.second = 0
        var new = value.dateComponents
        new.hour = 0
        new.minute = 0
        new.second = 0
        
        return Calendar.current.dateComponents(
            [.month],
            from: Calendar.current.date(from: origin)!,
            to: Calendar.current.date(from: new)!
        ).month!
    }
    public func cellToDate(_ cellIndex: Int) -> /*YearMonthDay*/ Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        let toDate = gregorianCalendar.date(from: dateComponents)!
        let weekday = gregorianCalendar.component(.weekday, from: toDate) // 1Sun, 2Mon, 3Tue, 4Wed, 5Thu, 6Fri, 7Sat
        var components = DateComponents()
        components.day = cellIndex + 1 - weekday
        let addedDate = gregorianCalendar.date(byAdding: components, to: toDate)!
        
        return addedDate
        /*
        let year = gregorianCalendar.component(.year, from: addedDate)
        let month = gregorianCalendar.component(.month, from: addedDate)
        let day = gregorianCalendar.component(.day, from: addedDate)
        
        
        let isFocusYaerMonth: Bool
        isFocusYaerMonth = year == dateComponents.year && month == dateComponents.month
        
        return YearMonthDay(year: year, month: month, day: day, isFocusYearMonth: isFocusYaerMonth)
        */
    }
}
public struct WeekInterval: Interval {
    public var year: Int
    public var focus: Int
    public var dateComponents: DateComponents {
        get {
            var components = DateComponents()
            components.year = self.year
            components.weekOfYear = focus
            components.weekday = 1
            
            return components
        }
    }
    public var monthShortString: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "W MMM"
            
            var buffer = formatter.string(from: Calendar.current.date(from: dateComponents)!)
            buffer = "Wk. #\(buffer)"
            
            return buffer
        }
    }
    
    public init() {
        let today = Date()
        self.init(
            year: Calendar.current.component(.year, from: today),
            focus: Calendar.current.component(.weekOfYear, from: today)
        )
    }
    
    public init(year: Int, focus: Int) {
        self.year = year
        self.focus = focus
    }
    
    public func shifted(by: Int) -> Interval {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        var toAdd = DateComponents()
        toAdd.weekOfYear = by

        let addedDate = Calendar.current.date(byAdding: toAdd, to: gregorianCalendar.date(from: dateComponents)!)!
        
        return WeekInterval(
            year: Calendar.current.component(.year, from: addedDate),
            focus: Calendar.current.component(.weekOfYear, from: addedDate)
        )
    }
    
    public func diffInterval(value: Interval) -> Int {
        var origin = self.dateComponents
        origin.hour = 0
        origin.minute = 0
        origin.second = 0
        var new = value.dateComponents
        new.hour = 0
        new.minute = 0
        new.second = 0
        
        return Calendar.current.dateComponents(
            [.weekOfYear],
            from: Calendar.current.date(from: origin)!,
            to: Calendar.current.date(from: new)!
        ).weekOfYear!
    }
    
    public func cellToDate(_ cellIndex: Int) -> /*YearMonthDay*/ Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        let toDate = gregorianCalendar.date(from: dateComponents)!
        let weekday = gregorianCalendar.component(.weekday, from: toDate) // 1Sun, 2Mon, 3Tue, 4Wed, 5Thu, 6Fri, 7Sat
        var components = DateComponents()
        components.day = cellIndex + 1 - weekday
        let addedDate = gregorianCalendar.date(byAdding: components, to: toDate)!
        
        return addedDate
        /*
        let year = gregorianCalendar.component(.year, from: addedDate)
        let month = gregorianCalendar.component(.month, from: addedDate)
        let day = gregorianCalendar.component(.day, from: addedDate)
        
        
        let isFocusYearMonth: Bool
        isFocusYearMonth = year == year && gregorianCalendar.component(.weekOfYear, from: addedDate) == dateComponents.weekOfYear
        
        return YearMonthDay(year: year, month: month, day: day, isFocusYearMonth: isFocusYaerMonth)
        */
    }
}

public struct YearMonthDay: Equatable, Hashable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let isFocusYearMonth: Bool?
    
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        self.isFocusYearMonth = nil
    }
        
    public init(year: Int, month: Int, day: Int, isFocusYearMonth: Bool) {
        self.year = year
        self.month = month
        self.day = day
        self.isFocusYearMonth = isFocusYearMonth
    }
    
    public static var current: YearMonthDay {
        get {
            let today = Date()
            return YearMonthDay(
                year: Calendar.current.component(.year, from: today),
                month: Calendar.current.component(.month, from: today),
                day: Calendar.current.component(.day, from: today)
            )
        }
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
    
    public var isToday: Bool {
        let today = Date()
        let year = Calendar.current.component(.year, from: today)
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)
        return self.year == year && self.month == month && self.day == day
    }
    
    public var dayOfWeek: Week {
        let weekday = Calendar.current.component(.weekday, from: self.date!)
        return Week.allCases[weekday - 1]
    }
    
    public var date: Date? {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        return gregorianCalendar.date(from: self.toDateComponents())
    }
    
    public func toDateComponents() -> DateComponents {
        var components = DateComponents()
        components.year  = self.year
        components.month = self.month
        components.day   = self.day
        return components
    }
    
    public func addDay(value: Int) -> YearMonthDay {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let toDate = self.toDateComponents()

        var components = DateComponents()
        components.day = value

        let addedDate = Calendar.current.date(byAdding: components, to: gregorianCalendar.date(from: toDate)!)!
        let ret = YearMonthDay(
            year: Calendar.current.component(.year, from: addedDate),
            month: Calendar.current.component(.month, from: addedDate),
            day: Calendar.current.component(.day, from: addedDate)
        )
        return ret
    }
    
    public func diffDay(value: YearMonthDay) -> Int {
        var origin = self.toDateComponents()
        origin.hour = 0
        origin.minute = 0
        origin.second = 0
        var new = value.toDateComponents()
        new.hour = 0
        new.minute = 0
        new.second = 0
        return Calendar.current.dateComponents([.day], from: Calendar.current.date(from: origin)!, to: Calendar.current.date(from: new)!).month!
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
        hasher.combine(self.day)
    }
}

