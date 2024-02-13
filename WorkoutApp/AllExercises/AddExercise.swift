//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/12/24.
//

import SwiftUI
import Combine

struct AddExercise: View {
    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack{
                VStack {
                    Text("Bench Press")
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    Text("Chest")
                        .font(.title3)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        
                }
                .padding()
                VStack{
     
                    Circle()
                        .frame(width: 160.0, height: 160.0)
                        .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255))
                        .overlay(
                            Image("weightboy")
                                .resizable() // Allows the image to be resized
                                .aspectRatio(contentMode: .fill) // Keeps the aspect ratio and fills 
                                .padding(.trailing, 10)
                        )

                    VStack{
                        Text("Sets")
                            .font(.title)
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    }
                    .padding()
                }
            }
        }
            }
           
        }

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        AddExercise()
    }
}

