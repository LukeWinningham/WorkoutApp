//
//  DiscoverPacks.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/13/24.
//

import SwiftUI
import Combine

struct DiscoverPacks: View {
    var body: some View {
        VStack(alignment: .leading) { // Align content to the leading edge
            Text("Workout Packs")
                .font(.title2)
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .multilineTextAlignment(.leading)
                .bold()
  
                


            ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll view
                HStack(spacing: 15) { // Add spacing between items in the scroll view
                    ForEach(0..<10) { _ in // Replace with your actual data source
                        VStack{
                            Image("pack") // Ensure you have an image named "background" in your assets
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                       
                            
                            VStack{
                                Text("Sam Sulek")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                Text("Cut Workout Plan")
                                    .font(.callout)
                                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            }
                        }
                    }
                }
                .padding(.trailing) // Add padding on both sides
            }
        }
        .padding() // Add padding around the entire VStack for cleaner edges
    }
}

struct DiscoverPacks_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiscoverPacks()
        }
    }
}
