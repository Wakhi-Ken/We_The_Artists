// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../utils/avatar_gradients.dart';
import '../widgets/animated_gradient_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String location;
  final String? bio;
  final String avatarInitials;
  final VoidCallback? onEditProfile;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.role,
    required this.location,
    required this.avatarInitials,
    this.bio,
    this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AvatarGradients.getGradientForUser(avatarInitials);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedGradientAvatar(
                initials: avatarInitials,
                size: 80,
                gradientColors: colors,
              ),
              const Spacer(),
              if (onEditProfile != null)
                OutlinedButton(
                  onPressed: onEditProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$role · ${location.isNotEmpty ? location : 'Unknown location'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Text(
            bio?.isNotEmpty == true ? bio! : 'No bio available',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
