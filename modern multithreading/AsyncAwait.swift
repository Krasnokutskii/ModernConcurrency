//
//  AsyncAwait.swift
//  modern multithreading
//
//  Created by Ярослав Краснокутский on 16.9.24..
//

import SwiftUI

class AsyncAwaitVM: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Tititle 1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                let title2 = "Title3 : \(Thread.current)"
                self.dataArray.append(title)
                self.dataArray.append(title2)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1: \(Thread.current)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "Author2: \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(author2)
            
            let author3 = "Author3: \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
}

struct AsyncAwait: View {
    @StateObject private var viewModel = AsyncAwaitVM()
    var body: some View {
        List{
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor1()
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwait()
}
