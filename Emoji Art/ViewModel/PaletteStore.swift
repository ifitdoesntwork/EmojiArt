//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/10/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes: [Palette] {
        didSet {
            if 
                palettes.isEmpty,
                !oldValue.isEmpty
            {
                palettes = oldValue
            }
        }
    }
    
    init(
        named name: String
    ) {
        self.name = name
        palettes = Palette.builtins
        
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
    
    @Published private var _cursorIndex = Int.zero
    
    var cursorIndex: Int {
        get {
            boundsCheckedPaletteIndex(_cursorIndex)
        }
        
        set {
            _cursorIndex = boundsCheckedPaletteIndex(newValue)
        }
    }
    
    private func boundsCheckedPaletteIndex(
        _ index: Int
    ) -> Int {
        var index = index % palettes.count
        
        if index < .zero {
            index += palettes.count
        }
        
        return index
    }
    
    // MARK: - Adding Palettes
    
    func insert(
        _ palette: Palette,
        at insertionIndex: Int? = nil // default is cursorIndex
    ) {
        let insertionIndex = boundsCheckedPaletteIndex(
            insertionIndex ?? cursorIndex
        )
        palettes
            .firstIndex { $0.id == palette.id }
            .map {
                palettes
                    .move(
                        fromOffsets: IndexSet([$0]),
                        toOffset: insertionIndex
                    )
                palettes
                    .replaceSubrange(
                        insertionIndex...insertionIndex,
                        with: [palette]
                    )
            }
        ?? palettes
            .insert(
                palette,
                at: insertionIndex
            )
    }
    
    func insert(
        name: String,
        emojis: String,
        at index: Int? = nil
    ) {
        insert(
            Palette(name: name, emojis: emojis),
            at: index
        )
    }
    
    func append(
        _ palette: Palette
    ) {
        palettes
            .firstIndex { $0.id == palette.id }
            .map {
                if palettes.count == 1 {
                    palettes = [palette]
                } else {
                    palettes
                        .remove(at: $0)
                    palettes
                        .append(palette)
                }
            }
        ?? palettes
            .append(palette)
    }
    
    func append(
        name: String,
        emojis: String
    ) {
        append(Palette(name: name, emojis: emojis))
    }
}
