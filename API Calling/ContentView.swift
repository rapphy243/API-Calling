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
    @State private var showingAlert = false
    @Environment(\.openURL) var openURL //used for if AIOD is a video
    var body: some View {
        NavigationView {
            VStack {
                Text(dailyImage.title)
                    .font(.title).bold()
                if dailyImage.media_type == "image" { //Sometimes APOD is a video
                    customAsyncImage(url: dailyImage.url)
                }
                else {
                    customAsyncImage(url: dailyImage.thumbnail_url)
                        .onTapGesture {
                            openURL(dailyImage.url!)
                        }
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
                    DatePicker("", selection: $date, in: dateFromFirstImage(), displayedComponents: .date)
                        .onChange(of: date) {
                            Task { // https://stackoverflow.com/questions/74449780/ios-swiftui-cannot-pass-function-of-type-async-void-to-parameter-expec
                                await getDailyImage(date: date)
                            }
                        }
                    }
                ToolbarItem(placement: .topBarLeading) {
                    Text("Astronomy Picture Date:")
                }
            }
        }
        .navigationTitle("NASA Image of the Day")
        .task {
            await getDailyImage()
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Loading Error"), message: Text("There was a problem loading the APOD"))
        })
    }
    
    func getDailyImage() async {
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd" // I don't like baking API keys, but there doesn't seem like any way to easily make a Secrets file.
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey + "&thumbs=True"
        if let url = URL(string: query){
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedData = try? JSONDecoder().decode(DailyImage.self, from: data) {
                    self.dailyImage = decodedData
                    return
                }
            }
        }
        showingAlert = true
    }
    
    func getDailyImage(date: Date) async {
        let date = dateToString(date: date)
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd"
        let query = "https://api.nasa.gov/planetary/apod?api_key=" + apikey + "&date=" + date + "&thumbs=True"
        if let url = URL(string: query){
            if let (data, _) = try? await URLSession.shared.data(from: url) { // Decode data to dailyImage struct
                if let decodedData = try? JSONDecoder().decode(DailyImage.self, from: data) {
                    self.dailyImage = decodedData
                    return
                }
            }
        }
        showingAlert = true
    }
    
    func dateToString (date: Date) -> String { // Helper function for getDailyImage
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        return dateFormater.string(from: date)
    }
    
    func dateFromFirstImage() -> ClosedRange<Date> { // Used for date picker so user cannot input a invalid date
        var dateComponents = DateComponents()
        dateComponents.year = 1995
        dateComponents.month = 6
        dateComponents.day = 16
        //This date is the first APOD
        return Calendar.current.date(from: dateComponents)!...Date()
    }
}

struct customAsyncImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: 350)
                .frame(height: 350)
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: "photo.fill")
                .border(Color.gray)
                .frame(width: 250, height: 350)
        }
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
