//
//  CalendarProxy.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/25.
//

import SwiftUI
import Combine

public class CalendarController: ObservableObject {
    @Published public var interval: Interval
    @Published public var isLocked: Bool
    @Published internal var position: Int = Global.CENTER_PAGE
    @Published public var viewMode: ViewMode
    
    internal let orientation: Orientation
    internal let columnCount = 7
    internal var rowCount: Int {
        get {
            viewMode == .month ? 6 : 1
        }
    }
    internal let max: Int = Global.MAX_PAGE
    internal let center: Int = Global.CENTER_PAGE
    internal let scrollDetector: CurrentValueSubject<CGFloat, Never>
    internal var cancellables = Set<AnyCancellable>()
    
    public enum ViewMode: Int {
        case week = 1
        case month = 6
    }
    
    public init(_ viewMode: ViewMode = .month, orientation: Orientation = .horizontal, isLocked: Bool = false) {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        
        self.viewMode = viewMode
        switch viewMode {
        case .month:
            self.interval = MonthInterval()
        case .week:
            self.interval = WeekInterval()
        }
        self.scrollDetector = detector
        self.orientation = orientation
        self.isLocked = isLocked
        
        detector
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] value in
                if let self = self {
                    let step = self.position - self.center
                    self.interval = self.interval.shifted(by: step)
                    self.position = self.center
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    public func setViewMode(_ viewMode: ViewMode) {
        self.viewMode = viewMode
        
        switch viewMode {
        case .month:
            self.interval = MonthInterval()
        case .week:
            self.interval = WeekInterval()
        }
    }
    
    public func setInterval(_ interval: Interval) {
        self.interval = interval
        self.position = self.center
        self.objectWillChange.send()
    }
    
    public func scrollTo(_ interval: Interval, isAnimate: Bool = true) {
        if isAnimate {
            var diff = self.position - interval.diffInterval(value: self.interval)
            if diff < 0 {
                self.interval = interval.shifted(by: self.center)
                diff = 0
                // 4 * 12 + 2 50
            } else if self.max <= diff {
                self.interval = interval.shifted(by: -self.center + 1)
                diff = self.max - 1
            }
            self.objectWillChange.send()
            withAnimation { [weak self] in
                if let self = self {
                    self.position = diff
                    self.objectWillChange.send()
                }
            }
        } else {
            self.interval = interval
            self.objectWillChange.send()
        }
    }
}
