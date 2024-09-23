//
//  AsynLet.swift
//  modern multithreading
//
//  Created by Ярослав Краснокутский on 23.9.24..
//

import SwiftUI

// Asyn let we use to run couple of task simultaniously.
// Simple, if we want more power use TaskGroup.

struct AsynLet: View {
    
    @State private var images: [UIImage] = []
    @State private var buttonText: BarButtonType = .serial
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 10, content: {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 160)
                            .mask(RoundedRectangle(cornerRadius: 25))
                    }
                })
            }
            .onTapGesture {
                switch buttonText {
                case .serial:
                    fetchImgesOneByOne()
                case .simultaniously:
                    fetchImagesSimultaniously()
                }
            }
            .navigationTitle("Async Let")
            .toolbar {
                Button(buttonText.rawValue) {
                    buttonText = buttonText == .serial ? .simultaniously : .serial
                }}
        }
    }
    
    func fetchImgesOneByOne() {
        // Images will appear one buy one
        Task {
            let image = try await fetchImage()
            self.images.append(image)
            let image2 = try await fetchImage()
            self.images.append(image2)
            let image3 = try await fetchImage()
            self.images.append(image3)
            let image4 = try await fetchImage()
            self.images.append(image4)
        }
    }
    
    func fetchImagesSimultaniously() {
        Task {
            // mark function as async let to run later with await.
            async let fetchImage1 = fetchImage()
            async let fetchImage2 = fetchImage()
            async let fetchImage3 = fetchImage()
            async let fetchImage4 = fetchImage()
            
            // loading here for all of them simultaniously
            let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4 )
            
            self.images.append(contentsOf: [image1, image2, image3, image4])
        }
    }
    
    func fetchImage() async throws -> UIImage{
        do {
            let url = URL(string: "https://picsum.photos/200")!
            let urlRequest = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: urlRequest)

            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
    enum BarButtonType: String {
        case serial = "Serial"
        case simultaniously = "Simultaniously"
    }
}

#Preview {
    AsynLet()
}
