//
//  WaveStartBtn.swift
//  PixelHeroDefenseTD
//
//  Created by user on 24.03.2026.
//

import SwiftUI

struct WaveStartBtn: View {
  var body: some View {
	 VStack{
		  ZStack{
			 Image("Banner1")
				.resizable()
				.scaledToFit()
			 
			 Text("Next Wave")
				.font(.footnote.bold())
				.padding(.bottom, 10)
				.foregroundStyle(.white)
				.fontDesign(.monospaced)
		}
	 }
	 .frame(height: 50)
  }
}

#Preview {
    WaveStartBtn()
}
