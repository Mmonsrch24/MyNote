import 'package:flutter/material.dart';

class ColorOptionPreset {
  final Color color;
  const ColorOptionPreset(this.color);
}

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

  static const List<ColorOptionPreset> colorPresets = [
    ColorOptionPreset(Color(0xFF1E1E1E)),
    ColorOptionPreset(Color(0xFFDC2626)),
    ColorOptionPreset(Color(0xFF2563EB)),
    ColorOptionPreset(Color(0xFF16A34A)),
    ColorOptionPreset(Color(0xFFEAB308)),
    ColorOptionPreset(Color(0xFF9333EA)),
    ColorOptionPreset(Color(0xFFF97316)),
    ColorOptionPreset(Color(0xFF06B6D4)),
    ColorOptionPreset(Color(0xFFEC4899)),
    ColorOptionPreset(Color(0xFFFFFFFF)),
  ];

  @override
  State<ColorBar> createState() => _ColorBarState();
}

class _ColorBarState extends State<ColorBar> {
  int _selectedTab = 0; // 0: Color palette, 1: Color Set
  double _hue = 140.0; // ค่าเริ่มต้น (เฉดเขียว)
  double _saturation = 0.85;
  double _value = 0.85;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.currentColor != null) {
      final hsv = HSVColor.fromColor(widget.currentColor!);
      _hue = hsv.hue;
      _saturation = hsv.saturation == 0 ? 0.85 : hsv.saturation;
      _value = hsv.value == 0 ? 0.85 : hsv.value;
      _opacity = hsv.alpha;
    }
  }

  Color get _activeColor => HSVColor.fromAHSV(_opacity, _hue, _saturation, _value).toColor();

  void _updateColor(Color newColor) {
    widget.setColor(newColor);
  }

  @override
  Widget build(BuildContext context) {
    final hexString = _activeColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    final pureHueColor = HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();

    return Center(
      child: Container(
        width: 310,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2235), // Dark Theme ทึบแสง ป้องกันการทะลุเห็นพื้นหลัง
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
          children: [
            // 1. แถบสลับแท็บ Color palette / Color Set
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

            // 2. กล่อง Gradient Saturation/Value ปรับตาม _hue จริง 100%
            LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (details) => _handleColorPick(details.localPosition, constraints.maxWidth),
                  onPanUpdate: (details) => _handleColorPick(details.localPosition, constraints.maxWidth),
                  child: Container(
                    height: 135,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: pureHueColor, // สีพื้นหลังอิงตาม Hue ที่เลื่อนสไลเดอร์
                    ),
                    child: Stack(
                      children: [
                        // ไล่ระดับความขาว (Saturation จากซ้ายไปขวา)
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
                        // ไล่ระดับความมืด (Value จากบนลงล่าง)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black],
                            ),
                          ),
                        ),
                        // วงแหวนบอกตำแหน่งสีที่เลือกปัจจุบัน
                        Positioned(
                          left: (_saturation * constraints.maxWidth - 9).clamp(0.0, constraints.maxWidth - 18),
                          top: ((1.0 - _value) * 135 - 9).clamp(0.0, 135 - 18),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 3. สไลเดอร์เฉดสี Spectrum
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
                      _updateColor(_activeColor);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Hex, Opacity และกล่องสีพรีวิวพร้อมปุ่มบวก
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
                    border: Border.all(color: Colors.white60, width: 1.5),
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. ถาดสี Preset ด้านล่าง (เลือกแล้วสีเปลี่ยนทันที)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ColorBar.colorPresets.map((preset) {
                final isSelected = _activeColor.toARGB32() == preset.color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    final hsv = HSVColor.fromColor(preset.color);
                    setState(() {
                      _hue = hsv.hue;
                      _saturation = hsv.saturation == 0 ? 0.0 : hsv.saturation;
                      _value = hsv.value;
                      _updateColor(preset.color);
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: preset.color,
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

  void _handleColorPick(Offset localPosition, double width) {
    setState(() {
      _saturation = (localPosition.dx / width).clamp(0.0, 1.0);
      _value = (1.0 - (localPosition.dy / 135)).clamp(0.0, 1.0);
      _updateColor(_activeColor);
    });
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