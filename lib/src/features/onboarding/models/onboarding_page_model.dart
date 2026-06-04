import 'package:equatable/equatable.dart';

class OnboardingPageModel extends Equatable {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingPageModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [image, title, subtitle];
}
