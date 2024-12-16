//
//  ContentView.swift
//  Prototypes
//
//  Created by Josh Nelson on 11/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Prototypes")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                
                List {
                    NavigationLink("ID Card") {
                        IDCard()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemBackground))
                            .ignoresSafeArea()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton()
                                }
                            }
                            .navigationBarBackButtonHidden()
                    }
                    NavigationLink("Things List Cell") {
                        ThingsListCell()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemBackground))
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton()
                                }
                            }
                            .navigationBarBackButtonHidden()
                    }
                    NavigationLink("Counter") {
                        Counter()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemBackground))
                            .ignoresSafeArea()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton()
                                }
                            }
                            .navigationBarBackButtonHidden()
                    }
                    
                    NavigationLink("Things Search Icon") {
                        ThingsSearchIcon()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemBackground))
                            .ignoresSafeArea()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton()
                                }
                            }
                            .navigationBarBackButtonHidden()
                    }
                    
                    NavigationLink("TBD") {
                        FamilyTray()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemBackground))
                            .ignoresSafeArea()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton()
                                }
                            }
                            .navigationBarBackButtonHidden()
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ContentView()
}
