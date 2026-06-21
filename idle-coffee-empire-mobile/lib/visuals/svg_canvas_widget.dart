import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

enum _LoadState { loading, loaded, error }

/// Loads and renders a [flame_svg] [Svg] asset inside the Flutter widget tree.
/// Accepts an asset path relative to the assets/ folder (e.g. 'ui/coffee_coin.svg').
/// Three states: loading → transparent SizedBox, loaded → CustomPaint, error → subtle icon.
class SvgCanvasWidget extends StatefulWidget {
  const SvgCanvasWidget(this.assetPath, {super.key, required this.size});

  final String? assetPath;
  final double size;

  @override
  State<SvgCanvasWidget> createState() => _SvgCanvasWidgetState();
}

class _SvgCanvasWidgetState extends State<SvgCanvasWidget> {
  _LoadState _state = _LoadState.loading;
  Svg? _svg;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(SvgCanvasWidget old) {
    super.didUpdateWidget(old);
    if (old.assetPath != widget.assetPath) {
      setState(() {
        _state = _LoadState.loading;
        _svg = null;
      });
      _loadSvg();
    }
  }

  Future<void> _loadSvg() async {
    final path = widget.assetPath;
    if (path == null) {
      if (mounted) setState(() => _state = _LoadState.error);
      return;
    }
    try {
      final svg = await Svg.load(path);
      if (mounted) {
        setState(() {
          _svg = svg;
          _state = _LoadState.loaded;
        });
      }
    } catch (e, stack) {
      debugPrint('SVG LOAD FAILED: $path — $e');
      debugPrint('$stack');
      if (mounted) setState(() => _state = _LoadState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _LoadState.loading => SizedBox(width: widget.size, height: widget.size),
      _LoadState.error => SizedBox(
          width: widget.size,
          height: widget.size,
          child: Icon(
            Icons.broken_image_outlined,
            size: widget.size * 0.5,
            color: Colors.white24,
          ),
        ),
      _LoadState.loaded => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _SvgPainter(_svg!),
        ),
    };
  }
}

class _SvgPainter extends CustomPainter {
  const _SvgPainter(this.svg);
  final Svg svg;

  @override
  void paint(Canvas canvas, Size size) {
    svg.render(canvas, Vector2(size.width, size.height));
  }

  @override
  bool shouldRepaint(_SvgPainter old) => old.svg != svg;
}
