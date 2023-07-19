library sliver_list_watcher;

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SliverListWatcher extends StatefulWidget {
  final VoidCallback onScrollEnd;
  final VoidCallback? onInit;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isLoading;
  final int? itemCount;
  final List<Widget> topWidgets;
  final Widget? loadingWidget;
  final Future<void> Function()? onRefresh;
  ScrollController? scrollController;
  double refreshDisplacement;
  Color? refreshIndicatorColor;
  Color? refreshIndicatorBackgroundColor;

  SliverListWatcher({
    Key? key,
    this.itemCount,
    this.scrollController,
    required this.onScrollEnd,
    this.topWidgets = const [],
    this.loadingWidget,
    this.onRefresh,
    this.refreshDisplacement = 10,
    this.refreshIndicatorBackgroundColor,
    this.refreshIndicatorColor,
    required this.itemBuilder,
    this.isLoading = false,
    this.onInit,
  }) : super(key: key);

  @override
  _SliverListWatcherState createState() => _SliverListWatcherState();
}

class _SliverListWatcherState extends State<SliverListWatcher>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.scrollController ??= ScrollController();
      widget.onInit?.call();
      widget.scrollController!.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    widget.scrollController!.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController!.position.pixels ==
        widget.scrollController!.position.maxScrollExtent) {
      if (!widget.isLoading) {
        widget.onScrollEnd();
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build to preserve state
    final topWidgetsColumn = Column(
      children: widget.topWidgets,
    );

    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh ?? () => Future.delayed(Duration.zero),
      notificationPredicate: (notification) => widget.onRefresh != null,
      color: widget.refreshIndicatorColor,
      backgroundColor: widget.refreshIndicatorBackgroundColor,
      displacement: widget.refreshDisplacement,
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            key: const ValueKey('topWidgets'),
            child: topWidgetsColumn,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              widget.itemBuilder,
              childCount: widget.itemCount ?? 0,
            ),
          ),
          if (widget.isLoading)
            SliverToBoxAdapter(
              key: const ValueKey('loadingWidget'),
              child: _buildDefaultLoading(),
            ),
        ],
      ),
    );
  }

  SizedBox _buildDefaultLoading() {
    return const SizedBox(
      height: 40,
      width: 40,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
