import 'package:images_files_checker/src/domain/common/result.dart';

import '../models/user_options.dart';

abstract class UserOptionsRepository {
  Result<UserOptions> getUserOptions(List<String> arguments);
}
