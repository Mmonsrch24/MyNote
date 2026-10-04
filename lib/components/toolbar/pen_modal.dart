import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
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

  @override
  Widget build(BuildContext context) {
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox.shrink();
    }

    final double penSize = currentPen.options.size;

    return Center(
      child: Container(
        width: 300,
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
            Center(
              child: Text(
                currentPen.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // แถวเลือกหัวปากกา 3 แบบจริงตามประเภท Pen (ตัดดินสอและไฮไลต์ออก)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPenTypeIcon(
                  label: 'Fountain',
                  icon: SvgPicture.asset(
                    'assets/images/scribble_fountain.svg',
                    width: 20,
                    height: 20 / 508 * 374,
                    theme: const SvgTheme(currentColor: Colors.white70),
                  ),
                  isSelected: currentPen.icon == Pen.fountainPenIcon,
                  onTap: () {
                    final newPen = Pen.fountainPen();
                    newPen.options.size = penSize;
                    newPen.color = currentPen.color;
                    widget.setTool(newPen);
                    setState(() {});
                  },
                ),
                _buildPenTypeIcon(
                  label: 'Ballpoint',
                  icon: SvgPicture.asset(
                    'assets/images/scribble_ballpoint.svg',
                    width: 20,
                    height: 20 / 508 * 374,
                    theme: const SvgTheme(currentColor: Colors.white70),
                  ),
                  isSelected: currentPen.icon == Pen.ballpointPenIcon,
                  onTap: () {
                    final newPen = Pen.ballpointPen();
                    newPen.options.size = penSize;
                    newPen.color = currentPen.color;
                    widget.setTool(newPen);
                    setState(() {});
                  },
                ),
                _buildPenTypeIcon(
                  label: 'Shape',
                  icon: const FaIcon(ShapePen.shapePenIcon, size: 16, color: Colors.white70),
                  isSelected: currentPen.icon == ShapePen.shapePenIcon,
                  onTap: () {
                    final shapePen = ShapePen();
                    shapePen.options.size = penSize;
                    shapePen.color = currentPen.color;
                    widget.setTool(shapePen);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Line type',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildLineTypeOption(0, '——'),
                const SizedBox(width: 6),
                _buildLineTypeOption(1, '- - -'),
                const SizedBox(width: 6),
                _buildLineTypeOption(2, '· · · ·'),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thickness', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  '${(penSize * 0.1).toStringAsFixed(2)} mm',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.white12,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}