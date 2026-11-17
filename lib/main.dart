import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

import 'services/via_cep_service.dart';
import 'services/demo_cep_service.dart';
import 'state/search_controller.dart' as search;
import 'views/home_page.dart';

void main() => runApp(const CepApp());

class CepApp extends StatelessWidget {
  const CepApp({super.key, this.controller});
  final search.SearchController? controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Consulta CEP',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14695C)),
      scaffoldBackgroundColor: const Color(0xFFF4F5F0),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: _Home(controller: controller),
  );
}

class _Home extends StatefulWidget {
  const _Home({this.controller});
  final search.SearchController? controller;
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  http.Client? _client;
  late final search.SearchController controller =
      widget.controller ??
      search.SearchController(
        const bool.fromEnvironment('DEMO')
            ? DemoCepService()
            : ViaCepService(_client = http.Client()),
      );
  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HomePage(controller: controller);
}
