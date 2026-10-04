import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/eraser.dart';

class EraserModal extends StatefulWidget {
  const EraserModal({
    super.key,
    required this.eraser,
    this.onClearAll,
  });

  final Eraser eraser;
  final VoidCallback? onClearAll;

  @override
  State<EraserModal> createState() => _EraserModalState();
}

class _EraserModalState extends State<EraserModal> {
  @override
  Widget build(BuildContext context) {
    // อ่านค่าโหมดจริงจาก Preferences ของ Saber
    final isStrokeEraser = stows.eraserType.value == EraserType.wholeStroke;

    return Center(
      child: Container(
        width: 290,
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
            const Center(
              child: Text(
                'Eraser',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Handwriting eraser',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Stroke eraser: ลบทั้งเส้น
            _buildModeTile(
              title: 'Stroke eraser',
              isSelected: isStrokeEraser,
              onTap: () {
                setState(() {
                  stows.eraserType.value = EraserType.wholeStroke;
                });
              },
            ),
            const SizedBox(height: 6),

            // Area eraser: ลบเฉพาะจุดที่โดน
            _buildModeTile(
              title: 'Area eraser',
              isSelected: !isStrokeEraser,
              onTap: () {
                setState(() {
                  stows.eraserType.value = EraserType.partialStroke;
                });
              },
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 16),

            // ล้างลายมือทั้งหมดในหน้า
            InkWell(
              onTap: widget.onClearAll,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.trashCan, size: 13, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Erase all handwriting',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 16, color: Color(0xFF60A5FA)),
          ],
        ),
      ),
    );
  }
}