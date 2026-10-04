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
  int _tipType = 0; // 0: Chisel (หัวตัด), 1: Round (หัวกลม)
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

    const pastelColors = [
      Color(0xFFFF8B94), Color(0xFFFFB3BA), Color(0xFFBAFFC9), Color(0xFFB5EAD7),
      Color(0xFFFFDAC1), Color(0xFFFFEE93), Color(0xFFBAE1FF), Color(0xFFE2F0CB),
    ];

    return Center(
      child: Container(
        width: 310,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวและปุ่มเลือกรูปทรงหัวมาร์กเกอร์ (หัวตัด vs หัวกลม)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTipChoice(0, Icons.border_color, 'Chisel'),
                const SizedBox(width: 12),
                _buildTipChoice(1, Icons.edit, 'Round'),
              ],
            ),
            const SizedBox(height: 14),

            // Slider ความหนา
            Row(
              children: [
                const Icon(Icons.remove, color: Colors.white54, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white38,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      trackHeight: 6,
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
                const Icon(Icons.add, color: Colors.white54, size: 16),
                SizedBox(
                  width: 28,
                  child: Text(
                    size.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            // Slider ความทึบแสง (ส่งค่า Alpha จริงเข้าวัตถุ Highlighter)
            Row(
              children: [
                const Icon(Icons.opacity, color: Colors.white54, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: highlighter.color.withValues(alpha: 0.9),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: highlighter.color.a.clamp(0.1, 1.0),
                      min: 0.1,
                      max: 1.0,
                      onChanged: (val) {
                        setState(() {
                          // อัปเดตสีพร้อม Alpha ทันที
                          highlighter.color = highlighter.color.withValues(alpha: val);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$opacityPercent%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Straighten lines', style: TextStyle(color: Colors.white70, fontSize: 12)),
              value: _straightenLines,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _straightenLines = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Adjust thickness to text', style: TextStyle(color: Colors.white70, fontSize: 12)),
              value: _adjustThicknessToText,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _adjustThicknessToText = val),
            ),
            const SizedBox(height: 10),

            // จานสีพาสเทล 8 สี
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: pastelColors.map((color) {
                final isSelected = highlighter.color.toARGB32() ==
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
                    child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.black87) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipChoice(int index, IconData icon, String label) {
    final isSelected = _tipType == index;
    return GestureDetector(
      onTap: () => setState(() => _tipType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF60A5FA) : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}