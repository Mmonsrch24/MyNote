import 'package:flutter/material.dart';

class PageManagerModal extends StatefulWidget {
  const PageManagerModal({
    super.key,
    required this.onClose,
    required this.currentPage,
    required this.totalPages,
    this.onAddPage,
  });

  final VoidCallback onClose;
  final int currentPage;
  final int totalPages;
  final void Function(int insertPosition, String pattern)? onAddPage;

  @override
  State<PageManagerModal> createState() => _PageManagerModalState();
}

class _PageManagerModalState extends State<PageManagerModal> {
  int _insertPosition = 1; // 0: Before, 1: After, 2: Last page
  int _selectedTemplate = 0; // 0: Blank, 1: Thin line, 2: Wide line, 3: Grid, 4: Dots
  double _lineHeight = 40.0;
  double _lineWidth = 3.0;

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Blank', 'icon': Icons.crop_portrait},
    {'name': 'Thin line', 'icon': Icons.format_align_justify},
    {'name': 'Wide line', 'icon': Icons.menu},
    {'name': 'Grid', 'icon': Icons.grid_4x4},
    {'name': 'Dots', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
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
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. ตำแหน่งแทรกหน้า (Before / After / Last page)
            Row(
              children: [
                _buildPositionButton('Before current', 0),
                const SizedBox(width: 6),
                _buildPositionButton('After current', 1),
                const SizedBox(width: 6),
                _buildPositionButton('Last page', 2),
              ],
            ),
            const SizedBox(height: 16),

            // 3. แทมเพลตกระดาษ
            const Text(
              'Templates',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  final isSelected = _selectedTemplate == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTemplate = index),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3B82F6) : Colors.white12,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            template['icon'] as IconData,
                            color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            template['name'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 4. ตั้งค่าความสูงและความหนาของเส้น
            Row(
              children: [
                const Text('Line height', style: TextStyle(color: Colors.white60, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _lineHeight,
                    min: 20.0,
                    max: 80.0,
                    onChanged: (val) => setState(() => _lineHeight = val),
                  ),
                ),
                Text('${_lineHeight.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            Row(
              children: [
                const Text('Line width', style: TextStyle(color: Colors.white60, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _lineWidth,
                    min: 1.0,
                    max: 6.0,
                    onChanged: (val) => setState(() => _lineWidth = val),
                  ),
                ),
                Text('${_lineWidth.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Divider(color: Colors.white12, height: 16),

            // 5. ปุ่มนำเข้าไฟล์แทรก
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImportAction(Icons.picture_as_pdf, 'Import PDF'),
                _buildImportAction(Icons.image, 'Import image'),
                _buildImportAction(Icons.camera_alt, 'Take photo'),
              ],
            ),
            const SizedBox(height: 16),

            // 6. ปุ่มยืนยันสร้างหน้าใหม่
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAddPage?.call(
                    _insertPosition,
                    _templates[_selectedTemplate]['name'] as String,
                  );
                  widget.onClose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Apply and Add Page',
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

  Widget _buildPositionButton(String label, int index) {
    final isSelected = _insertPosition == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _insertPosition = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF60A5FA) : Colors.white60,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImportAction(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF60A5FA)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}