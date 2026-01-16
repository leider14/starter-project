import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MywdgAvatarimage extends StatelessWidget {
  final String urlImage;
  final VoidCallback? onTap;
  const MywdgAvatarimage({super.key, required this.urlImage, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: CachedNetworkImage(
              imageUrl: urlImage,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl:
                    'https://cdn.pixabay.com/photo/2013/07/12/15/07/hat-149479_1280.png',
                fit: BoxFit.cover,
              ),
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ));
  }
}
