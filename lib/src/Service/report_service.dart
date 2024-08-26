import 'package:ranchat_flutter/src/repository/report_repository.dart';

class ReportService {
  final ReportRepository _reportRepository = ReportRepository();

  Future<void> reportUser(String roomId, String userId, String reportedUserId,
      String selectedReason, String reportReason) {
    return _reportRepository.reportUser(
        roomId, userId, reportedUserId, selectedReason, reportReason);
  }
}
