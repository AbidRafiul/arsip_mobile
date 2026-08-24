import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Gunakan font Inter dari asset lokal — tidak perlu internet
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MobileApprovalApp());
}
