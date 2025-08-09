import 'dart:math';

import 'package:arb_translator/src/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class TranslationCell extends StatefulWidget {
  const TranslationCell({
    required this.width,
    required this.text,
    super.key,
    this.editable = false,
    this.multiline = false,
    this.centerVertically = false,
    this.background = Colors.transparent,
    this.onCommit,
    this.onSecondaryTapDown,
    this.onTap,
    this.horizontalScrollController,
  });

  final double width;
  final String text;
  final bool editable;
  final bool multiline;
  final bool centerVertically;
  final Color background;
  final void Function(String value)? onCommit;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final VoidCallback? onTap;
  final ScrollController? horizontalScrollController;

  @override
  State<TranslationCell> createState() => _TranslationCellState();
}

class _TranslationCellState extends State<TranslationCell> {
  TextEditingController? _controller;
  late String _initial;
  bool get _isEditing => widget.editable;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _controller = TextEditingController(text: widget.text);
    }
    _initial = widget.text;
  }

  @override
  void didUpdateWidget(covariant TranslationCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isEditing && oldWidget.text != widget.text && widget.text != _controller!.text) {
      final sel = _controller!.selection;
      _controller!.text = widget.text;
      if (sel.start <= widget.text.length) _controller!.selection = sel;
      _initial = widget.text;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _maybeCommit() {
    if (!_isEditing) return;
    final v = _controller!.text;
    if (v != _initial) {
      widget.onCommit?.call(v);
      _initial = v;
    }
  }

  void _scrollIntoView() {
    final ctrl = widget.horizontalScrollController;
    if (ctrl == null || !ctrl.hasClients) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final global = box.localToGlobal(Offset.zero);
    final width = box.size.width;
    final screenWidth = MediaQuery.of(context).size.width;
    final left = global.dx;
    final right = left + width;
    double target = ctrl.offset;
    if (right > screenWidth) {
      target += (right - screenWidth) + 32;
    } else if (left < 0) {
      target = max(0, ctrl.offset + left - 32);
    }
    if (target != ctrl.offset) {
      ctrl.animateTo(target, duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _isEditing
        ? TextField(
            controller: _controller,
            maxLines: widget.multiline ? null : 1,
            minLines: widget.multiline ? null : 1,
            expands: widget.multiline, // Expand TextField to fill available height
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.all(8),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            style: AppTextStyles.tableCell13,
            onSubmitted: (_) => _maybeCommit(),
            onEditingComplete: _maybeCommit,
            onChanged: (_) => _maybeCommit(), // Commit immediately on each change
            onTap: _scrollIntoView,
            // Disable default context menu
            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
          )
        : Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: widget.centerVertically ? Alignment.centerLeft : Alignment.topLeft,
              child: Text(
                widget.text,
                maxLines: widget.multiline ? null : 2,
                overflow: widget.multiline ? TextOverflow.visible : TextOverflow.ellipsis,
                style: AppTextStyles.tableCell13,
              ),
            ),
          );

    return GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: Container(
        width: widget.width,
        height: double.infinity, // Stretch cell to full height
        color: widget.background,
        child: child,
      ),
    );
  }
}
