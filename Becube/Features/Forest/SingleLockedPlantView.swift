//
//  SingleLockedPlant.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 19/08/26.
//

import SwiftUI

struct SingleLockedPlant: View {
    let skill : CopingSkill
    @Environment(Router.self) private var router
    @Environment(GardenStore.self) private var gardenStore

    /// The same rule the forest map uses: the collected drawing once the skill has
    /// been earned, the pre-practice one before that. Ground art rather than the
    /// potted `unlockedVase` variant, since the plant is standing on grass here.
    ///
    /// `plantImageName(_:)` falls back to the placeholder on its own for skills
    /// whose art hasn't been drawn yet, so this stays correct as illustrations land.
    private var plantImageName: String {
        skill.plantImageName(gardenStore.hasUnlockedPlant(id: skill.id) ? .unlocked : .locked)
    }
    
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
                            
                            Image(plantImageName)
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
                                
                                HStack (spacing: 3){
                                    Text ("Plant name: ")
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.darkBrown)
                                        .padding(.bottom, 13)
                                
                                    Text(skill.plantName ?? "")
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .foregroundStyle(.darkBrown)
                                        .padding(.bottom, 13)
                                }
                                
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
                        
                        Button {
                            router.push(.learn(skillID: skill.id))
                        } label: {

                            Text("Learn")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.darkBrown)
                                .clipShape(Capsule())
                        }
                        
                        // A plain push, not `practiceAfterLearning` — jumping in
                        // from here should keep this screen underneath, so backing
                        // out of practice lands on the plant again.
                        Button {
                            router.push(.practice(skillID: skill.id))
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
