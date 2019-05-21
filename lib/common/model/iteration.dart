class Iteration {
  final List<String> drumTypes;
  final Duration pause;
  final Duration start;

  Iteration({this.drumTypes, this.pause, this.start});

  Iteration copyWith({
    List<String> drumTypes,
    Duration pause,
    Duration start,
  }) {
    return Iteration(
      drumTypes: drumTypes ?? this.drumTypes,
      pause: pause ?? this.pause,
      start: start ?? this.start,
    );
  }

  factory Iteration.fromJson(dynamic json) {
    return Iteration(
      drumTypes: List<String>.from(json['drumType']),
      pause: Duration(seconds: json['pause']),
      start: Duration(seconds: json['startDuration']),
    );
  }

  static List<Iteration> listFromDocuments(List<dynamic> iterations) {
    return iterations == null
        ? []
        : iterations
        .map(
            (iteration) => Iteration.fromJson(iteration))
        .toList();
  }
}
