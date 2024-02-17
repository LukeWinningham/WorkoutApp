//
//  WorkoutPacks.swift
//  Amson
//
//  Created by Luke Winningham on 2/17/24.
//

import SwiftUI
import Foundation
import Combine
import CloudKit



struct WorkoutPacks: View {
    @EnvironmentObject var weekData: WeekData
     @State private var packName: String = ""
     @State private var packDescription: String = ""
     @State private var isShowingAddView = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color(red: 18/255, green: 18/255, blue: 18/255)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    headerView
                    Rectangle() // This creates the border line
                        .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Set the border color here
                        .frame(height: 2) // Set the border thickness here
                    daysListView
                    Rectangle() // This creates the border line
                        .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Set the border color here
                        .frame(height: 2) // Set the border thickness here
                }
            }
        }
    }

    
    var headerView: some View {
        HStack {
            Spacer()
            Text("Workout Packs")
                .font(.title)
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .padding()
            Spacer()
            
        }
        
    }
    
    var daysListView: some View {
          ScrollView(showsIndicators: false) {
              VStack(spacing: 10) {
                  ForEach(0..<3) { _ in // Assuming you want 10 packs, so 5 rows
                      HStack(spacing: 50) {
                          ForEach(0..<2) { _ in // 2 packs per line
                              NavigationLink(destination: AddView()) {
                                  VStack {
                                      Image("pack")
                                          .resizable()
                                          .aspectRatio(contentMode: .fill)
                                          .frame(width: 150, height: 200)
                                          .clipShape(RoundedRectangle(cornerRadius: 5))
                                      
                                      VStack {
                                          Text("Sam Sulek")
                                              .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                          Text("Cut Workout Plan")
                                              .font(.callout)
                                              .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                             
                                      }
                                  }
                              }
                              .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to remove button style
                          }
                      }
                  }
              }
              .padding(.horizontal, 10) // Add horizontal padding
          }
      }
    func createWorkoutPack() {
           // Generate a unique ID for the workout pack
           let packID = UUID().uuidString

           // Create a record in CloudKit
           let record = CKRecord(recordType: "WorkoutPacks")
           record["PackID"] = packID
           record["Name"] = packName
           record["Description"] = packDescription

           let database = CKContainer.default().publicCloudDatabase
           database.save(record) { (record, error) in
               if let error = error {
                   print("Error saving record: \(error.localizedDescription)")
               } else {
                   print("Record saved successfully.")
                   // Optionally, you can update your UI to reflect the newly created workout pack.
               }
           }
       }
   }
struct WorkoutPacks_Previews: PreviewProvider {
    static var previews: some View {
        
        WorkoutPacks()
            .environmentObject(WeekData.shared)
    }
}

   

