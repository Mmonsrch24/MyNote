import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';

class HighlighterModal extends StatefulWidget {
  const HighlighterModal({
    super.key,
    required this.getTool,
    required this.setTool,
  });

  final Tool Function() getTool;
  final void Function(Highlighter) setTool;

  @override
  State<HighlighterModal> createState() => _HighlighterModalState();
}

class _HighlighterModalState extends State<HighlighterModal> {
  bool _straightenLines = false;
  bool _adjustThicknessToText = false;

  @override
  Widget build(BuildContext context) {
    final Tool currentTool = widget.getTool();
    final Highlighter highlighter;
    if (currentTool is Highlighter) {
      highlighter = currentTool;
    } else {
      return const SizedBox.shrink();
    }

    final double size = highlighter.options.size;
    final int opacityPercent = (highlighter.color.a * 100).round();

    // 8 สีพาสเทลสำหรับไฮไลต์ตามรูปหน้า 3
    const pastelColors = [
      Color(0xFFFF8B94), // ชมพู
      Color(0xFFFFB3BA), // ส้มอ่อน
      Color(0xFFBAFFC9), // เขียวมะนาวอ่อน
      Color(0xFFB5EAD7), // เขียวมิ้นต์
      Color(0xFFFFDAC1), // พีช
      Color(0xFFFFEE93), // เหลืองไฮไลต์หลัก
      Color(0xFFBAE1FF), // ฟ้าพาสเทล
      Color(0xFFE2F0CB), // เขียวตองอ่อน
    ];

    return Center(
      child: Container(
        width: 320,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235), // Dark Theme สไตล์ StarNote
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนหัวและไอคอนมาร์กเกอร์
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: highlighter.color.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      Highlighter.highlighterIcon,
                      color: highlighter.color.withValues(alpha: 1.0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Highlighter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. แถบเลื่อนปรับขนาดความหนาเส้น (Thickness)
            Row(
              children: [
                const Icon(Icons.remove, color: Colors.white54, size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white38,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 14,
                    ),
                    child: Slider(
                      value: size.clamp(5.0, 100.0),
                      min: 5.0,
                      max: 100.0,
                      onChanged: (val) {
                        setState(() {
                          highlighter.options.size = val;
                        });
                      },
                    ),
                  ),
                ),
                const Icon(Icons.add, color: Colors.white54, size: 18),
                const SizedBox(width: 6),
                SizedBox(
                  width: 28,
                  child: Text(
                    size.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3. แถบเลื่อนปรับความทึบแสง (Opacity)
            Row(
              children: [
                const Icon(Icons.opacity, color: Colors.white54, size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: highlighter.color.withValues(alpha: 0.8),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 14,
                    ),
                    child: Slider(
                      value: highlighter.color.a.clamp(0.1, 1.0),
                      min: 0.1,
                      max: 1.0,
                      onChanged: (val) {
                        setState(() {
                          highlighter.color = highlighter.color.withValues(alpha: val);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 38,
                  child: Text(
                    '$opacityPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. Smart Toggles (Straighten lines & Adjust thickness)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Straighten lines',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              value: _straightenLines,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _straightenLines = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Adjust thickness to text',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              value: _adjustThicknessToText,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _adjustThicknessToText = val),
            ),
            const SizedBox(height: 14),

            // 5. จานสีพาสเทล 8 สี + วงล้อสี
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...pastelColors.map((color) {
                  final isSelected =
                      highlighter.color.toARGB32() ==
                      color.withValues(alpha: highlighter.color.a).toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        highlighter.color = color.withValues(alpha: highlighter.color.a);
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 13, color: Colors.black87)
                          : null,
                    ),
                  );
                }),
                // ปุ่มวงล้อสีรุ้ง
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.red,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        Colors.red,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}