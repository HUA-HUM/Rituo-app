//
//  OnboardingService.swift
//  app
//

import Combine
import SwiftUI

private enum OnboardingKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}

class OnboardingService: ObservableObject {
    @Published var shouldShowOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(!shouldShowOnboarding, forKey: OnboardingKeys.hasCompletedOnboarding)
        }
    }

    @Published var currentStep: Int = 0

    let totalSteps = 4
    let onboardingData: [OnboardingStep]

    init() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: OnboardingKeys.hasCompletedOnboarding)
        self.shouldShowOnboarding = !hasCompletedOnboarding

        self.onboardingData = [
            OnboardingStep(
                id: 0,
                title: "Welcome to Rituo",
                description: "Your hub for NFC tags, quick scans, and calm focus when you need it.",
                imageName: "hand.wave.fill",
                color: .blue
            ),
            OnboardingStep(
                id: 1,
                title: "Read and write tags",
                description: "Use the Read tab to scan tag data and Write to save your profile to a tag.",
                imageName: "sensor.tag.radiowaves.forward.fill",
                color: .green
            ),
            OnboardingStep(
                id: 2,
                title: "Focus with app blocking",
                description: "Shield distracting apps during deep work—manage blocked apps from Home when you are ready.",
                imageName: "hand.raised.fill",
                color: .orange
            ),
            OnboardingStep(
                id: 3,
                title: "You are all set",
                description: "Jump into your dashboard and start using NFC on your terms.",
                imageName: "checkmark.circle.fill",
                color: .purple
            ),
        ]
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.spring()) {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }

    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring()) {
                currentStep -= 1
            }
        }
    }

    func skipOnboarding() {
        completeOnboarding()
    }

    func completeOnboarding() {
        withAnimation(.easeInOut) {
            shouldShowOnboarding = false
        }
    }

    func getProgress() -> CGFloat {
        CGFloat(currentStep + 1) / CGFloat(totalSteps)
    }
}

struct OnboardingStep {
    let id: Int
    let title: String
    let description: String
    let imageName: String
    let color: Color
}
