import 'dart:math';

import 'package:arb_translator/src/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Облегчённая ячейка таблицы, которая показывает TextField только при фокусе.
/// Когда ячейка не в фокусе - показывает простой Text для экономии ресурсов.
class TranslationCell extends StatefulWidget {
  const TranslationCell({
    required this.width,
    required this.text,
    super.key,
    this.editable = false,
    this.multiline = false,
    this.centerVertically = false,
    this.background = Colors.transparent,
    this.isEditing = false,
    this.onCommit,
    this.onSecondaryTapDown,
    this.onTap,
    this.onStartEditing,
    this.onStopEditing,
    this.horizontalScrollController,
  });

  final double width;
  final String text;
  final bool editable;
  final bool multiline;
  final bool centerVertically;
  final Color background;
  /// Показывать ли TextField (true) или Text (false)
  final bool isEditing;
  final void Function(String value)? onCommit;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final VoidCallback? onTap;
  /// Колбек когда пользователь кликает для начала редактирования
  final VoidCallback? onStartEditing;
  /// Колбек когда редактирование заканчивается
  final VoidCallback? onStopEditing;
  final ScrollController? horizontalScrollController;

  @override
  State<TranslationCell> createState() => _TranslationCellState();
}

class _TranslationCellState extends State<TranslationCell> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  late String _initial;

  @override
  void initState() {
    super.initState();
    _initial = widget.text;
    if (widget.isEditing) {
      _createEditingState();
    }
  }

  void _createEditingState() {
    _controller ??= TextEditingController(text: widget.text);
    _focusNode ??= FocusNode()..addListener(_onFocusChange);
  }

  void _disposeEditingState() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    _focusNode = null;
    _controller?.dispose();
    _controller = null;
  }

  void _onFocusChange() {
    if (_focusNode != null && !_focusNode!.hasFocus) {
      _maybeCommit();
      widget.onStopEditing?.call();
    }
  }

  @override
  void didUpdateWidget(covariant TranslationCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Переключение режима редактирования
    if (widget.isEditing && !oldWidget.isEditing) {
      _createEditingState();
      _controller!.text = widget.text;
      _initial = widget.text;
      // Автофокус при начале редактирования
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode?.requestFocus();
        _scrollIntoView();
      });
    } else if (!widget.isEditing && oldWidget.isEditing) {
      _maybeCommit();
      _disposeEditingState();
    }
    
    // Обновление текста если изменился снаружи
    if (widget.isEditing && _controller != null) {
      if (oldWidget.text != widget.text && widget.text != _controller!.text) {
        final sel = _controller!.selection;
        _controller!.text = widget.text;
        if (sel.start <= widget.text.length) _controller!.selection = sel;
        _initial = widget.text;
      }
    } else {
      _initial = widget.text;
    }
  }

  @override
  void dispose() {
    _disposeEditingState();
    super.dispose();
  }

  void _maybeCommit() {
    if (_controller == null) return;
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

  void _handleTap() {
    widget.onTap?.call();
    if (widget.editable && !widget.isEditing) {
      widget.onStartEditing?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    
    if (widget.isEditing && _controller != null) {
      // Режим редактирования - показываем TextField
      child = TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: widget.multiline ? null : 1,
        minLines: widget.multiline ? null : 1,
        expands: widget.multiline,
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
        onSubmitted: (_) {
          _maybeCommit();
          widget.onStopEditing?.call();
        },
        onEditingComplete: () {
          _maybeCommit();
          widget.onStopEditing?.call();
        },
        onChanged: (_) => _maybeCommit(),
        contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
      );
    } else {
      // Режим просмотра - показываем лёгкий Text
      child = Padding(
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
    }

    return GestureDetector(
      onTap: _handleTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      child: Container(
        width: widget.width,
        height: double.infinity,
        color: widget.background,
        child: child,
      ),
    );
  }
}
