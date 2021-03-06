import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd_course/core/errors/failure.dart';
import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/util/input_conveter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure.';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure.';
const String INVALID_INPUT_MESSAGE =
    'Invalid Input - The number must be a posite integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    @required GetConcreteNumberTrivia concrete,
    @required GetRandomNumberTrivia random,
    @required this.inputConverter,
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random;

  @override
  NumberTriviaState get initialState => Empty();

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      yield* _mapEventConcreteNumber(event.numberString);
    } else if (event is GetTriviaForRandomNumber) {
      yield* _mapEventTriviaRandomNumber();
    }
  }

  Stream<NumberTriviaState> _mapEventTriviaRandomNumber() async* {
    yield Loading();
    
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    
    yield* _eitherLoadOrErrorState(failureOrTrivia);
  }

  Stream<NumberTriviaState> _mapEventConcreteNumber(String numberString) async* {
    final inputEither =
        inputConverter.stringToUnsignedInteger(numberString);
    
    yield* inputEither.fold(
      (failure) async* {
        yield Error(message: INVALID_INPUT_MESSAGE);
      },
      (parsed_number) async* {
        yield Loading();
    
        final failureOrTrivia =
            await getConcreteNumberTrivia(Params(number: parsed_number));
    
        yield* _eitherLoadOrErrorState(failureOrTrivia);
      },
    );
  }

  Stream<NumberTriviaState> _eitherLoadOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia) async* {
    yield failureOrTrivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (trivia) => Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
