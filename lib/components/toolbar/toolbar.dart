import 'dart:io';
import 'package:collapsible/collapsible.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keybinder/keybinder.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/eraser_modal.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/highlighter_modal.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/components/toolbar/size_picker.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({
    super.key,
    required this.readOnly,
    required this.setTool,
    required this.currentTool,
    required this.setColor,
    required this.quillFocus,
    required this.textEditing,
    required this.toggleTextEditing,
    required this.undo,
    required this.isUndoPossible,
    required this.redo,
    required this.isRedoPossible,
    required this.toggleFingerDrawing,
    required this.pickPhoto,
    required this.paste,
    required this.duplicateSelection,
    required this.deleteSelection,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  final bool readOnly;
  final ValueChanged<Tool> setTool;
  final Tool currentTool;
  final ValueChanged<Color> setColor;

  final ValueNotifier<QuillStruct?> quillFocus;
  final bool textEditing;
  final VoidCallback toggleTextEditing;

  final VoidCallback undo;
  final bool isUndoPossible;
  final VoidCallback redo;
  final bool isRedoPossible;

  final VoidCallback toggleFingerDrawing;
  final VoidCallback pickPhoto;
  final VoidCallback paste;
  final VoidCallback duplicateSelection;
  final VoidCallback deleteSelection;

  final Future Function(BuildContext)? exportAsSba;
  final Future Function(BuildContext)? exportAsPdf;
  final Future Function(BuildContext)? exportAsPng;

  @override
  State<Toolbar> createState() => _ToolbarState();

  static const _buttonPaddingHorizontal = EdgeInsets.symmetric(horizontal: 6);
  static const _buttonPaddingVertical = EdgeInsets.symmetric(vertical: 6);
}

class _ToolbarState extends State<Toolbar> {
  ValueNotifier<bool> showExportOptions = ValueNotifier(false);
  ValueNotifier<bool> showColorOptions = ValueNotifier(false);
  ValueNotifier<ToolOptions> toolOptionsType = ValueNotifier(ToolOptions.hide);

  @override
  void initState() {
    _assignKeybindings();
    DynamicMaterialApp.addFullscreenListener(_setState);
    super.initState();
  }

  void _setState() => setState(() {});

  Keybinding? _ctrlF;
  Keybinding? _ctrlE;
  Keybinding? _ctrlC;
  Keybinding? _ctrlShiftS;
  Keybinding? _ctrlV;

