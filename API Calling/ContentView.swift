//
//  ContentView.swift
//  API Calling
//
//  Created by Raphael Abano on 2/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var dailyImage: DailyImage = DailyImage()
    @State private var date: Date = Date()
    var body: some View {
        NavigationView {
            VStack {
                Text(dailyImage.title)
                    .font(.title).bold()
                if dailyImage.media_type == "image" {
                    AsyncImage(url: dailyImage.url) { image in // https://www.swiftanytime.com/blog/asyncimage-in-swiftui
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "photo.fill")
                            .border(Color.gray)
                        
                    }
                    .frame(width: 250, height: 350)
                }
                ScrollView {
                    Text(dailyImage.explanation)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .onChange(of: date) {
                            Task { // https://stackoverflow.com/questions/74449780/ios-swiftui-cannot-pass-function-of-type-async-void-to-parameter-expec
                                await getDailyImage(date: date)
                            }
                        }
                }
            }
        }
        .navigationTitle("NASA Image of the Day")
        .task {
            await getDailyImage()
        }
    }
    
    func getDailyImage() async {
        let apikey = "DEMO_KEY"
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey
        if let url = URL(string: query){
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedData = try? JSONDecoder().decode(DailyImage.self, from: data) {
                    self.dailyImage = decodedData
                }
            }
        }
    }
    
    func getDailyImage(date: Date) async {
        let date = dateToString(date: date)
        let apikey = "DEMO_KEY"
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey + "&date=" + date
        if let url = URL(string: query){
            if let (data, _) = try? await URLSession.shared.data(from: url) { // Decode data to dailyImage struct
                if let decodedData = try? JSONDecoder().decode(DailyImage.self, from: data) {
                    self.dailyImage = decodedData
                }
            }
        }
    }
    
    func dateToString (date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        return dateFormater.string(from: date)
    }
}

struct DailyImage: Codable {
    var url: URL? // ? was added with suggestion of Github Copilot
    var title: String
    var explanation: String
    var date: String
    var media_type: String
    
    init() {
        url = URL(string: "")
        title = ""
        explanation = ""
        date = ""
        media_type = "image"
    }
}

#Preview {
    ContentView()
}
