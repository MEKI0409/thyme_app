// services/mood_responsive_garden_service.dart
// Calm Gamification: Garden reflects user's emotional state
// The garden RESPONDS to emotions, it doesn't DEMAND actions

import 'package:flutter/material.dart';

class MoodResponsiveGardenService {
  /// Get garden ambiance based on user's current mood
  /// The garden adapts to support the user, not to reward/punish
  GardenAmbiance getGardenAmbiance(String? currentMood) {
    switch (currentMood?.toLowerCase()) {
      case 'anxious':
        return GardenAmbiance(
          // Soothing blue-green tones
          skyGradient: [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
          groundGradient: [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
          // Slow, gentle wind
          windSpeed: 0.2,
          windIntensity: 0.3,
          // Calming ambient sound
          ambientSound: 'gentle_stream',
          // Show breathing guide for anxious users
          showBreathingGuide: true,
          showFallingPetals: false,
          showButterflies: false,
          showSparkles: false,
          showFireflies: false,
          showWarmLight: false,
          showRaindrops: false,
          message: "Your garden is a calm space. Take a breath here. 🍃",
          supportMessage:
          "It's okay to feel anxious. This space is here to hold you gently.",
        );

      case 'sad':
        return GardenAmbiance(
          // Warm sunset tones - comforting, not cheerful
          skyGradient: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
          groundGradient: [const Color(0xFFBCAAA4), const Color(0xFFA1887F)],
          windSpeed: 0.15,
          windIntensity: 0.2,
          // Soft rain can be comforting
          ambientSound: 'soft_rain',
          showBreathingGuide: false,
          showFallingPetals: false,
          showButterflies: false,
          showSparkles: false,
          showFireflies: false,
          showWarmLight: true, // Warm glowing light
          showRaindrops: true,
          message:
          "It's okay to feel this way. Your garden holds space for all feelings. 💛",
          supportMessage:
          "Sadness is welcome here. You don't have to be okay right now.",
        );

      case 'stressed':
        return GardenAmbiance(
          // Natural green tones - grounding
          skyGradient: [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
          groundGradient: [const Color(0xFF81C784), const Color(0xFF66BB6A)],
          windSpeed: 0.3,
          windIntensity: 0.4,
          ambientSound: 'forest_birds',
          showBreathingGuide: true,
          showFallingPetals: true, // Gentle falling petals - relaxing visual
          showButterflies: false,
          showSparkles: false,
          showFireflies: false,
          showWarmLight: false,
          showRaindrops: false,
          message:
          "Let go of what you can't control. Your garden grows at its own pace. 🌸",
          supportMessage:
          "Stress is your body telling you something. Listen gently.",
        );

      case 'happy':
        return GardenAmbiance(
          // Bright, warm tones
          skyGradient: [const Color(0xFFFFFDE7), const Color(0xFFFFF9C4)],
          groundGradient: [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
          windSpeed: 0.4,
          windIntensity: 0.5,
          ambientSound: 'cheerful_birds',
          showBreathingGuide: false,
          showFallingPetals: false,
          showButterflies: true,
          showSparkles: true,
          showFireflies: false,
          showWarmLight: true,
          showRaindrops: false,
          message: "Your joy makes the garden bloom. ✨",
          supportMessage: "This feeling is worth savoring. Stay here a while.",
        );

      case 'calm':
        return GardenAmbiance(
          // Soft purple evening tones
          skyGradient: [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
          groundGradient: [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
          windSpeed: 0.15,
          windIntensity: 0.2,
          ambientSound: 'evening_crickets',
          showBreathingGuide: false,
          showFallingPetals: false,
          showButterflies: false,
          showSparkles: false,
          showFireflies: true, // Peaceful fireflies
          showWarmLight: true,
          showRaindrops: false,
          message: "A perfect moment of peace. 🌙",
          supportMessage: "Calm is a gift. Enjoy this stillness.",
        );

      case 'neutral':
      default:
        return GardenAmbiance(
          // Default teal tones
          skyGradient: [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
          groundGradient: [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
          windSpeed: 0.25,
          windIntensity: 0.3,
          ambientSound: 'nature_ambient',
          showBreathingGuide: false,
          showFallingPetals: false,
          showButterflies: false,
          showSparkles: false,
          showFireflies: false,
          showWarmLight: false,
          showRaindrops: false,
          message: "Welcome back to your garden. 🌿",
          supportMessage: "This space is here for you, whatever you're feeling.",
        );
    }
  }

  /// Get ambient particles based on mood
  List<AmbientParticle> getAmbientParticles(GardenAmbiance ambiance) {
    final particles = <AmbientParticle>[];

    if (ambiance.showFallingPetals) {
      particles.addAll(_generatePetals(15));
    }
    if (ambiance.showButterflies) {
      particles.addAll(_generateButterflies(5));
    }
    if (ambiance.showSparkles) {
      particles.addAll(_generateSparkles(20));
    }
    if (ambiance.showFireflies) {
      particles.addAll(_generateFireflies(12));
    }
    if (ambiance.showRaindrops) {
      particles.addAll(_generateRaindrops(30));
    }

    return particles;
  }

  List<AmbientParticle> _generatePetals(int count) {
    return List.generate(count, (i) {
      return AmbientParticle(
        type: ParticleType.petal,
        color: [
          const Color(0xFFFFCDD2),
          const Color(0xFFF8BBD9),
          const Color(0xFFE1BEE7),
        ][i % 3],
        size: 8.0 + (i % 5) * 2,
        speed: 0.3 + (i % 3) * 0.1,
        swayAmount: 20.0,
      );
    });
  }

  List<AmbientParticle> _generateButterflies(int count) {
    return List.generate(count, (i) {
      return AmbientParticle(
        type: ParticleType.butterfly,
        color: [
          const Color(0xFFFFEB3B),
          const Color(0xFF4FC3F7),
          const Color(0xFFFF8A65),
        ][i % 3],
        size: 15.0 + (i % 3) * 5,
        speed: 0.5 + (i % 2) * 0.2,
        swayAmount: 40.0,
      );
    });
  }

  List<AmbientParticle> _generateSparkles(int count) {
    return List.generate(count, (i) {
      return AmbientParticle(
        type: ParticleType.sparkle,
        color: const Color(0xFFFFD54F),
        size: 4.0 + (i % 4) * 1.5,
        speed: 0.1,
        swayAmount: 5.0,
      );
    });
  }

  List<AmbientParticle> _generateFireflies(int count) {
    return List.generate(count, (i) {
      return AmbientParticle(
        type: ParticleType.firefly,
        color: const Color(0xFFFFEB3B),
        size: 6.0 + (i % 3) * 2,
        speed: 0.2 + (i % 2) * 0.1,
        swayAmount: 30.0,
      );
    });
  }

  List<AmbientParticle> _generateRaindrops(int count) {
    return List.generate(count, (i) {
      return AmbientParticle(
        type: ParticleType.raindrop,
        color: const Color(0xFF90CAF9).withOpacity(0.6),
        size: 2.0 + (i % 3),
        speed: 1.5 + (i % 3) * 0.5,
        swayAmount: 2.0,
      );
    });
  }
}

/// Garden ambiance configuration
class GardenAmbiance {
  final List<Color> skyGradient;
  final List<Color> groundGradient;
  final double windSpeed;
  final double windIntensity;
  final String? ambientSound;
  final bool showBreathingGuide;
  final bool showFallingPetals;
  final bool showButterflies;
  final bool showSparkles;
  final bool showFireflies;
  final bool showWarmLight;
  final bool showRaindrops;
  final String message;
  final String supportMessage;

  GardenAmbiance({
    required this.skyGradient,
    required this.groundGradient,
    this.windSpeed = 0.3,
    this.windIntensity = 0.3,
    this.ambientSound,
    this.showBreathingGuide = false,
    this.showFallingPetals = false,
    this.showButterflies = false,
    this.showSparkles = false,
    this.showFireflies = false,
    this.showWarmLight = false,
    this.showRaindrops = false,
    required this.message,
    required this.supportMessage,
  });
}

/// Ambient particle for garden decorations
class AmbientParticle {
  final ParticleType type;
  final Color color;
  final double size;
  final double speed;
  final double swayAmount;

  AmbientParticle({
    required this.type,
    required this.color,
    required this.size,
    required this.speed,
    required this.swayAmount,
  });
}

enum ParticleType {
  petal,
  butterfly,
  sparkle,
  firefly,
  raindrop,
}