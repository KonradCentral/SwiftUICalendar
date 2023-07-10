//
//  CalendarView.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/26.
//

import SwiftUI
import Combine

public struct CalendarView<CalendarCell: View, HeaderCell: View>: View {
    
    private var gridItem: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 7) // columnCount
    private let content: (Date, Bool) -> CalendarCell
    private let header: (Week) -> HeaderCell?
    private var headerSize: HeaderSize
    @ObservedObject private var controller: CalendarController
    private let isHasHeader: Bool
    private let formatter = DateFormatter()
    
    public init(
        _ controller: CalendarController = CalendarController(),
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
        _ controller: CalendarController = CalendarController(),
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
    
    public func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.component(.month, from: date) == Calendar.current.component(.month, from: Date())
    }
    
    public var body: some View {
        GeometryReader { proxy in
            InfinitePagerView(controller, orientation: controller.orientation) { date, i in
                LazyVGrid(columns: gridItem, alignment: .center, spacing: 0) {
                    ForEach(0..<(controller.columnCount * (controller.rowCount + (isHasHeader ? 1 : 0))), id: \.self) { j in
                        GeometryReader { _ in
                            if isHasHeader && j < controller.columnCount {
                                header(Week.allCases[j])
                            } else {
                                let date = cellToDate(j - (isHasHeader ? 7 : 0))
                                self.content(date, isCurrentMonth(date))
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
    
    func cellToDate(_ cellIndex: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        
        let toDate = controller.date
        let weekday = gregorian.component(.weekday, from: toDate) // 1Sun, 2Mon, 3Tue, 4Wed, 5Thu, 6Fri, 7Sat
        var components = DateComponents()
        components.day = cellIndex + 1 - weekday
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
