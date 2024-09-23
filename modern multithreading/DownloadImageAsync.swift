//
//  DownloadImageAsync.swift
//  modern multithreading
//
//  Created by Ярослав Краснокутский on 16.9.24..
//

import SwiftUI
import Combine

// Task - Main 
// await - marking the place to suspend the code.
// Task.yield - suspend the code inside Task.
// async - marking the functions to show that it works asynchronosly.

class DownloadImageManager {
    let url = URL(string: "https://picsum.photos/200")!

    func handleResponse(data: Data? , response: URLResponse?) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode <= 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithEscaping(complitionHandler: @escaping (_ image: UIImage?, _ error: Error?)-> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            complitionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine()-> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({$0})
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    let loader = DownloadImageManager()
    var bug = Set<AnyCancellable>()
    
    
    
    func fetchImage() async {
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
    
//    func fetchImage() {
//        loader.downloadWithEscaping { [weak self] image, error in
//            if let image = image {
//                DispatchQueue.main.async {
//                    self?.image = image
//                }
//            }
//        }
//    }
    
//    func fetchImage() {
//        loader.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                
//            } receiveValue: { image in
//                self.image = image
//            }
//            .store(in: &bug)
//    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
        .onTapGesture {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
