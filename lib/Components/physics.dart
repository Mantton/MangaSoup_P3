import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomScrollPhysics extends ScrollPhysics {
  final double friction;

  const CustomScrollPhysics(this.friction, {ScrollPhysics parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(friction, parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final tolerance = this.tolerance;
    if ((velocity.abs() < tolerance.velocity) ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: 1,
      friction: 0, // <--- HERE
      tolerance: tolerance,
    );
  }
}

class NoMomentumScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that prevent the scroll offset from exceeding the
  /// bounds of the content..
  final double velocityT;

  const NoMomentumScrollPhysics({ScrollPhysics parent, this.velocityT = 7500})
      : super(parent: parent);

  @override
  NoMomentumScrollPhysics applyTo(ScrollPhysics ancestor) {
    return NoMomentumScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
              'The proposed new position, $value, is exactly equal to the current position of the '
              'given ${position.runtimeType}, ${position.pixels}.\n'
              'The applyBoundaryConditions method should only be called when the value is '
              'going to actually change the pixels, otherwise it is redundant.'),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty)
        ]);
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overscroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
      return null;
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
      return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  @override
  double get maxFlingVelocity => velocityT;

  @override
  double carriedMomentum(double existingVelocity) {
    return super.carriedMomentum(10); // carry little momentum over
  }
}
