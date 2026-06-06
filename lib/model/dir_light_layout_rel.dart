class DirLightLayoutRel {
  final double x; // 0..1
  final double y; // 0..1
  final double width;
  final double height;

  const DirLightLayoutRel({
    required this.x,
    required this.y,
    this.width = 120,
    this.height = 120,
  });
}