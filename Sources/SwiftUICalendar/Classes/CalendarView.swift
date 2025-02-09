//
//  CalendarView.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/26.
//

import SwiftUI
import Combine
import InfiniteSwipeView

@available(macOS 11, *)
public struct CalendarView<CalendarCell: View, HeaderCell: View>: View {
    
    private var gridItem: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 7) // columnCount
    private let content: (Date, Bool) -> CalendarCell
    private let header: (Week) -> HeaderCell?
    private var headerSize: HeaderSize
    @ObservedObject private var controller: CalendarController
    private let isHasHeader: Bool
    private let formatter = DateFormatter()
    
    public init(
        _ controller: CalendarController,
        @ViewBuilder content: @escaping (Date, Bool) -> CalendarCell
    ) where HeaderCell == EmptyView {
        self.controller = controller
        self.header = { _ in nil }
        self.content = content
        self.isHasHeader = false
        self.headerSize = .zero
        
        formatter.dateFormat = "dd"
    }
    
    public init(
        _ controller: CalendarController,
        headerSize: HeaderSize = .fixHeight(40),
        @ViewBuilder header: @escaping (Week) -> HeaderCell,
        @ViewBuilder content: @escaping (Date, Bool) -> CalendarCell
    ) {
        self.controller = controller
        self.header = header
        self.content = content
        self.isHasHeader = true
        self.headerSize = headerSize
        
        formatter.dateFormat = "dd"
    }
    
    public func isSameMonth(_ dateA: Date, _ dateB: Date) -> Bool {
        let gregorian = Calendar(identifier: .gregorian)
        return gregorian.component(.month, from: dateA) == gregorian.component(.month, from: dateB)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            InfiniteSwipeView(index: $controller.offsetIntervals, orientation: controller.orientation) { index in
                LazyVGrid(columns: gridItem, alignment: .center, spacing: 0) {
                    let offsetedDate = controller.offsetedDate(intervals: index)
                    ForEach(0..<(controller.columnCount * (controller.rowCount + (isHasHeader ? 1 : 0))), id: \.self) { j in
                        GeometryReader { _ in
                            if isHasHeader && j < controller.columnCount {
                                header(Week.allCases[j])
                            } else {
                                let cellDate = offsetDate(by: j - (isHasHeader ? 7 : 0), date: offsetedDate)
                                self.content(cellDate, isSameMonth(cellDate, offsetedDate))
                                    .frame(height: calculateCellHeight(j, geometry: proxy))
                            }
                        }
                        .frame(height: calculateCellHeight(j, geometry: proxy))
                    }
                }
                //.frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
        }
    }
    
    func offsetDate(by: Int, date: Date) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        
        let toDate = date
        let weekday = gregorian.component(.weekday, from: toDate) // 1Sun, 2Mon, 3Tue, 4Wed, 5Thu, 6Fri, 7Sat
        var components = DateComponents()
        components.day = by + 1 - weekday
        let addedDate = gregorian.date(byAdding: components, to: toDate)!
        
        return addedDate
    }
    
    func calculateCellHeight(_ index: Int, geometry: GeometryProxy) -> CGFloat {
        if !isHasHeader {
            return geometry.size.height / CGFloat(controller.rowCount)
        }

        var headerHeight: CGFloat = 0
        switch headerSize {
        case .zero:
            headerHeight = 0
        case .ratio:
            headerHeight = geometry.size.height / CGFloat(controller.rowCount + 1)
        case .fixHeight(let value):
            headerHeight = value
        }

        if index < controller.columnCount {
            return headerHeight
        } else {
            return (geometry.size.height - headerHeight) / CGFloat(controller.rowCount)
        }
    }
}

@available(macOS 11, *)
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(CalendarController()) { date, isFocusMonth in
            let gregorian = Calendar(identifier: .gregorian)
            GeometryReader { geometry in
                Text("\(gregorian.component(.year, from: date))/\(gregorian.component(.month, from: date))/\(gregorian.component(.day, from: date))")
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    .border(.black, width: 1)
                    .font(.system(size: 8))
                    .opacity(isFocusMonth ? 1 : 0.6)
            }
        }
    }
}
