//
//  RunVictoryScreen.swift
//  PixelHeroDefenseTD
//
//  Після 30-ї хвилі: можна увімкнути нескінченний забіг або перезапустити.
//

import SwiftUI

struct RunVictoryScreen: View {
  let onContinueEndless: () -> Void
  let onRestart: () -> Void

  var body: some View {
	 ZStack {
		Color.black.ignoresSafeArea().opacity(0.25)
		VStack(spacing: 22) {
		  Text("Run cleared")
			 .font(.custom("antiquity-print", size: 36))
			 .foregroundStyle(
				LinearGradient(
				  colors: [Color(red: 0.95, green: 0.82, blue: 0.45), Color(red: 0.65, green: 0.5, blue: 0.2)],
				  startPoint: .leading,
				  endPoint: .trailing
				)
			 )
			 .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)

		  Text("Boss wave 20 defeated.\nContinue in endless mode?")
			 .font(.subheadline.monospaced())
			 .multilineTextAlignment(.center)
			 .foregroundStyle(.white.opacity(0.9))

		  VStack(spacing: 14) {
			 Button {
				onContinueEndless()
			 } label: {
				Text("Endless mode")
				  .foregroundStyle(.white)
				  .monospaced()
				  .padding()
				  .frame(maxWidth: .infinity)
				  .background(
					 RoundedRectangle(cornerRadius: 12)
						.fill(Color.green.opacity(0.35))
				  )
				  .overlay(
					 RoundedRectangle(cornerRadius: 12)
						.stroke(Color.white.opacity(0.25), lineWidth: 1)
				  )
			 }

			 Button {
				onRestart()
			 } label: {
				Text("Restart run")
				  .foregroundStyle(.white.opacity(0.9))
				  .monospaced()
				  .padding()
				  .frame(maxWidth: .infinity)
				  .background(
					 RoundedRectangle(cornerRadius: 12)
						.fill(Color.red.opacity(0.28))
				  )
				  .overlay(
					 RoundedRectangle(cornerRadius: 12)
						.stroke(Color.white.opacity(0.2), lineWidth: 1)
				  )
			 }
		  }
		  .padding(.horizontal, 28)
		}
		.padding(32)
	 }
 }
}

#Preview {
  RunVictoryScreen(onContinueEndless: {}, onRestart: {})
}
