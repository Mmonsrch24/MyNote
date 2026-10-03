import 'package:flutter/material.dart';

class ColorBar extends StatefulWidget {
  const ColorBar({
    super.key,
    required this.setColor,
    this.currentColor,
    this.axis = Axis.horizontal,
    this.invert = false,
  });

  final ValueChanged<Color> setColor;
  final Color? currentColor;
  final Axis axis;
  final bool invert;

  // คืนค่า static variable ให้ editor.dart ใช้งานได้ตามเดิม
  static const List<Color> colorPresets = [
    Color(0xFF1E1E1E), Color(0xFFDC2626), Color(0xFF2563EB), Color(0xFF16A34A), Color(0xFFEAB308),
    Color(0xFF9333EA), Color(0xFFF97316), Color(0xFF06B6D4), Color(0xFFEC4899), Color(0xFFFFFFFF),
  ];

  @override
  State<ColorBar> createState() => _ColorBarState();
}

class _ColorBarState extends State<ColorBar> {
  int _selectedTab = 0; // 0: Color palette, 1: Color Set
  double _hue = 45.0;
  double _saturation = 0.8;
  double _value = 0.85;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentColor != null) {
      final hsv = HSVColor.fromColor(widget.currentColor!);
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _opacity = hsv.alpha;
    }
  }

  Color get _activeColor => HSVColor.fromAHSV(_opacity, _hue, _saturation, _value).toColor();

  @override
  Widget build(BuildContext context) {
    final hexString = _activeColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

    return Center(
      child: Container(
        width: 310,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235),
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
          children: [
            // 1. สลับแท็บ Color palette / Color Set
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Color palette', 0)),
                  Expanded(child: _buildTabButton('Color Set', 1)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. กล่อง Saturation / Value Gradient Box
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _saturation = (details.localPosition.dx / 278).clamp(0.0, 1.0);
                  _value = (1.0 - (details.localPosition.dy / 140)).clamp(0.0, 1.0);
                  widget.setColor(_activeColor);
                });
              },
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                  color: HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Slider Hue Spectrum
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 12,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                thumbColor: Colors.white,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
              ),
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.red, Colors.yellow, Colors.green, Colors.cyan,
                      Colors.blue, Colors.purple, Colors.red,
                    ],
                  ),
                ),
                child: Slider(
                  value: _hue,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (val) {
                    setState(() {
                      _hue = val;
                      widget.setColor(_activeColor);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Hex & Opacity
            Row(
              children: [
                const Icon(Icons.colorize, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'Hex $hexString',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_opacity * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _activeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 1.5),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Preset Colors
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ColorBar.colorPresets.map((preset) {
                final isSelected = _activeColor.toARGB32() == preset.toARGB32();
                return GestureDetector(
                  onTap: () {
                    final hsv = HSVColor.fromColor(preset);
                    setState(() {
                      _hue = hsv.hue;
                      _saturation = hsv.saturation;
                      _value = hsv.value;
                      widget.setColor(preset);
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: preset,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF60A5FA) : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}