//
//  ContentView.swift
//  DesignTokensSystem
//
//  Created by Gab on 1/9/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loader = ColorLoader.shared
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.4)
            
            VStack(spacing: GabDesignModel.Popup.Sys.Vstack.spacing) {
                Group {
                    contentView
                    
                    buttonView
                }
                .padding(.horizontal, GabDesignModel.Popup.Sys.Content.Padding.horizontal)
            }
            .padding(.top, GabDesignModel.Popup.Sys.Content.Padding.top)
            .padding(.bottom, GabDesignModel.Popup.Sys.Content.Padding.bottom)
            .background(GabDesignModel.Popup.Sys.Background.primaryColor)
            .cornerRadius(GabDesignModel.Popup.Sys.Radius.primary)
            .shadow(
                color: GabDesignModel.Popup.Sys.Shadow.Primary.value.color,
                radius: GabDesignModel.Popup.Sys.Shadow.Primary.value.blur,
                x: GabDesignModel.Popup.Sys.Shadow.Primary.value.x,
                y: GabDesignModel.Popup.Sys.Shadow.Primary.value.y
            )
            .padding(.horizontal, GabDesignModel.Popup.Sys.Primary.Padding.horizontal)
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        VStack(spacing: GabDesignModel.Popup.Sys.Content.Vstack.spacing) {
            AsyncImage(url: URL(string: GabDesignModel.Popup.Content.amber)) { (result: AsyncImagePhase) in
                result.image?
                    .resizable()
                    .scaledToFit()
//                    .resizable()
            }
//            .frame(width: 240, height: 120)
            
            if !GabDesignModel.Popup.Sys.title.isEmpty {
                Text(GabDesignModel.Popup.Sys.title)
                    .font(.system(size: 18))
                    .foregroundStyle(GabDesignModel.Popup.Sys.Content.titleColor)
            }
            
            if !GabDesignModel.Popup.Sys.subtitle.isEmpty {
                Text(GabDesignModel.Popup.Sys.subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(GabDesignModel.Popup.Sys.Content.subtitleColor)
            }
            
            if !GabDesignModel.Popup.Sys.description.isEmpty {
                Text(GabDesignModel.Popup.Sys.description)
                    .font(.system(size: 13))
                    .foregroundStyle(GabDesignModel.Popup.Sys.Content.descriptionColor)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    var buttonView: some View {
        Button {
            
        } label: {
            Text("Confirm")
                .font(.system(size: 16))
                .foregroundStyle(GabDesignModel.Popup.Sys.Button.titleColor)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(GabDesignModel.Popup.Sys.Button.backgroundColor)
        .cornerRadius(GabDesignModel.Popup.Sys.Button.radius)

    }
}

#Preview {
    ContentView()
}
