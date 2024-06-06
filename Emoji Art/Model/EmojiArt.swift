//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import Foundation

struct EmojiArt {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = Int.zero
    
    mutating func addEmoji(
        _ emoji: String,
        at position: Emoji.Position,
        size: Int
    ) {
        uniqueEmojiId += 1
        emojis.append(Emoji(
            string: emoji,
            position: position,
            size: size,
            id: uniqueEmojiId
        ))
    }
    
    mutating func removeEmoji(
        _ emoji: Emoji
    ) {
        emojis
            .firstIndex { $0.id == emoji.id }
            .map { _ = emojis.remove(at: $0) }
    }
    
    struct Emoji: Identifiable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: .zero, y: .zero)
        }
    }
}

extension EmojiArt: HasIdentifiables {
    typealias I = Emoji
    
    var identifiables: [I] {
        get {
            emojis
        }
        set {
            emojis = newValue
        }
    }
}
