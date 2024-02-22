//
//  AccountCard.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//
import SwiftUI
import Combine

struct AccountCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
            .frame(height: 250)
            .shadow(radius: 5)
            .overlay(
                VStack(alignment: .leading, spacing: 15) {
                    Text("Account")
                        .font(.title)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .bold()
                        .padding(.leading, 4)
                        .padding(.top, 15)
                    
               /*     HStack {
                        Image(systemName: "doc.plaintext")
                            .foregroundColor(Color.white)
                            .font(.title2)
                            .frame(width: 30)
                        
                        Text("Data")
                            .font(.title2)
                          
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(minWidth: 70, alignment: .leading)
                          
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(width: 30, height: 30)
                            .imageScale(.large)
                            .padding(.trailing, 10)
                    }
                    */
                    HStack {
                        Image(systemName: "trophy")
                            .foregroundColor(Color.yellow)
                            .frame(width: 30)
                            .font(.title2)

                        Text("Achievements")
                            .font(.title2)
                            
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(minWidth: 70, alignment: .leading)
                            
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(width: 30, height: 30)
                            .imageScale(.large)
                            .padding(.trailing, 10)
                    }
                    
             /*      HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(Color.green)
                            .font(.title2)
                            .frame(width: 30)
                        
                        Text("Progress")
                            .font(.title2)
                           
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(minWidth: 70, alignment: .leading)
                            
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .frame(width: 30, height: 30)
                            .imageScale(.large)
                            .padding(.trailing, 10)
                    }
              */
                    HStack {
                               Image(systemName: "envelope")
                                   .foregroundColor(Color.white)
                                   .font(.title2)
                                   .frame(width: 30)
                               
                               Text("Contact Us")
                                   .font(.title2)
                                  
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
                                   .foregroundColor(Color.green)
                                   .font(.title2)
                                   .frame(width: 30)
                               
                               Text("Privacy Policy")
                                   .font(.title2)
                                  
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
                                   .font(.title2)
                                   .frame(width: 30)
                               
                               Text("Settings")
                                   .font(.title2)
                                  
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
                    .padding([.leading, .bottom, .trailing], 15)
            )
            .padding(.horizontal, 15)

    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        AccountCard()
    }
}
