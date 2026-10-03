import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';

class PenModal extends StatefulWidget {
  const PenModal({super.key, required this.getTool, required this.setTool});

  final Tool Function() getTool;
  final void Function(Pen) setTool;

  @override
  State<PenModal> createState() => _PenModalState();
}

class _PenModalState extends State<PenModal> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox();
    }

    final isHighlighterOrPencil = currentPen is Highlighter || currentPen is Pencil;
    final double penSize = currentPen.options.size;

    return Center(
      child: Container(
        width: 310,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Live Stroke Preview
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Container(
                width: (penSize * 3).clamp(8.0, 200.0),
                height: penSize.clamp(2.0, 32.0),
                decoration: BoxDecoration(
                  color: currentPen.color,
                  borderRadius: BorderRadius.circular(penSize / 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. ขนาดเส้นด่วน 4 ระดับ (Quick Presets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2.0, 4.0, 8.0, 14.0].map((preset) {
                final isSelected = (penSize - preset).abs() < 0.6;
                return ChoiceChip(
                  label: Text('${preset.toInt()} pt'),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                  selected: isSelected,
                  selectedColor: colorScheme.primary,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        currentPen.options.size = preset;
                      });
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // 3. Slider ปรับขนาดเส้น
            Row(
              children: [
                const Icon(Icons.line_weight, size: 18),
                Expanded(
                  child: Slider(
                    value: penSize.clamp(1.0, 30.0),
                    min: 1.0,
                    max: 30.0,
                    divisions: 58,
                    label: penSize.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        currentPen.options.size = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    penSize.toStringAsFixed(0),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),

            // 4. สลับชนิดปากกา
            if (!isHighlighterOrPencil) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: t.editor.pens.fountainPen,
                    onPressed: () => setState(() {
                      widget.setTool(Pen.fountainPen());
                    }),
                    style: IconButton.styleFrom(
                      backgroundColor: Pen.currentPen.icon == Pen.fountainPenIcon
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      foregroundColor: Pen.currentPen.icon == Pen.fountainPenIcon
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    icon: SvgPicture.asset(
                      'assets/images/scribble_fountain.svg',
                      width: 24,
                      height: 24 / 508 * 374,
                      theme: SvgTheme(
                        currentColor: Pen.currentPen.icon == Pen.fountainPenIcon
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.editor.pens.ballpointPen,
                    onPressed: () => setState(() {
                      widget.setTool(Pen.ballpointPen());
                    }),
                    style: IconButton.styleFrom(
                      backgroundColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      foregroundColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    icon: SvgPicture.asset(
                      'assets/images/scribble_ballpoint.svg',
                      width: 24,
                      height: 24 / 508 * 374,
                      theme: SvgTheme(
                        currentColor: Pen.currentPen.icon == Pen.ballpointPenIcon
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: t.editor.pens.shapePen,
                    onPressed: () => setState(() {
                      widget.setTool(ShapePen());
                    }),
                    style: IconButton.styleFrom(
                      backgroundColor: Pen.currentPen.icon == ShapePen.shapePenIcon
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      foregroundColor: Pen.currentPen.icon == ShapePen.shapePenIcon
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    icon: const FaIcon(ShapePen.shapePenIcon, size: 18),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}