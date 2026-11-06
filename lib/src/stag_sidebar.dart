import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A configurable dark sidebar with expanded and icon-only layouts.
class StagSidebar extends StatefulWidget {
  const StagSidebar({
    super.key,
    required this.sections,
    this.selectedId,
    this.onItemSelected,
    this.logo,
    this.title = 'Stag',
    this.collapseLabel = 'Collapse sidebar',
    this.expandLabel = 'Expand sidebar',
    this.actions = const [],
    this.style = const StagSidebarStyle(),
    this.expandedWidth = 210,
    this.collapsedWidth = 64,
    this.initiallyCollapsed = false,
    this.showCollapseButton = true,
    this.collapseIcon = Icons.first_page,
    this.expandIcon = Icons.last_page,
    this.moreActionsIcon = Icons.more_horiz,
    this.moreActionsLabel = 'More actions',
    this.onCollapsedChanged,
  });

  final List<StagSidebarSection> sections;
  final String? selectedId;
  final ValueChanged<String>? onItemSelected;
  final Widget? logo;
  final String? title;
  final String collapseLabel;
  final String expandLabel;
  final List<StagSidebarAction> actions;
  final StagSidebarStyle style;
  final double expandedWidth;
  final double collapsedWidth;
  final bool initiallyCollapsed;
  final bool showCollapseButton;
  final IconData collapseIcon;
  final IconData expandIcon;
  final IconData moreActionsIcon;
  final String moreActionsLabel;
  final ValueChanged<bool>? onCollapsedChanged;

  @override
  State<StagSidebar> createState() => _StagSidebarState();
}

class _StagSidebarState extends State<StagSidebar> {
  late bool _collapsed = widget.initiallyCollapsed;
  final Map<String, bool> _expandedMenus = {};

