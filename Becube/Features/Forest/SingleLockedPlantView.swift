//
//  SingleLockedPlant.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 19/08/26.
//

import SwiftUI

struct SingleLockedPlant: View {
    let skill : CopingSkill
    @Environment(GardenStore.self) var gardenStore
    
    var body: some View{
        
        //Background
        GeometryReader { fullGeo in
            
            ZStack(alignment: .bottom){
                Color("Blue BG")
                
                Image("Grass")
                    .resizable()
                    .scaledToFill()
                    .frame(width: fullGeo.size.width, height: fullGeo.size.height * 0.57)
                    .clipped()
                
                
                VStack{
                    HStack{
                        BackButton()
                        Spacer()
                    }
                    .padding(.top, 68)
                    
                    Spacer()
                    
                    //Flower area
                    VStack (spacing: 33){
                        ZStack (alignment: .bottom){
                            Image("FlowerShadow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 208, height: 35.9)
                                .offset(x: -10, y: 15 )
                            
                            Image("FlowerPlantPlaceholder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 190.6, height: 178.22)
                            
                            
                        }
                        
                        
                        //Card Informations
                        CommentBox(bulge: 6, tailPosition: .topCenter, contentPadding: 24) {
                            VStack(spacing: 2) {
                                Text(skill.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.darkBrown)
                                
                                Text(skill.plantPhilosophy)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.darkBrown)
                                    .padding(.bottom, 13)
                                
                                Text(skill.info["what"] ?? "Description is not found.")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.darkBrown)
                                    .foregroundStyle(.secondary)
                            }
                            
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15){
                        
                        NavigationLink{
                            
                            let learnVM = LearnViewModel(skillID: skill.id, gardenStore: gardenStore)
                            LearnView(viewModel: learnVM)
                            
                        }label: {
                            
                            Text("Learn")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.darkBrown)
                                .clipShape(Capsule())
                        }
                        
                        NavigationLink {
                            
                            Text("\(skill.name)")
                                .font(.title)
                            
                        } label: {
                            
                            Text("Jump Straight to Practice")
                                .font(.footnote)
                                .underline()
                                .foregroundStyle(Color.darkBrown)
                        }
                        
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .frame(width: fullGeo.size.width, height: fullGeo.size.height)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        // hides the system's automatic back button, since we're drawing our own in "header"
        .toolbar(.hidden, for: .navigationBar)
        // hides the system's navigation bar entirely, so only our custom header shows
    }
    
}
