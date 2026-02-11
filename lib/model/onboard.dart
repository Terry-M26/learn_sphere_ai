// OnBoard model - represents a single onboarding page
// Used in OnboardingScreen to display intro slides to new users

class OnBoard {
  final String title; // Main heading text for the page
  final String subtitle; // Description text below the title
  final String lottie; // Lottie animation filename (without path/extension)

  // Constructor - all fields required for each onboarding page
  // Example: OnBoard(title: 'Welcome', subtitle: 'Get started...', lottie: 'animation_1')
  OnBoard({required this.title, required this.subtitle, required this.lottie});
}
