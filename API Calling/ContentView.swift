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
                AsyncImage(url: dailyImage.url) { image in // https://www.swiftanytime.com/blog/asyncimage-in-swiftui
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "photo.fill")
                }
                .frame(width: 250, height: 350)
                .border(Color.gray)
                Text(dailyImage.date)
                Text(dailyImage.explanation)
                    .padding()
            }
        }
        .task {
            await getDailyImage()
        }
    }
    
    func getDailyImage() async {
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd"
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
        let apikey = "Yex2GxflPAs3lIfcWO8ZIMqvoQ9RTDViTvgCvZNd"
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
    
    init() {
        url = URL(string: "")
        title = ""
        explanation = ""
        date = ""
    }
}

#Preview {
    ContentView()
}
