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
            .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
            .frame(height: 170)
            .shadow(radius: 5)
            .overlay(
                VStack(alignment: .leading, spacing: 15) {
                    Text("Other")
                        .font(.title3)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .bold()
                        .padding(.leading, 10)
                        .padding(.top, 15)
                    
                    VStack(spacing: 5) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(Color.white)
                                .font(.subheadline)
                                .frame(width: 30)
                                .padding(.leading, 10)
                            
                            Text("Contact Us")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(minWidth: 70, alignment: .leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(width: 30, height: 30)
                                .imageScale(.large)
                                .padding(.trailing, 10)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .foregroundColor(Color.yellow)
                                .frame(width: 30)
                                .padding(.leading, 10)
                            
                            Text("Privacy Policy")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(minWidth: 70, alignment: .leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(width: 30, height: 30)
                                .imageScale(.large)
                                .padding(.trailing, 10)
                        }
                        
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(Color.gray)
                                .font(.headline)
                                .frame(width: 30)
                                .padding(.leading, 10)
                            
                            Text("Settings")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(minWidth: 70, alignment: .leading)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .frame(width: 30, height: 30)
                                .imageScale(.large)
                                .padding(.trailing, 10)
                        }
                    }
                }
                    .padding([.leading, .bottom, .trailing], 10)
            )
            .padding(.horizontal, 15)

    }
}

struct Other_Previews: PreviewProvider {
    static var previews: some View {
        Other()
    }
}
