//
//  Extension.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

typealias CGOffset = CGSize

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    init(
        center: CGPoint,
        size: CGSize
    ) {
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
}

extension CGOffset {
    static func +(lhs: CGOffset, rhs: CGOffset) -> CGOffset {
        CGOffset(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
    
    static func +=(lhs: inout CGOffset, rhs: CGOffset) {
        lhs = lhs + rhs
    }
}

extension String {
    // removes any duplicate Characters
    // preserves the order of the Characters
    var uniqued: String {
        // not super efficient
        // would only want to use it on small(ish) strings
        // and we wouldn't want to call it in a tight loop or something
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}

extension AnyTransition {
    static let rollUp: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .top)
    )
    
    static let rollDown: AnyTransition = .asymmetric(
        insertion: .move(edge: .top),
        removal: .move(edge: .bottom)
    )
}

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    var role: ButtonRole?
    let action: () -> Void
    
    init(
        _ title: String? = nil,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text(title)
            } else if let systemImage {
                Image(systemName: systemImage)
            }
        }
    }
}

protocol HasIdentifiables {
    associatedtype I: Identifiable
    var identifiables: [I] { get set }
}

extension HasIdentifiables {
    subscript(
        _ id: I.ID
    ) -> I? {
        index(of: id)
            .map { identifiables[$0] }
    }
    
    subscript(
        _ identifiable: I
    ) -> I {
        get {
            index(of: identifiable.id)
                .map { identifiables[$0] }
            ?? identifiable // should probably throw error
        }
        
        set {
            index(of: identifiable.id)
                .map { identifiables[$0] = newValue }
        }
    }
    
    private func index(
        of id: I.ID
    ) -> Int? {
        identifiables
            .firstIndex { $0.id == id }
    }
}

extension Set {
    mutating func toggle(
        _ element: Element
    ) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
