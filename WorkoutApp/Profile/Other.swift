//
//  Other.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//

import SwiftUI
import Combine

struct Other: View {

    var body: some View {
            RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Use any color that fits your design
                .frame(height: 170) // Adjust size as needed
                .shadow(radius: 5) // Adjust shadow radius as needed
                .overlay(
                   
                    VStack(alignment: .leading, spacing: 1) { // Adjust spacing between rows here
                        
                        Text("Other")
                            .font(.title3)
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            .bold()
                            .padding( .leading, 10.0)
                            .padding( .top, 15.0)
                        
                        VStack(spacing: -5.0){
                            HStack{
                                Image(systemName: "envelope")
                                    .foregroundColor(Color.white) // Use your own image or system image name
                                    .padding( .leading, 7.0)
                                Text("Contact Us")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                    .frame(width: 50, height: 50)
                                    .imageScale(.large)
                            }
                            HStack{
                                Image(systemName: "checkmark.seal")
                                    .foregroundColor(Color.yellow) // Use your own image or system image name
                                    .padding( .leading, 10.0)
                                Text("Privacy Policy")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                    .frame(width: 50, height: 50)
                                    .imageScale(.large)
                            }
                            HStack{
                                Image(systemName: "gear")
                                    .foregroundColor(Color.gray) // Use your own image or system image name
                                    .padding( .leading, 11)
                                Text("Settings")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))                                    .frame(width: 50, height: 50)
                                    .imageScale(.large)
                            }
                            
                        }
                   
                    
                    }
                )
                .padding(.horizontal, 15) // Padding applied to the Button

        }
      
    }


// Correct way to define a preview provider for your SwiftUI view
struct Other_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Other()
        }
    }
}
