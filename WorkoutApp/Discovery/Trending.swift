//
//  Trending.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/13/24.
//

import SwiftUI
import Combine
struct Trending: View {
    var body: some View {
        VStack(alignment: .leading) { // Align content to the leading edge
            Text("Trending")
                .font(.title2)
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .multilineTextAlignment(.leading)
                .bold()
  
                


            ScrollView(.horizontal, showsIndicators: false) { // Horizontal scroll view
                HStack(spacing: 15) { // Add spacing between items in the scroll view
                    ForEach(0..<10) { _ in // Replace with your actual data source
                        HStack(spacing: 40){
                            VStack{
                                Image("me") // Ensure you have an image named "background" in your assets
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                Text("Luke")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            }
                            
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
                        Spacer()
                    }
                }
                .padding(.trailing) // Add padding on both sides
            }
        }
        .padding() // Add padding around the entire VStack for cleaner edges
    }
}

struct Trending_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Trending()
        }
    }
}
