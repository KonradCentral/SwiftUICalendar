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
    //@Published internal var position: Int = Global.CENTER_PAGE
    //@Published private var scope: Calendar.Component
    @Published private var scope: ViewMode
    @Published public var date: Date
    
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
    //internal let max: Int = Global.MAX_PAGE
    //internal let center: Int = Global.CENTER_PAGE
    //internal let scrollDetector: CurrentValueSubject<CGFloat, Never>
    //internal var cancellables = Set<AnyCancellable>()
    
    public init(_ scope: ViewMode = .month, orientation: Orientation = .horizontal, isLocked: Bool = false) {
        let gregorian = Calendar(identifier: .gregorian)
        let today = Date()
        
        self.scope = scope
        let majorScopeComponent = gregorian.component(.year, from: today)
        switch scope {
        case .week:
            self.date = gregorian.date(from:DateComponents(year: majorScopeComponent, weekOfYear: gregorian.component(.weekOfYear, from: today)))!
        case .month:
            self.date = gregorian.date(from: DateComponents(year: majorScopeComponent, month: gregorian.component(.month, from: today)))!
        }
        
        //self.scrollDetector = CurrentValueSubject<CGFloat, Never>(0)
        self.orientation = orientation
        self.isLocked = isLocked
        
        
        /*self.scrollDetector
            //.debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                if let self = self {
                    let step = self.position - self.center
                    self.date = offsetedFocus(by: step)
                    self.position = self.center
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)*/
    }
    
    //TODO: Find a way to turn this function into a {set} method
    public func setScope(_ scope: ViewMode) {
        self.scope = scope
        //self.position = self.center
        self.objectWillChange.send()
    }
    
    private var dateFormat: String {
        get {
            switch scope {
            case .week:
                return "MMM yyyy 'Week #'W"
            case .month:
                return "MMM yyyy"
            }
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
