import 'package:flutter/material.dart';

class SelectionBar extends StatefulWidget {
  const SelectionBar({
    super.key,
    required this.duplicateSelection,
    required this.deleteSelection,
  });

  final VoidCallback duplicateSelection;
  final VoidCallback deleteSelection;

  @override
  State<SelectionBar> createState() => _SelectionBarState();
}

class _SelectionBarState extends State<SelectionBar> {
  bool _showMoreMenu = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. แถบเมนูหลัก Context Bar (หน้า 6 ใน PDF)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2235), // Dark Theme สไตล์ StarNote
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton('Cut', () {}),
                _buildActionButton('Copy', widget.duplicateSelection),
                _buildActionButton('Paste', () {}),
                _buildActionButton('Delete', widget.deleteSelection, isDestructive: true),
                _buildActionButton('Change style', () {}),
                _buildActionButton('Crop', () {}),
                _buildActionButton('Lasso crop', () {}),
                const VerticalDivider(width: 12, color: Colors.white24, thickness: 1),
                // ปุ่มสามจุด More
                IconButton(
                  icon: Icon(
                    _showMoreMenu ? Icons.close : Icons.more_vert,
                    color: Colors.white70,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  tooltip: 'More',
                  onPressed: () {
                    setState(() {
                      _showMoreMenu = !_showMoreMenu;
                    });
                  },
                ),
              ],
            ),
          ),

          // 2. เมนูย่อย More Menu เมื่อแตะสามจุด (หน้า 6 กล่องสีม่วง)
          if (_showMoreMenu)
            Container(
              width: 190,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2235),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem('Convert to math', () {}),
                  _buildMenuItem('Align handwriting', () {}),
                  _buildMenuItem('Move forward', () {}),
                  _buildMenuItem('Move backward', () {}),
                  const Divider(color: Colors.white12, height: 8),
                  _buildMenuItem('Lock', () {}, isLock: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, VoidCallback onTap, {bool isDestructive = false}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap, {bool isLock = false}) {
    return InkWell(
      onTap: () {
        setState(() => _showMoreMenu = false);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isLock ? const Color(0xFF60A5FA) : Colors.white70,
            fontSize: 13,
            fontWeight: isLock ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}