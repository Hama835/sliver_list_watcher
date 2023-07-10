library sliver_list_watcher;

import 'package:flutter/material.dart';

class SliverListWatcher extends StatefulWidget {
  final VoidCallback onScrollEnd;
  final VoidCallback? onInit;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;
  final int? itemCount;
  final List<Widget> topWidgets;
  final Widget? loadingWidget;

  const SliverListWatcher({
    Key? key,
    this.itemCount,
    required this.onScrollEnd,
    this.topWidgets = const [],
    this.loadingWidget,
    required this.itemBuilder,
    this.isLoading = false,
    this.onInit,
  }) : super(key: key);

  @override
  _SliverListWatcherState createState() => _SliverListWatcherState();
}

class _SliverListWatcherState extends State<SliverListWatcher>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit?.call();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
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

    return CustomScrollView(
      controller: _scrollController,
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
