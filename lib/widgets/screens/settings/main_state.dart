part of 'main_cubit.dart';

class MainState {
  final bool isLightTheme;
  const MainState.init({
    this.isLightTheme = true,
  });

//<editor-fold desc="Data Methods">
  const MainState({
    required this.isLightTheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MainState &&
          runtimeType == other.runtimeType &&
          isLightTheme == other.isLightTheme);

  @override
  int get hashCode => isLightTheme.hashCode;

  @override
  String toString() {
    return 'MainState{' + ' isLightTheme: $isLightTheme,' + '}';
  }

  MainState copyWith({
    bool? isLightTheme,
  }) {
    return MainState(
      isLightTheme: isLightTheme ?? this.isLightTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isLightTheme': this.isLightTheme,
    };
  }

  factory MainState.fromMap(Map<String, dynamic> map) {
    return MainState(
      isLightTheme: map['isLightTheme'] as bool,
    );
  }

//</editor-fold>
}
