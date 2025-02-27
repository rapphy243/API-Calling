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
    @Environment(\.openURL) var openURL //used for if AIOD is a video
    var body: some View {
        NavigationView {
            VStack {
                Text(dailyImage.title)
                    .font(.title).bold()
                if dailyImage.media_type == "image" { //Sometimes APOD is a video
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
                else {
                    AsyncImage(url: dailyImage.thumbnail_url) { image in // https://www.swiftanytime.com/blog/asyncimage-in-swiftui
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "photo.fill")
                            .border(Color.gray)
                        
                    }
                    .onTapGesture {
                        openURL(dailyImage.url!)
                    }
                    .frame(width: 250, height: 350)
                    Text("Tap Image To Watch Video")
                        .font(.caption)
                    
                }
                ScrollView {
                    Text(dailyImage.explanation)
                        .font(.body)
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
                ToolbarItem(placement: .topBarLeading) {
                    Text("Astronomy Picture Date: ")
                }
                
            }
        }
        .navigationTitle("NASA Image of the Day")
        .task {
            await getDailyImage()
        }
    }
    
    func getDailyImage() async {
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd" // I don't like baking API keys, but there doesn't seem like any way to easily make a Secrets file.
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey + "&thumbs=True"
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
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd"
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey + "&date=" + date + "&thumbs=True"
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
    var media_type: String // Sometimes image of the day is a video...
    var thumbnail_url: URL? // If it is a video get the thumbnail
    
    init() {
        title = ""
        explanation = ""
        date = ""
        media_type = "image"
    }
}

#Preview {
    ContentView()
}