  void _toggleCollapsed() {
    setState(() => _collapsed = !_collapsed);
    widget.onCollapsedChanged?.call(_collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    final outerPadding = style.padding.resolve(Directionality.of(context));

    final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : style.animationDuration;
    final compactPadding = EdgeInsets.only(
      left: style.collapsedHorizontalPadding,
      top: outerPadding.top,
      right: style.collapsedHorizontalPadding,
      bottom: outerPadding.bottom,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _collapsed ? 0 : 1),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, progress, child) => Container(
        width: widget.collapsedWidth +
            (widget.expandedWidth - widget.collapsedWidth) * progress,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          border:
              Border.all(color: style.borderColor, width: style.borderWidth),
          borderRadius: BorderRadius.circular(style.borderRadius),
          boxShadow: style.shadows,
        ),
        padding: EdgeInsets.lerp(compactPadding, outerPadding, progress),
        child: LayoutBuilder(builder: (context, constraints) {
          final navigation = Column(mainAxisSize: MainAxisSize.min, children: [
            for (final section in widget.sections)
              _buildSection(section, style, progress, duration),
          ]);
          final footer = Column(mainAxisSize: MainAxisSize.min, children: [
            if (widget.actions.isNotEmpty) ...[
              SizedBox(height: style.footerSpacing),
              _buildActions(style, progress > .9 && !_collapsed),
            ],
            if (widget.showCollapseButton) ...[
              SizedBox(height: style.footerSpacing),
              _buildCollapseButton(style, progress),
            ],
          ]);
          final header = _buildHeader(style, progress);
          if (!constraints.hasBoundedHeight || constraints.maxHeight < 160) {
            return SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              header,
              SizedBox(height: style.headerSpacing),
              navigation,
              footer,
            ]));
          }
          return Column(children: [
            header,
            SizedBox(height: style.headerSpacing),
            Expanded(child: SingleChildScrollView(child: navigation)),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: constraints.maxHeight * .45),
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [footer]),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _buildHeader(StagSidebarStyle style, double progress) {
    return _animatedRow(
      progress: progress,
      iconWidth: 36,
      icon: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: widget.logo ??
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: style.actionColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: style.borderColor),
                ),
                child: Icon(
                  Icons.bolt,
                  color: style.accentColor,
                  size: style.iconSize,
                ),
              ),
        ),
      ),
      label: widget.title == null
          ? const SizedBox.shrink()
          : Text(
              widget.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.titleStyle ??
                  Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: style.selectedTextColor,
                        fontWeight: FontWeight.w700,
                      ),
            ),
    );
  }

  Widget _buildSection(StagSidebarSection section, StagSidebarStyle style,
      double progress, Duration duration) {
    return Padding(
      padding: EdgeInsets.only(bottom: style.sectionSpacing),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: section.backgroundColor,
          borderRadius: BorderRadius.circular(style.groupBorderRadius),
        ),
        child: Padding(
          padding: section.padding ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < section.items.length; index++) ...[
                if (index > 0) SizedBox(height: style.itemSpacing),
                _buildEntry(section.items[index], style, progress, duration),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(StagSidebarItem item, StagSidebarStyle style,
      double progress, Duration duration) {
    if (item.children.isEmpty) {
      return _buildItem(item, style, progress, duration);
    }
    final expanded = _expandedMenus[item.id] ?? item.initiallyExpanded;
    void toggle() {
      setState(() => _expandedMenus[item.id] = !expanded);
      item.onTap?.call();
    }

    final children = IgnorePointer(
      ignoring: !expanded,
      child: ExcludeSemantics(
        excluding: !expanded,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final child in item.children) ...[
            SizedBox(height: style.itemSpacing),
            _buildEntry(child, style, progress, duration),
          ],
        ]),
      ),
    );

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      padding: EdgeInsets.all(expanded ? style.submenuPadding : 0),
      decoration: BoxDecoration(
        color: expanded
            ? item.submenuBackgroundColor ?? style.submenuBackgroundColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(style.groupBorderRadius),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildItem(item, style, progress, duration,
            onActivate: toggle, expanded: expanded),
        if (duration == Duration.zero)
          if (expanded) children else const SizedBox.shrink()
        else
          ClipRect(
            child: AnimatedCrossFade(
              duration: duration,
              sizeCurve: Curves.easeInOutCubic,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: children,
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ),
      ]),
    );
  }

  Widget _buildItem(StagSidebarItem item, StagSidebarStyle style,
      double progress, Duration duration,
      {VoidCallback? onActivate, bool? expanded}) {
    final selected = item.id == widget.selectedId;
    final baseLabelStyle = style.labelStyle ??
        Theme.of(context).textTheme.labelMedium ??
        const TextStyle();
    final labelStyle = (selected ? style.selectedLabelStyle : null) ??
        baseLabelStyle.copyWith(
          color: selected ? style.selectedTextColor : style.textColor,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
    final selectedGradient = item.selectedGradient ??
        (item.selectedBackgroundColor != null ||
                style.selectedBackgroundColor != null
            ? null
            : style.selectedGradient);
    void activate() {
      if (onActivate != null) {
        onActivate();
        return;
      }
      widget.onItemSelected?.call(item.id);
      item.onTap?.call();
    }

    final child = Semantics(
      button: true,
      selected: selected,
      expanded: expanded,
      label: item.label,
      onTap: activate,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color: selected
              ? item.selectedBackgroundColor ?? style.selectedBackgroundColor
              : null,
          gradient: selected ? selectedGradient : null,
          borderRadius: BorderRadius.circular(style.itemBorderRadius),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: activate,
            borderRadius: BorderRadius.circular(style.itemBorderRadius),
            hoverColor: style.hoverColor,
            child: SizedBox(
              height: style.itemHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: style.itemPadding * progress,
                ),
                child: _animatedRow(
                  progress: progress,
                  iconWidth: style.iconSize + 12,
                  icon: AnimatedContainer(
                    duration: duration,
                    width: style.iconSize + 12,
                    height: style.iconSize + 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? style.selectedIconBackgroundColor
                          : Colors.transparent,
                    ),
                    child: Icon(item.icon,
                        size: style.iconSize,
                        color: selected
                            ? style.selectedTextColor
                            : style.iconColor),
                  ),
                  label: LayoutBuilder(
                      builder: (context, constraints) => Row(children: [
                            Expanded(
                                child: Text(item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: labelStyle)),
                            if (expanded != null && constraints.maxWidth > 40)
                              AnimatedRotation(
                                  turns: expanded ? .5 : 0,
                                  duration: duration,
                                  curve: Curves.easeInOutCubic,
                                  child: Icon(Icons.expand_more,
                                      size: style.iconSize,
                                      color: style.iconColor)),
                          ])),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return _collapsed ? Tooltip(message: item.label, child: child) : child;
  }

  Widget _buildActions(StagSidebarStyle style, bool expanded) {
    if (!expanded) {
      if (!_collapsed) {
        return SizedBox(width: style.actionSize, height: style.actionSize);
      }
      return _CompactActions(
        actions: widget.actions,
        style: style,
        icon: widget.moreActionsIcon,
        label: widget.moreActionsLabel,
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: style.actionSpacing,
      runSpacing: style.actionSpacing,
      children: [
        for (final action in widget.actions)
          IconButton(
            onPressed: action.onPressed,
            tooltip: action.label,
            constraints: BoxConstraints.tightFor(
              width: style.actionSize,
              height: style.actionSize,
            ),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: action.backgroundColor ?? style.actionColor,
              foregroundColor: action.iconColor ?? style.actionIconColor,
              shape: CircleBorder(side: BorderSide(color: style.borderColor)),
            ),
            icon: Icon(action.icon, size: style.actionIconSize),
          ),
      ],
    );
  }

  Widget _buildCollapseButton(StagSidebarStyle style, double progress) {
    return Semantics(
      button: true,
      label: _collapsed ? widget.expandLabel : widget.collapseLabel,
      onTap: _toggleCollapsed,
      excludeSemantics: true,
      child: Tooltip(
          message: _collapsed ? widget.expandLabel : widget.collapseLabel,
          child: InkWell(
            onTap: _toggleCollapsed,
            borderRadius: BorderRadius.circular(style.itemBorderRadius),
            hoverColor: style.hoverColor,
            child: SizedBox(
              height: style.itemHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: style.itemPadding * progress),
                child: _animatedRow(
                  progress: progress,
                  iconWidth: style.iconSize,
                  icon: Icon(
                    _collapsed ? widget.expandIcon : widget.collapseIcon,
                    size: style.iconSize,
                    color: style.accentColor,
                  ),
                  label: Text(
                    widget.collapseLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (style.labelStyle ??
                            Theme.of(context).textTheme.labelMedium ??
                            const TextStyle())
                        .copyWith(color: style.textColor),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _animatedRow(
      {required double progress,
      required double iconWidth,
      required Widget icon,
      required Widget label}) {
    return LayoutBuilder(builder: (context, constraints) {
      final space =
          (constraints.maxWidth - iconWidth).clamp(0.0, double.infinity);
      final leading = space * (1 - progress) / 2;
      final gap = (10 * progress).clamp(0.0, space - leading);
      return Row(children: [
        SizedBox(width: leading),
        icon,
        SizedBox(width: gap),
        Expanded(
            child: ExcludeSemantics(
                excluding: _collapsed,
                child: Opacity(opacity: progress, child: label))),
      ]);
    });
  }
}

class _CompactActions extends StatefulWidget {
  const _CompactActions(
      {required this.actions,
      required this.style,
      required this.icon,
      required this.label});

  final List<StagSidebarAction> actions;
  final StagSidebarStyle style;
  final IconData icon;
  final String label;

  @override
  State<_CompactActions> createState() => _CompactActionsState();
}

class _CompactActionsState extends State<_CompactActions>
    with WidgetsBindingObserver {
  final _portal = OverlayPortalController();
  final _anchorKey = GlobalKey();
  final _tapGroup = Object();
  Timer? _closeTimer;
  ScrollPosition? _scrollPosition;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
      _scrollPosition = position;
      _scrollPosition?.isScrollingNotifier.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollPosition?.isScrollingNotifier.value == true) _hide();
  }

  @override
  void didChangeMetrics() => _hide();

  void _show() {
    _closeTimer?.cancel();
    if (!_portal.isShowing) _portal.show();
  }

  void _hide() {
    _closeTimer?.cancel();
    _pinned = false;
    if (_portal.isShowing) _portal.hide();
  }

  void _scheduleHide() {
    _closeTimer?.cancel();
    if (!_pinned) _closeTimer = Timer(const Duration(milliseconds: 180), _hide);
  }

  void _toggle() {
    if (_pinned) {
      _hide();
    } else {
      _pinned = true;
      _show();
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _scrollPosition?.isScrollingNotifier.removeListener(_onScroll);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style;
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        final overlayBox =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final anchor =
            _anchorKey.currentContext!.findRenderObject()! as RenderBox;
        final position =
            anchor.localToGlobal(Offset.zero, ancestor: overlayBox);
        final actionSize = math.max(40.0, style.actionSize);
        final desiredWidth = 16 +
            widget.actions.length * actionSize +
            math.max(0, widget.actions.length - 1) * style.actionSpacing;
        final width =
            math.min(desiredWidth, math.max(0.0, overlayBox.size.width - 16));
        final left = position.dx
            .clamp(8.0, math.max(8.0, overlayBox.size.width - width - 8))
            .toDouble();
        final showAbove = position.dy >= actionSize + 20;
        final top = (showAbove
                ? position.dy - actionSize - 20
                : position.dy + anchor.size.height + 8)
            .clamp(8.0, math.max(8.0, overlayBox.size.height - actionSize - 20))
            .toDouble();
        final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
            ? Duration.zero
            : style.animationDuration;

        return Stack(children: [
          Positioned(
              left: left,
              top: top,
              child: TapRegion(
                groupId: _tapGroup,
                onTapOutside: (_) => _hide(),
                child: MouseRegion(
                  onEnter: (_) => _closeTimer?.cancel(),
                  onExit: (_) => _scheduleHide(),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: duration,
                    curve: Curves.easeOut,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                          offset: Offset(0, 4 * (1 - value)), child: child),
                    ),
                    child: Material(
                      color: style.actionMenuColor,
                      elevation: 8,
                      borderRadius:
                          BorderRadius.circular(style.itemBorderRadius),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: width,
                        height: actionSize + 12,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            for (var i = 0; i < widget.actions.length; i++) ...[
                              if (i > 0) SizedBox(width: style.actionSpacing),
                              SizedBox(
                                width: actionSize,
                                height: actionSize,
                                child: IconButton(
                                  tooltip: widget.actions[i].label,
                                  onPressed: () {
                                    final action = widget.actions[i];
                                    _hide();
                                    action.onPressed();
                                  },
                                  constraints: BoxConstraints.tightFor(
                                      width: actionSize, height: actionSize),
                                  padding: EdgeInsets.zero,
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        widget.actions[i].backgroundColor ??
                                            style.actionColor,
                                    foregroundColor:
                                        widget.actions[i].iconColor ??
                                            style.actionIconColor,
                                  ),
                                  icon: Icon(widget.actions[i].icon,
                                      size: style.actionIconSize),
                                ),
                              ),
                            ],
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ]);
      },
      child: SizedBox(
        key: _anchorKey,
        width: style.actionSize,
        height: style.actionSize,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _hide(),
          child: MouseRegion(
            onEnter: (_) => _show(),
            onExit: (_) => _scheduleHide(),
            child: IconButton(
              tooltip: widget.label,
              onPressed: _toggle,
              constraints: BoxConstraints.tightFor(
                  width: style.actionSize, height: style.actionSize),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: style.actionColor,
                foregroundColor: style.actionIconColor,
                shape: CircleBorder(
                    side: BorderSide(
                        color: style.borderColor, width: style.borderWidth)),
              ),
              icon: Icon(widget.icon, size: style.actionIconSize),
            ),
          ),
        ),
      ),
    );
  }
}

/// A group of navigation items.
class StagSidebarSection {
  const StagSidebarSection({
    required this.items,
    this.backgroundColor,
    this.padding,
  });

  final List<StagSidebarItem> items;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
}

/// A selectable navigation item.
class StagSidebarItem {
  const StagSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.onTap,
    this.selectedBackgroundColor,
    this.selectedGradient,
    this.children = const [],
    this.initiallyExpanded = false,
    this.submenuBackgroundColor,
  });

  final String id;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? selectedBackgroundColor;
  final Gradient? selectedGradient;
  final List<StagSidebarItem> children;
  final bool initiallyExpanded;
  final Color? submenuBackgroundColor;
}

/// A circular action shown at the bottom of the sidebar.
class StagSidebarAction {
  const StagSidebarAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
}

/// Colors, sizes, and spacing used by [StagSidebar].
class StagSidebarStyle {
  const StagSidebarStyle({
    this.backgroundColor = const Color(0xFF111322),
    this.textColor = const Color(0xFF92A2B0),
    this.iconColor = const Color(0xFF8194A2),
    this.selectedTextColor = Colors.white,
    this.selectedIconBackgroundColor = const Color(0x33FFFFFF),
    this.submenuBackgroundColor = const Color(0xFF1B2C39),
    this.submenuPadding = 6,
    this.accentColor = const Color(0xFF52C9D7),
    this.selectedBackgroundColor,
    this.selectedGradient = const LinearGradient(
      colors: [Color(0xFF43C893), Color(0xFF31BDE4)],
    ),
    this.actionColor = const Color(0xFF151A2A),
    this.actionIconColor = const Color(0xFF52C9D7),
    this.actionMenuColor = const Color(0xFF1B2C39),
    this.hoverColor = const Color(0x332C9EAD),
    this.borderColor = const Color(0x442B4654),
    this.borderWidth = 1,
    this.shadows = const [
      BoxShadow(color: Color(0x440C2531), blurRadius: 24, offset: Offset(0, 12))
    ],
    this.padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
    this.collapsedHorizontalPadding = 8,
    this.labelStyle,
    this.selectedLabelStyle,
    this.titleStyle,
    this.borderRadius = 18,
    this.groupBorderRadius = 15,
    this.itemBorderRadius = 14,
    this.iconSize = 18,
    this.itemHeight = 40,
    this.itemPadding = 8,
    this.headerSpacing = 18,
    this.sectionSpacing = 14,
    this.itemSpacing = 3,
    this.actionSize = 32,
    this.actionIconSize = 16,
    this.actionSpacing = 6,
    this.footerSpacing = 8,
    this.animationDuration = const Duration(milliseconds: 180),
  });

  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color selectedTextColor;
  final Color selectedIconBackgroundColor;
  final Color submenuBackgroundColor;
  final double submenuPadding;
  final Color accentColor;
  final Color? selectedBackgroundColor;
  final Gradient? selectedGradient;
  final Color actionColor;
  final Color actionIconColor;
  final Color actionMenuColor;
  final Color hoverColor;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;
  final EdgeInsetsGeometry padding;
  final double collapsedHorizontalPadding;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;
  final TextStyle? titleStyle;
  final double borderRadius;
  final double groupBorderRadius;
  final double itemBorderRadius;
  final double iconSize;
  final double itemHeight;
  final double itemPadding;
  final double headerSpacing;
  final double sectionSpacing;
  final double itemSpacing;
  final double actionSize;
  final double actionIconSize;
  final double actionSpacing;
  final double footerSpacing;
  final Duration animationDuration;
}
