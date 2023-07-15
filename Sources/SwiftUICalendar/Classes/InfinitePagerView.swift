//
//  InfinitePagerView.swift
//  SwiftUICalendar
//
//  Created by GGJJack on 2021/10/22.
//

import Foundation
import SwiftUI
import Combine

internal struct InfinitePagerView<Content: View>: View {
    @State private var internalIndex = 2
    @Binding var index: Int
    private let maxIndex = 3, middleIndex = 2
    @State private var step: Int = 0
    private let content: (Int) -> Content
    private let flippingAngle: Angle = Angle(degrees: 0)
    private var orientation: Orientation
    @State var isLocked: Bool = false
    
    init(_ index: Binding<Int>, orientation: Orientation, @ViewBuilder content: @escaping (Int) -> Content) {
        self.content = content
        self.orientation = orientation
        self._index = index
    }
    
    var body: some View {
        drawTabView {// geometry in
            //ForEach(0..<maxIndex, id: \.self) { i in
                //let date = controller.offsetedFocus(by: i - maxIndex)
            self.content(index - 1).tag(1)
            self.content(index + 0).tag(2)
                .onDisappear {
                    internalIndex = middleIndex
                    index += step
                    step = 0
                }
            self.content(index + 1).tag(3)
                    //.frame(width: geometry.size.width, height: geometry.size.height)
                    /*.background(GeometryReader {
                        Color.clear.preference(key: ScrollOffsetKey.self, value: (controller.orientation == .horizontal ? -$0.frame(in: .named("scroll")).origin.x : -$0.frame(in: .named("scroll")).origin.y))
                    })*/
                    /*
                    .onPreferenceChange(ScrollOffsetKey.self) {
                        controller.scrollDetector.send($0)
                    }*/
            //}
        }
    }
    
    @ViewBuilder
    private func drawTabView<V: View>(@ViewBuilder content: @escaping (/*GeometryProxy*/) -> V) -> some View {
        //GeometryReader { proxy in
            if self.orientation == .horizontal {
                TabView(selection: $internalIndex) {
                    content(/*proxy*/)
                        .contentShape(Rectangle())
                        .gesture(isLocked ? DragGesture() : nil)
                }
                //.frame(width: proxy.size.width, height: proxy.size.height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .coordinateSpace(name: "scroll")
                .onChange(of: internalIndex) { newValue in
                    if [1, 3].contains(newValue) {
                        step = newValue - middleIndex
                    }
                }
            }
            else {
                TabView(selection: $internalIndex) {
                    content(/*proxy*/)
                        //.frame(width: proxy.size.width, height: proxy.size.height)
                        .rotationEffect(.degrees(-90))
                        .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
                        .contentShape(Rectangle())
                        .gesture(isLocked ? DragGesture() : nil)
                }
                //.frame(width: proxy.size.height, height: proxy.size.width)
                .rotation3DEffect(flippingAngle, axis: (x: 1, y: 0, z: 0))
                .rotationEffect(.degrees(90), anchor: .topLeading)
                //.offset(x: proxy.size.width)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .coordinateSpace(name: "scroll")
                .onChange(of: internalIndex) { newValue in
                    if [1, 3].contains(newValue) {
                        step = newValue - middleIndex
                    }
                }
            }
        //}
    }
}
