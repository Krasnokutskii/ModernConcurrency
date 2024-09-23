//
//  TaskGroup.swift
//  modern multithreading
//
//  Created by Ярослав Краснокутский on 23.9.24..
//

import SwiftUI

class TaskGroupViewModel: ObservableObject {
    @Published var images = [UIImage]()
    
    func fetchImages() async {
        let images = try? await fetchImagesWithTaskGroup()
        if let images = images {
            await MainActor.run {
                self.images.append(contentsOf: images)
            }
        }
    }
    
    private var imageUrls = [
        "https://picsum.photos/100",
        "https://picsum.photos/200",
        "https://picsum.photos/300",
        "https://picsum.photos/400",
        "https://picsum.photos/500",
        "https://picsum.photos/600",
        "https://picsum.photos/700"
    ]
    
    private func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images = [UIImage]()
            images.reserveCapacity(imageUrls.count)
            for url in imageUrls {
                group.addTask {
                    try? await self.fetchImage(string: url)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
   
    private func fetchImage(string: String) async throws -> UIImage{
        do {
            let url = URL(string: string)!
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
        
    }
}

struct TaskGroup: View {
    @StateObject var viewModel = TaskGroupViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], content: {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                })
            }
            .onTapGesture {
                Task {
                    print("tap")
                    await viewModel.fetchImages()
                }
            }
            .navigationTitle("Task Group")
        }
    }
}

#Preview {
    TaskGroup()
}
