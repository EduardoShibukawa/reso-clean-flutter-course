import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  /* 
  Equatable
  */
  @override
  List<Object> get props => [text, number];

  final String text;
  final int number;    

  NumberTrivia({
    this.text,
    this.number,
  });
}
