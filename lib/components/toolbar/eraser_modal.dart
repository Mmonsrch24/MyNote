import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _isStrokeEraser = true; // สลับโหมด Stroke กับ Area ใน UI
  bool _eraseHighlighterOnly = false;
  bool _eraseTapeOnly = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(18),
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
            // Header
            const Center(
              child: Text(
                'Eraser',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Handwriting eraser mode
            const Text(
              'Handwriting eraser',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),

            // Stroke eraser
            _buildModeTile(
              title: 'Stroke eraser',
              isSelected: _isStrokeEraser,
              onTap: () => setState(() => _isStrokeEraser = true),
            ),
            const SizedBox(height: 6),

            // Area eraser
            _buildModeTile(
              title: 'Area eraser',
              isSelected: !_isStrokeEraser,
              onTap: () => setState(() => _isStrokeEraser = false),
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 16),

            // 2. Erase highlighter only
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Erase highlighter only',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              value: _eraseHighlighterOnly,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _eraseHighlighterOnly = val),
            ),

            // 3. Erase tape only
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Erase tape only',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              value: _eraseTapeOnly,
              activeColor: const Color(0xFF3B82F6),
              onChanged: (val) => setState(() => _eraseTapeOnly = val),
            ),

            const Divider(color: Colors.white12, height: 16),

            // 4. Erase all handwriting
            InkWell(
              onTap: widget.onClearAll,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.trashCan, size: 14, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Erase all handwriting',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
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