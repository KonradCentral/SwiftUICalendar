//
//  Struct.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/21.
//

import Foundation

public enum ViewMode {
    case week
    case month
}

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