  void _assignKeybindings() {
    _ctrlF = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyF),
    ], inclusive: true);
    _ctrlE = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyE),
    ], inclusive: true);
    _ctrlC = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyC),
    ], inclusive: true);
    _ctrlShiftS = Keybinding([
      KeyCode.ctrl,
      KeyCode.shift,
      KeyCode.from(LogicalKeyboardKey.keyS),
    ], inclusive: true);
    _ctrlV = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyV),
    ], inclusive: true);

    Keybinder.bind(_ctrlF!, widget.toggleFingerDrawing);
    Keybinder.bind(_ctrlE!, toggleEraser);
    Keybinder.bind(_ctrlC!, toggleColorOptions);
    Keybinder.bind(_ctrlShiftS!, toggleExportBar);
    Keybinder.bind(_ctrlV!, widget.paste);
  }

  void _removeKeybindings() {
    if (_ctrlF != null) Keybinder.remove(_ctrlF!);
    if (_ctrlE != null) Keybinder.remove(_ctrlE!);
    if (_ctrlC != null) Keybinder.remove(_ctrlC!);
    if (_ctrlShiftS != null) Keybinder.remove(_ctrlShiftS!);
    if (_ctrlV != null) Keybinder.remove(_ctrlV!);
  }

  void toggleEraser() {
    if (widget.currentTool is Eraser) {
      toolOptionsType.value = (toolOptionsType.value == ToolOptions.eraser)
          ? ToolOptions.hide
          : ToolOptions.eraser;
    } else {
      toolOptionsType.value = ToolOptions.hide;
      widget.setTool(Eraser());
    }
  }

  void toggleColorOptions() {
    showColorOptions.value = !showColorOptions.value;
  }

  void toggleExportBar() {
    showExportOptions.value = !showExportOptions.value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == Brightness.dark;

    final isToolbarVertical =
        stows.editorToolbarAlignment.value == AxisDirection.left ||
        stows.editorToolbarAlignment.value == AxisDirection.right;

    final buttonPadding = isToolbarVertical
        ? Toolbar._buttonPaddingVertical
        : Toolbar._buttonPaddingHorizontal;

    final currentColor = switch (widget.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    if (widget.currentTool == Select.currentSelect) {
      toolOptionsType.value = Select.currentSelect.doneSelecting
          ? ToolOptions.select
          : ToolOptions.hide;
    }

    final bars = <Widget>[
      // Export Popover
      ValueListenableBuilder(
        valueListenable: showExportOptions,
        builder: (context, showExportOptions, child) {
          return Collapsible(
            axis: isToolbarVertical
                ? CollapsibleAxis.horizontal
                : CollapsibleAxis.vertical,
            maintainState: true,
            collapsed: !showExportOptions,
            child: child!,
          );
        },
        child: ExportBar(
          axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
          toggleExportBar: toggleExportBar,
          exportAsSba: widget.exportAsSba,
          exportAsPdf: widget.exportAsPdf,
          exportAsPng: widget.exportAsPng,
        ),
      ),
      // Tool Options Popovers
      ValueListenableBuilder(
        valueListenable: toolOptionsType,
        builder: (context, toolOptions, _) {
          return Collapsible(
            axis: isToolbarVertical
                ? CollapsibleAxis.horizontal
                : CollapsibleAxis.vertical,
            maintainState: true,
            collapsed: toolOptions == ToolOptions.hide,
            child: Material(
              color: Colors.transparent,
              child: switch (toolOptions) {
                ToolOptions.hide => const SizedBox.square(dimension: SizePicker.smallLength),
                ToolOptions.pen => PenModal(
                  getTool: () => Pen.currentPen,
                  setTool: widget.setTool,
                ),
                ToolOptions.highlighter => HighlighterModal(
                  getTool: () => Highlighter.currentHighlighter,
                  setTool: (pen) => widget.setTool(pen),
                ),
                ToolOptions.pencil => PenModal(
                  getTool: () => Pencil.currentPencil,
                  setTool: widget.setTool,
                ),
                ToolOptions.select => SelectionBar(
                  duplicateSelection: widget.duplicateSelection,
                  deleteSelection: widget.deleteSelection,
                  pasteSelection: widget.paste,
                ),
                ToolOptions.eraser => EraserModal(
                  eraser: widget.currentTool is Eraser
                      ? widget.currentTool as Eraser
                      : Eraser(),
                  onClearAll: () {
                    toolOptionsType.value = ToolOptions.hide;
                  },
                ),
              },
            ),
          );
        },
      ),
      // Color Options Popover
      ValueListenableBuilder(
        valueListenable: showColorOptions,
        builder: (context, showColorOptions, child) {
          return Collapsible(
            axis: isToolbarVertical
                ? CollapsibleAxis.horizontal
                : CollapsibleAxis.vertical,
            maintainState: true,
            collapsed: !showColorOptions,
            child: child!,
          );
        },
        child: ColorBar(
          axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
          setColor: widget.setColor,
          currentColor: currentColor,
          invert: invert,
        ),
      ),
      // Text Quill Toolbar
      ValueListenableBuilder(
        valueListenable: widget.quillFocus,
        builder: (context, quill, _) {
          final baseButtonStyle =
              IconButtonTheme.of(context).style ?? const ButtonStyle();

          final iconTheme = QuillIconTheme(
            iconButtonUnselectedData: IconButtonData(
              style: baseButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(colorScheme.primary),
              ),
            ),
            iconButtonSelectedData: IconButtonData(
              style: baseButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(colorScheme.primary),
                foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
              ),
            ),
          );
          return Collapsible(
            axis: isToolbarVertical
                ? CollapsibleAxis.horizontal
                : CollapsibleAxis.vertical,
            maintainState: false,
            collapsed: !widget.textEditing || quill == null,
            child: quill != null
                ? QuillSimpleToolbar(
                    controller: quill.controller,
                    config: QuillSimpleToolbarConfig(
                      axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          iconTheme: iconTheme,
                        ),
                      ),
                      multiRowsDisplay: !Platform.isAndroid && !Platform.isIOS,
                      showUndo: false,
                      showRedo: false,
                      showFontSize: false,
                      showFontFamily: false,
                      showClearFormat: false,
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),

      // Main Floating Drawing Bar
      Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            direction: isToolbarVertical ? Axis.vertical : Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              // 1. Group Undo / Redo
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToolbarIconButton(
                      tooltip: t.editor.toolbar.undo,
                      enabled: !widget.readOnly && widget.isUndoPossible,
                      onPressed: widget.undo,
                      padding: buttonPadding,
                      child: const AdaptiveIcon(
                        icon: Icons.undo,
                        cupertinoIcon: CupertinoIcons.arrow_uturn_left,
                      ),
                    ),
                    ToolbarIconButton(
                      tooltip: t.editor.toolbar.redo,
                      enabled: !widget.readOnly && widget.isRedoPossible,
                      onPressed: widget.redo,
                      padding: buttonPadding,
                      child: const AdaptiveIcon(
                        icon: Icons.redo,
                        cupertinoIcon: CupertinoIcons.arrow_uturn_right,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // 2. Main Writing Tools
              ToolbarIconButton(
                tooltip: Pen.currentPen.name,
                selected: widget.currentTool == Pen.currentPen,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool == Pen.currentPen) {
                    toolOptionsType.value = (toolOptionsType.value == ToolOptions.pen)
                        ? ToolOptions.hide
                        : ToolOptions.pen;
                  } else {
                    toolOptionsType.value = ToolOptions.hide;
                    widget.setTool(Pen.currentPen);
                  }
                },
                padding: buttonPadding,
                child: UniIcon(Pen.currentPen.icon, size: 18),
              ),
              ToolbarIconButton(
                tooltip: t.editor.pens.pencil,
                selected: widget.currentTool == Pencil.currentPencil,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool == Pencil.currentPencil) {
                    toolOptionsType.value = (toolOptionsType.value == ToolOptions.pencil)
                        ? ToolOptions.hide
                        : ToolOptions.pencil;
                  } else {
                    toolOptionsType.value = ToolOptions.hide;
                    widget.setTool(Pencil.currentPencil);
                  }
                },
                padding: buttonPadding,
                child: const FaIcon(Pencil.pencilIcon, size: 16),
              ),
              ToolbarIconButton(
                tooltip: t.editor.pens.highlighter,
                selected: widget.currentTool == Highlighter.currentHighlighter,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool == Highlighter.currentHighlighter) {
                    toolOptionsType.value = (toolOptionsType.value == ToolOptions.highlighter)
                        ? ToolOptions.hide
                        : ToolOptions.highlighter;
                  } else {
                    toolOptionsType.value = ToolOptions.hide;
                    widget.setTool(Highlighter.currentHighlighter);
                  }
                },
                padding: buttonPadding,
                child: const FaIcon(Highlighter.highlighterIcon, size: 16),
              ),
              ToolbarIconButton(
                tooltip: t.editor.toolbar.toggleEraser,
                selected: widget.currentTool is Eraser,
                enabled: !widget.readOnly,
                onPressed: toggleEraser,
                padding: buttonPadding,
                child: const FaIcon(FontAwesomeIcons.eraser, size: 16),
              ),
              ToolbarIconButton(
                tooltip: t.editor.toolbar.select,
                selected: widget.currentTool is Select,
                enabled: !widget.readOnly,
                onPressed: () {
                  toolOptionsType.value = ToolOptions.hide;
                  widget.setTool(Select.currentSelect);
                },
                padding: buttonPadding,
                child: const Icon(CupertinoIcons.lasso, size: 18),
              ),

              const SizedBox(width: 4),

              // 3. Media & Text Tools
              ToolbarIconButton(
                tooltip: t.editor.toolbar.text,
                selected: widget.textEditing,
                enabled: !widget.readOnly,
                onPressed: widget.toggleTextEditing,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.title,
                  cupertinoIcon: CupertinoIcons.textformat,
                ),
              ),
              ToolbarIconButton(
                tooltip: t.editor.toolbar.photo,
                enabled: !widget.readOnly,
                onPressed: widget.pickPhoto,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.image_outlined,
                  cupertinoIcon: CupertinoIcons.photo,
                ),
              ),

              const SizedBox(width: 4),

              // 4. Quick Color Palette
              ...[
                const Color(0xFF1E1E1E),
                const Color(0xFF2563EB),
                const Color(0xFFDC2626),
                const Color(0xFF16A34A),
                const Color(0xFFD97706),
              ].map((color) {
                final isSelected = currentColor != null &&
                    currentColor.toARGB32() == color.toARGB32();
                return InkWell(
                  onTap: widget.readOnly
                      ? null
                      : () {
                          setState(() {
                            widget.setColor(color);
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withInversion(invert).withValues(alpha: 1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }),

              // ปุ่มเปิดจานสีเต็ม
              ValueListenableBuilder(
                valueListenable: showColorOptions,
                builder: (context, showColorOptions, child) {
                  return ToolbarIconButton(
                    tooltip: t.editor.toolbar.toggleColors,
                    selected: showColorOptions,
                    enabled: !widget.readOnly,
                    onPressed: toggleColorOptions,
                    padding: buttonPadding,
                    child: const Icon(Icons.palette_outlined, size: 18),
                  );
                },
              ),

              // 5. Stylus / Finger Toggle
              if (!stows.hideFingerDrawingToggle.value)
                ValueListenableBuilder(
                  valueListenable: stows.editorFingerDrawing,
                  builder: (context, value, child) {
                    return ToolbarIconButton(
                      tooltip: t.editor.toolbar.toggleFingerDrawing,
                      selected: value,
                      enabled: !widget.readOnly,
                      onPressed: widget.toggleFingerDrawing,
                      padding: buttonPadding,
                      child: const Icon(CupertinoIcons.hand_draw, size: 18),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ];

    return Flex(
      direction: isToolbarVertical ? Axis.horizontal : Axis.vertical,
      textDirection: switch (stows.editorToolbarAlignment.value) {
        AxisDirection.left => TextDirection.rtl,
        AxisDirection.right => TextDirection.ltr,
        _ => null,
      },
      verticalDirection: switch (stows.editorToolbarAlignment.value) {
        AxisDirection.down => VerticalDirection.down,
        AxisDirection.up => VerticalDirection.up,
        _ => VerticalDirection.down,
      },
      children: bars,
    );
  }

  @override
  void dispose() {
    DynamicMaterialApp.removeFullscreenListener(_setState);
    _removeKeybindings();
    super.dispose();
  }
}

enum ToolOptions { hide, pen, highlighter, pencil, select, eraser }