import 'package:dartz/dartz.dart';

import '../errors/failure.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final r = int.parse(str);

      if (isValid(r)) {
        return Right(r);
      }

      return Left(InvalidInputFailure());
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }

  bool isValid(int r) => r >= 0;
}

class InvalidInputFailure extends Failure {}
