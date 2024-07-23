//
//  ContentView.swift
//  TKDocParser
//
//  Created by Toseef on 19/07/24.
//

import SwiftUI
import TKDocumentParser

import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isPickerPresented = false
    @State private var extractedText = ""
    @State private var showDetail = false
    @State private var errorMsg = ""

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    isPickerPresented = true
                }) {
                    Text("Pick File")
                }
                .padding()

                Text(errorMsg)
                    .foregroundColor(.red)

                NavigationLink(destination: DetailView(text: extractedText), isActive: $showDetail) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $isPickerPresented, onDismiss: {
                if !extractedText.isEmpty {
                    showDetail = true
                }
            }) {
                DocumentPicker(extractedText: $extractedText)
            }
            .navigationBarTitle("TKDocParser")
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var extractedText: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType(filenameExtension: "docx")!, UTType(filenameExtension: "doc")!])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let text = try TKDocumentParser.parseText(from: url)
                print("extractedText: \(text)")
                DispatchQueue.main.async {
                    self.parent.extractedText = text
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.parent.extractedText = error.localizedDescription
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            DispatchQueue.main.async {
                self.parent.extractedText = ""
            }
        }
    }
}

struct DetailView: View {
    var text: String

    var body: some View {
        ScrollView {
            Text(text)
                .padding()
        }
        .navigationBarTitle("Parsed Text", displayMode: .inline)
    }
}


#Preview {
    ContentView()
}
