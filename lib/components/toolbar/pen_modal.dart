import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/shape_pen.dart';

class PenModal extends StatefulWidget {
  const PenModal({super.key, required this.getTool, required this.setTool});

  final Tool Function() getTool;
  final void Function(Pen) setTool;

  @override
  State<PenModal> createState() => _PenModalState();
}

class _PenModalState extends State<PenModal> {
  int _lineTypeIndex = 0; // 0: solid, 1: dashed, 2: dotted
  double _stabilization = 0.0;

  @override
  Widget build(BuildContext context) {
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox();
    }

    final double penSize = currentPen.options.size;

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
            // 1. ส่วนหัวแสดงชื่อปากกา
            Center(
              child: Text(
                currentPen.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. แถวเลือกประเภทหัวปากกา 5 รูปแบบ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPenTypeIcon(
                  label: 'Fountain',
                  icon: SvgPicture.asset(
                    'assets/images/scribble_fountain.svg',
                    width: 22,
                    height: 22 / 508 * 374,
                    theme: const SvgTheme(currentColor: Colors.white70),
                  ),
                  isSelected: currentPen.icon == Pen.fountainPenIcon,
                  onTap: () => setState(() => widget.setTool(Pen.fountainPen())),
                ),
                _buildPenTypeIcon(
                  label: 'Ballpoint',
                  icon: SvgPicture.asset(
                    'assets/images/scribble_ballpoint.svg',
                    width: 22,
                    height: 22 / 508 * 374,
                    theme: const SvgTheme(currentColor: Colors.white70),
                  ),
                  isSelected: currentPen.icon == Pen.ballpointPenIcon,
                  onTap: () => setState(() => widget.setTool(Pen.ballpointPen())),
                ),
                _buildPenTypeIcon(
                  label: 'Shape',
                  icon: const FaIcon(ShapePen.shapePenIcon, size: 18, color: Colors.white70),
                  isSelected: currentPen.icon == ShapePen.shapePenIcon,
                  onTap: () => setState(() => widget.setTool(ShapePen())),
                ),
                _buildPenTypeIcon(
                  label: 'Marker',
                  icon: const FaIcon(Highlighter.highlighterIcon, size: 18, color: Colors.white70),
                  isSelected: currentPen is Highlighter,
                  onTap: () => setState(() => widget.setTool(Highlighter.currentHighlighter)),
                ),
                _buildPenTypeIcon(
                  label: 'Pencil',
                  icon: const FaIcon(Pencil.pencilIcon, size: 18, color: Colors.white70),
                  isSelected: currentPen is Pencil,
                  onTap: () => setState(() => widget.setTool(Pencil.currentPencil)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Line type
            const Text(
              'Line type',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLineTypeOption(0, '——'),
                const SizedBox(width: 8),
                _buildLineTypeOption(1, '- - -'),
                const SizedBox(width: 8),
                _buildLineTypeOption(2, '· · · ·'),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Thickness
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thickness',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${(penSize * 0.1).toStringAsFixed(2)} mm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveTrackColor: Colors.white12,
                thumbColor: const Color(0xFF60A5FA),
                trackHeight: 3,
              ),
              child: Slider(
                value: penSize.clamp(1.0, 30.0),
                min: 1.0,
                max: 30.0,
                onChanged: (val) {
                  setState(() {
                    currentPen.options.size = val;
                  });
                },
              ),
            ),

            // 5. Stroke Stabilization
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stroke Stabilization',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${(_stabilization * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveTrackColor: Colors.white12,
                thumbColor: const Color(0xFF60A5FA),
                trackHeight: 3,
              ),
              child: Slider(
                value: _stabilization,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (val) {
                  setState(() {
                    _stabilization = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),

            // 6. Color
            const Text(
              'Color',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Color(0xFF1E1E1E),
                const Color(0xFFDC2626),
                const Color(0xFF2563EB),
                const Color(0xFF16A34A),
                const Color(0xFFEAB308),
              ].map((color) {
                final isSelected = currentPen.color.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPen.color = color;
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 7. ปุ่ม Add to pen box
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ),
                child: const Text(
                  'Add to pen box',
                  style: TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenTypeIcon({
    required String label,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: icon,
      ),
    );
  }

  Widget _buildLineTypeOption(int index, String text) {
    final isSelected = _lineTypeIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _lineTypeIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.white12,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}