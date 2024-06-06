//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by CS193p Instructor on 5/8/23.
//  Copyright (c) 2023 Stanford University
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    @ObservedObject var document: EmojiArtDocument
    
    private let paletteEmojiSize: CGFloat = 40
    private let borderWidth: CGFloat = 2
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    @GestureState private var selectionGesturePan: CGOffset = .zero
    
    @State private var selection = Set<Emoji.ID>()
    
    var body: some View {
        VStack(spacing: .zero) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
}

private extension EmojiArtDocumentView {
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * (selection.isEmpty ? gestureZoom : 1))
                    .offset(pan + gesturePan)
            }
            .onTapGesture {
                selection.removeAll()
            }
            .gesture(
                panGesture
                    .simultaneously(with: zoomGesture)
            )
            .dropDestination(
                for: Sturldata.self
            ) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    func documentContents(
        in geometry: GeometryProxy
    ) -> some View {
        AsyncImage(url: document.background)
            .position(
                Emoji.Position.zero
                    .in(geometry)
            )
        
        ForEach(document.emojis) {
            emoji($0, in: geometry)
        }
    }
    
    @ViewBuilder
    func emoji(
        _ emoji: Emoji,
        in geometry: GeometryProxy
    ) -> some View {
        let isSelected = selection
            .contains(emoji.id)
        
        Text(emoji.string)
            .font(emoji.font)
            .contextMenu {
                AnimatedActionButton(
                    "Delete",
                    systemImage: "minus.circle",
                    role: .destructive
                ) {
                    document.removeEmoji(emoji)
                }
            }
            .border(
                isSelected && selectionGesturePan == .zero ? .red : .clear,
                width: borderWidth
            )
            .scaleEffect(isSelected ? gestureZoom : 1)
            .position(emoji.position.in(geometry))
            .offset(
                isSelected ? selectionGesturePan : .zero
            )
            .onTapGesture {
                selection.toggle(emoji.id)
            }
            .gesture(
                isSelected ? selectionPanGesture: nil
            )
    }
    
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating(
                $gestureZoom
            ) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                func updateSelection() {
                    selection.forEach {
                        document.resize(
                            emojiWithId: $0,
                            by: endingPinchScale
                        )
                    }
                }
                
                selection.isEmpty
                    ? zoom *= endingPinchScale
                    : updateSelection()
            }
    }
    
    var panGesture: some Gesture {
        DragGesture()
            .updating(
                $gesturePan
            ) { inMotionDragGestureValue, gesturePan, _ in
                gesturePan = inMotionDragGestureValue.translation
            }
            .onEnded { endingDragGestureValue in
                pan += endingDragGestureValue.translation
            }
    }
    
    var selectionPanGesture: some Gesture {
        DragGesture()
            .updating(
                $selectionGesturePan
            ) { inMotionDragGestureValue, gesturePan, _ in
                gesturePan = inMotionDragGestureValue.translation
            }
            .onEnded { endingDragGestureValue in
                selection.forEach {
                    document.move(
                        emojiWithId: $0,
                        by: endingDragGestureValue.translation
                    )
                }
            }
    }
    
    func drop(
        _ sturldatas: [Sturldata],
        at location: CGPoint,
        in geometry: GeometryProxy
    ) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: paletteEmojiSize / zoom
                )
                return true
            default:
                break
            }
        }
        return false
    }
    
    func emojiPosition(
        at location: CGPoint,
        in geometry: GeometryProxy
    ) -> Emoji.Position {
        let center = geometry
            .frame(in: .local)
            .center
        
        return .init(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
}

struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
