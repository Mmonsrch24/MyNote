import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExportBar extends StatefulWidget {
  const ExportBar({
    super.key,
    required this.toggleExportBar,
    this.exportAsSba,
    this.exportAsPdf,
    this.exportAsPng,
    this.axis = Axis.horizontal,
  });

  final VoidCallback toggleExportBar;
  final Future Function(BuildContext)? exportAsSba;
  final Future Function(BuildContext)? exportAsPdf;
  final Future Function(BuildContext)? exportAsPng;
  final Axis axis;

  @override
  State<ExportBar> createState() => _ExportBarState();
}

class _ExportBarState extends State<ExportBar> {
  int _selectedType = 0; // 0: Editable PDF, 1: Non-editable PDF, 2: Picture, 3: StarNote
  bool _includeBackground = true;
  bool _includeTape = false;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Quick note');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleExport() {
    widget.toggleExportBar();
    switch (_selectedType) {
      case 0:
      case 1:
        widget.exportAsPdf?.call(context);
        break;
      case 2:
        widget.exportAsPng?.call(context);
        break;
      case 3:
        widget.exportAsSba?.call(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235), // Dark Theme สไตล์ StarNote
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Cancel | Export file | Export only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.toggleExportBar,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                const Text(
                  'Export file',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: _handleExport,
                  child: const Text(
                    'Export only',
                    style: TextStyle(color: Color(0xFF60A5FA), fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. File Type Cards (4 ประเภท)
            Row(
              children: [
                _buildTypeCard(0, 'Editable PDF', Icons.picture_as_pdf),
                const SizedBox(width: 8),
                _buildTypeCard(1, 'Non-editable PDF', Icons.picture_as_pdf_outlined),
                const SizedBox(width: 8),
                _buildTypeCard(2, 'Picture', Icons.image_outlined),
                const SizedBox(width: 8),
                _buildTypeCard(3, 'StarNote', Icons.note_alt_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Info Description
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Editable PDF can be edited in other apps after being exported. Vector strokes remain fully scalable.',
                      style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. File name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'File name:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${_nameController.text.length}/60',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Checkbox Options
            Theme(
              data: ThemeData(unselectedWidgetColor: Colors.white38),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _includeBackground,
                    onChanged: (val) => setState(() => _includeBackground = val ?? true),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text(
                      'Includes page background (horizontal line/grid/image/text etc.)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _includeTape,
                    onChanged: (val) => setState(() => _includeTape = val ?? false),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text(
                      'Include tape (all tape shown by default)',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 6. ปุ่ม Export and share
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _handleExport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Export and share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(int index, String label, IconData icon) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}