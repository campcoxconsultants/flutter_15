/// 2d coordinate for the puzzle hack. Can only be used with reasonable x/y values
class Coordinate {
  const Coordinate({required this.x, required this.y});
  final int x;
  final int y;

  bool compare({
    Coordinate? isSameRow,
    Coordinate? isDifferentRow,
    Coordinate? isSameColumn,
    Coordinate? isDifferentColumn,
    Coordinate? isLeftOf,
    Coordinate? isNotLeftOf,
    Coordinate? isRightOf,
    Coordinate? isNotRightOf,
    Coordinate? isAbove,
    Coordinate? isNotAbove,
    Coordinate? isBelow,
    Coordinate? isNotBelow,
    int? compareRow,
    int? compareColumn,
  }) {
    if (isSameRow != null && y != isSameRow.y) {
      return false;
    }
    if (isDifferentRow != null && y == isDifferentRow.y) {
      return false;
    }
    if (isSameColumn != null && x != isSameColumn.x) {
      return false;
    }
    if (isDifferentColumn != null && x == isDifferentColumn.x) {
      return false;
    }
    if (isLeftOf != null && x >= isLeftOf.x) {
      return false;
    }
    if (isNotLeftOf != null && x < isNotLeftOf.x) {
      return false;
    }
    if (isRightOf != null && x <= isRightOf.x) {
      return false;
    }
    if (isNotRightOf != null && x > isNotRightOf.x) {
      return false;
    }
    if (isAbove != null && y >= isAbove.y) {
      return false;
    }
    if (isNotAbove != null && y < isNotAbove.y) {
      return false;
    }
    if (isBelow != null && y <= isBelow.y) {
      return false;
    }
    if (isNotBelow != null && y > isNotBelow.y) {
      return false;
    }

    if (compareRow != null && y != compareRow) {
      return false;
    }
    if (compareColumn != null && x != compareColumn) {
      return false;
    }

    return true;
  }

  bool isSameRow(Coordinate other) => y == other.y;
  bool isSameColumn(Coordinate other) => x == other.x;
  bool isRightOf(Coordinate other) => x > other.x;
  bool isLeftOf(Coordinate other) => x < other.x;
  bool isAbove(Coordinate other) => y < other.y;
  bool isBelow(Coordinate other) => y > other.y;

  @override
  String toString() => '{x: $x, y: $y}';
  @override
  bool operator ==(Object other) => other is Coordinate && x == other.x && y == other.y;

  Coordinate operator +(Coordinate other) => Coordinate(x: x + other.x, y: y + other.y);

  @override
  int get hashCode => x * 1000 + y;
}
