//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    @Published private var emojiArt = EmojiArt()
    
    init() {
//        emojiArt
//            .addEmoji("🚲", at: .init(x: -200, y: -150), size: 200)
//        emojiArt
//            .addEmoji("🔥", at: .init(x: 250, y: 100), size: 80)
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: - Intent(s)
    
    func setBackground(
        _ url: URL?
    ) {
        emojiArt.background = url
    }
    
    func addEmoji(
        _ emoji: String,
        at position: Emoji.Position,
        size: CGFloat
    ) {
        emojiArt
            .addEmoji(emoji, at: position, size: Int(size))
    }
    
    func removeEmoji(
        _ emoji: Emoji
    ) {
        emojiArt
            .removeEmoji(emoji)
    }
    
    func move(
        _ emoji: Emoji,
        by offset: CGOffset
    ) {
        let existingPosition = emojiArt[emoji]
            .position
        
        emojiArt[emoji].position = .init(
            x: existingPosition.x + Int(offset.width),
            y: existingPosition.y - Int(offset.height)
        )
    }
    
    func move(
        emojiWithId id: Emoji.ID,
        by offset: CGOffset
    ) {
        emojiArt[id]
            .map { move($0, by: offset) }
    }
    
    func resize(
        _ emoji: Emoji,
        by scale: CGFloat
    ) {
        emojiArt[emoji].size = Int(
            CGFloat(emojiArt[emoji].size) * scale
        )
    }
    
    func resize(
        emojiWithId id: Emoji.ID,
        by scale: CGFloat
    ) {
        emojiArt[id]
            .map { resize($0, by: scale) }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        .system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(
        _ geometry: GeometryProxy
    ) -> CGPoint {
        let center = geometry
            .frame(in: .local)
            .center
        
        return .init(
            x: center.x + CGFloat(x),
            y: center.y - CGFloat(y)
        )
    }
}

