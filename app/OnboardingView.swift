//
//  OnboardingView.swift
//  app
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var onboardingService: OnboardingService
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { _ in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        onboardingService.onboardingData[onboardingService.currentStep].color.opacity(0.1),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            onboardingService.skipOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                    }

                    VStack(spacing: 40) {
                        Image(systemName: onboardingService.onboardingData[onboardingService.currentStep].imageName)
                            .font(.system(size: 100))
                            .foregroundColor(onboardingService.onboardingData[onboardingService.currentStep].color)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .rotationEffect(.degrees(isAnimating ? 5 : 0))
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                            .onAppear {
                                isAnimating = true
                            }

                        VStack(spacing: 20) {
                            Text(onboardingService.onboardingData[onboardingService.currentStep].title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)

                            Text(onboardingService.onboardingData[onboardingService.currentStep].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 40)
                        }

                        HStack(spacing: 10) {
                            ForEach(0..<onboardingService.totalSteps, id: \.self) { index in
                                Capsule()
                                    .fill(
                                        index == onboardingService.currentStep
                                            ? onboardingService.onboardingData[onboardingService.currentStep].color
                                            : Color.gray.opacity(0.3)
                                    )
                                    .frame(
                                        width: index == onboardingService.currentStep ? 40 : 10,
                                        height: 10
                                    )
                                    .animation(.spring(), value: onboardingService.currentStep)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxHeight: .infinity)

                    VStack(spacing: 15) {
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)

                                Capsule()
                                    .fill(onboardingService.onboardingData[onboardingService.currentStep].color)
                                    .frame(
                                        width: proxy.size.width * onboardingService.getProgress(),
                                        height: 4
                                    )
                                    .animation(.easeInOut, value: onboardingService.currentStep)
                            }
                        }
                        .frame(height: 4)
                        .padding(.horizontal, 40)

                        HStack {
                            if onboardingService.currentStep > 0 {
                                Button {
                                    onboardingService.previousStep()
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                }
                            }

                            Button {
                                onboardingService.nextStep()
                            } label: {
                                HStack {
                                    Text(onboardingService.currentStep == onboardingService.totalSteps - 1
                                        ? "Get Started" : "Next")
                                    Image(systemName: onboardingService.currentStep == onboardingService.totalSteps - 1
                                        ? "checkmark" : "chevron.right")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(onboardingService.onboardingData[onboardingService.currentStep].color)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
