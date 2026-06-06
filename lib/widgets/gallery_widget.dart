// widgets/gallery_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/generic_selection.dart';
import '../providers/current_state_provider.dart';
import '../providers/custom_theme_provider.dart';
import 'generic_selection_widget.dart';

class SelectionGridGallery extends StatelessWidget {
  final List<GenericSelection> items;
  final int? columns;
  final double spacing;
  final double runSpacing;
  final Alignment? textAlignment;
  final LinearGradient? imageOverlayGradient;
  final LinearGradient? textOverlayGradient;
  final double? cardAspectRatio;

  final double? fixedCardHeight;
  final double? maxCardHeight;
  final double? minCardHeight;

  final BorderRadius borderRadius;

  const SelectionGridGallery({
    super.key,
    required this.items,
    this.columns,
    this.spacing = 12.0,
    this.runSpacing = 12.0,
    this.textAlignment,
    this.imageOverlayGradient,
    this.textOverlayGradient,
    this.cardAspectRatio = 1.33,
    this.fixedCardHeight,
    this.maxCardHeight,
    this.minCardHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final myTheme = Provider.of<CustomThemes>(context, listen: true).getActiveTheme();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = (columns ?? _calculateOptimalColumns(items.length)).clamp(1, items.length);

        final totalHorizontalSpacing = spacing * (cols - 1);
        final availableWidth = constraints.maxWidth - totalHorizontalSpacing;
        final cardWidth = availableWidth / cols;

        final calculatedCardHeight = cardWidth / (cardAspectRatio ?? 1.33);

        double cardHeight = fixedCardHeight ?? calculatedCardHeight;

        if (minCardHeight != null && cardHeight < minCardHeight!) {
          cardHeight = minCardHeight!;
        }

        if (maxCardHeight != null && cardHeight > maxCardHeight!) {
          cardHeight = maxCardHeight!;
        }

        return Center(
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            alignment: WrapAlignment.center,
            children: items.map((item) {
              return SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Selector<CurrentStateProvider, int>(
                  selector: (context, provider) => provider.getCurrentState(item.id.toString()),
                  builder: (context, currStateValue, child) {
                    return GenericSelectionWidget(
                      id: item.id,
                      title: item.title,
                      iconSize: item.iconSize,
                      isMomentary: item.isMomentary,
                      onStateCallBack: () {},
                      offStateCallBack: () {},
                      height: cardHeight,
                      width: cardWidth,
                      states: item.states,
                      textStyle: myTheme.textTheme?.labelMedium,
                      backgroundImage: item.backgroundImage,
                      textAlignment: textAlignment ?? Alignment.bottomCenter,
                      imageOverlayGradient: imageOverlayGradient,
                      textOverlayGradient: textOverlayGradient,
                      borderRadius: borderRadius,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  int _calculateOptimalColumns(int itemCount) {
    if (itemCount <= 3) return itemCount;
    if (itemCount <= 6) return 3;
    if (itemCount <= 8) return 4;
    return 6;
  }
}