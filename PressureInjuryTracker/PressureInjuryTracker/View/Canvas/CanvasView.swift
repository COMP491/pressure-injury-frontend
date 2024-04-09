//
//  CanvasView.swift
//  PressureInjuryTracker
//
//  Created by Eren Ergün on 9.04.2024.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @Binding var image: UIImage?
    @Binding var showCanvas: Bool
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()

    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Button("Cancel") {
                    showCanvas = false
                }.padding(.horizontal)
            }
            if let uiImage = self.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(CanvasRepresentable(canvasView: $canvasView, toolPicker: $toolPicker).edgesIgnoringSafeArea(.all))
            }
            
            HStack {
                Button(action: undo) {
                    Text("Undo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: redo) {
                    Text("Redo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    saveAnnotatedImage()
                    self.showCanvas = false
                }) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            self.toolPicker.setVisible(true, forFirstResponder: self.canvasView)
            self.canvasView.becomeFirstResponder()
        }
    }

    struct CanvasRepresentable : UIViewRepresentable {
        @Binding var canvasView: PKCanvasView
        @Binding var toolPicker: PKToolPicker

        func makeUIView(context: Context) -> PKCanvasView {
            canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
            canvasView.isOpaque = false
            canvasView.backgroundColor = UIColor.clear
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            return canvasView
        }

        func updateUIView(_ uiView: PKCanvasView, context: Context) {
        }
    }

    func undo() {
        canvasView.undoManager?.undo()
    }

    func redo() {
        canvasView.undoManager?.redo()
    }

    func saveAnnotatedImage() {
        let drawing = canvasView.drawing
        let imageRect = CGRect(x: 0, y: 0, width: canvasView.bounds.width, height: canvasView.bounds.height)
        let renderer = UIGraphicsImageRenderer(bounds: imageRect)
        self.image = renderer.image { (ctx) in
            self.image?.draw(in: imageRect)
            drawing.image(from: imageRect, scale: 1.0).draw(in: imageRect)
        }
    }
}