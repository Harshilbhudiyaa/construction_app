import 'package:flutter/material.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/core/theme/professional_theme.dart';
import 'package:construction_app/shared/widgets/staggered_animation.dart';

class ProfessionalPage extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final String? category;
  final List<Widget>? actions;
  final List<Widget>? slivers;
  final List<Widget>? children;
  final List<Widget>? headerStats;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool animateEntry;
  final bool isTactile;
  final bool isBlueprint;

  const ProfessionalPage({
    super.key,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.category = 'SmartConstruction ERP',
    this.actions,
    this.slivers,
    this.children,
    this.headerStats,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.animateEntry = true,
    this.isTactile = false,
    this.isBlueprint = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SmartConstructionSliverAppBar(
            title: title,
            titleWidget: titleWidget,
            subtitle: subtitle ?? '',
            category: category ?? 'SmartConstruction ERP',
            actions: actions,
            headerStats: headerStats,
            bottom: bottom,
          ),
          if (slivers != null) ...slivers!,
          if (children != null)
            SliverList(
              delegate: SliverChildListDelegate(children!),
            ),
        ],
      ),
    );

    if (animateEntry) {
      return ProfessionalBackground(
        isTactile: isTactile,
        isBlueprint: isBlueprint,
        child: StaggeredAnimation(
          child: content,
        ),
      );
    }

    return ProfessionalBackground(
      isTactile: isTactile,
      isBlueprint: isBlueprint,
      child: content,
    );
  }
}
