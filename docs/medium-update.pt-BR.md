# Revisão pronta: Consultando CEPs com Flutter

Artigo: https://medium.com/flutter-comunidade-br/consultando-ceps-com-flutter-a395b86ce34a
Link original: http://bit.ly/2kcGFQh
Autor: Kleber Andrade. Publicação: Flutter — Comunidade BR. Idioma mantido: português.

## Situação editorial

Na primeira tentativa em 17/11/2026, a sessão estava desconectada e este documento foi preparado como referência técnica. Na continuação do trabalho, a conta do autor ficou acessível: o artigo original foi revisado e republicado pelo fluxo normal do Medium em 17/11/2026, preservando título, autoria, publicação e URL. A capa foi substituída, quatro capturas reais foram inseridas, todas as imagens receberam legendas e texto alternativo, e a aula ganhou explicações progressivas, checkpoints e exercícios. A versão didática final está em `docs/medium/article.pt-BR.html`; este arquivo conserva os trechos completos como referência técnica. Nenhuma newsletter foi enviada. O artigo de @nitishk72 não foi alterado.

## Aplicação ao artigo existente

Preserve o título “Consultando CEPs com Flutter”, o subtítulo “Notas de aula do prof. Kleber de Oliveira Andrade”, a introdução conceitual sobre CEP, os créditos e as referências didáticas. Os trechos de implementação e embeds antigos foram substituídos na publicação pela versão didática. A captura real em `docs/screenshots/web-address.jpg` foi incluída após a validação do navegador. Os blocos de código deste documento são extraídos dos arquivos finais do projeto; não use os antigos exemplos com `RaisedButton`, `http.get(String)` ou campos não inicializados.

## Texto de atualização para inserir após a introdução

Esta aula acompanha o aplicativo 2.0.1+3, com Flutter 3.50.0 e Dart 3.14.0, com null safety e Material 3. Vamos consultar o ViaCEP sem chave de API, validar o CEP antes da requisição e apresentar um endereço legível. Também vamos tratar conexão indisponível, timeout, CEP inexistente e respostas inválidas. A consulta é enviada ao ViaCEP; o aplicativo não salva histórico nem endereços no dispositivo.

## Criando e executando o projeto

Para acompanhar exatamente esta versão da aula, clone o repositório. Não basta colar o código atualizado em um projeto antigo com Gradle e dependências de 2019.

```sh
git clone https://github.com/kleberandrade/search-cep-aulas-flutter.git
cd search-cep-aulas-flutter
flutter --version
flutter pub get
flutter run -d chrome
```

A versão verificada é Flutter 3.50.0 com Dart 3.14.0. Para experimentar o exemplo local, sem fazer consultas externas, execute:

```sh
flutter run -d chrome --dart-define=DEMO=true
```

O modo de demonstração é identificado na tela e contém somente o endereço de São Paulo, CEP 01001-000. Outros CEPs mostram a mensagem de endereço não encontrado nesse modo. Para consultar qualquer CEP no ViaCEP, execute sem `DEMO=true`.

## Estrutura do projeto

O domínio contém `Cep`, responsável por validar oito dígitos ASCII e preservar zeros à esquerda. `ResultCep` representa um endereço imutável. `AddressLookup` define a consulta, com implementações real e de demonstração. `SearchController` representa os estados de tela e invalida respostas de pesquisas anteriores. `HomePage` cuida de apresentação e interação; `main.dart` cria e encerra o cliente HTTP e o controlador.

```text
lib/
  domain/cep.dart
  models/result_cep.dart
  services/via_cep_service.dart
  services/demo_cep_service.dart
  state/search_controller.dart
  views/home_page.dart
  main.dart
assets/sao_paulo.json
test/
tool/smoke.dart
```

## API do ViaCEP: corrigindo o exemplo

Use HTTPS e mantenha o CEP da URL coerente com o retorno. O artigo antigo exibia 13469111 no rótulo do link, mas apontava para 01001000. Nesta versão usamos https://viacep.com.br/ws/01001000/json/ e o exemplo de São Paulo. Um CEP sintaticamente válido pode não existir: o ViaCEP sinaliza isso com `erro: true`. HTTP 200 sozinho não garante endereço válido. Campos como logradouro e bairro podem estar vazios, sobretudo em CEPs de município, e a tela informa quando não foram fornecidos.

## Dependências e código completo atualizado

Substitua os embeds correspondentes às seções Dependências, Classe ResultCep, Classe ViaCepService, Classe Principal e Classe HomePage pelos respectivos arquivos abaixo. As seções de Cep e SearchController são novas. A classe de modelo converte dados em memória; não existe persistência neste exemplo. No Flutter 3.50, a interface importa `package:material_ui/material_ui.dart`; os delegates de localização vêm desse pacote. A biblioteca `http` recebe um `Uri` e um cliente injetável, que é fechado pelo proprietário da aplicação.

### `pubspec.yaml`

```yaml
name: search_cep
description: Accessible Brazilian postal code lookup with Flutter and ViaCEP.
publish_to: none
version: 2.0.1+3
environment:
  sdk: '>=3.14.0 <4.0.0'
  flutter: '>=3.50.0'
dependencies:
  flutter:
    sdk: flutter
  http: ^1.6.0
  material_ui: ^1.11.1
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
# Exact compatibility overrides validated with Flutter 3.50.0 / Dart 3.14.0.
# Re-test and remove when the official SDK constraints allow these versions.
dependency_overrides:
  material_color_utilities: 0.13.1
  test_api: 0.7.15
flutter:
  uses-material-design: true
  assets:
    - assets/sao_paulo.json
```

### `lib/domain/cep.dart`

```dart
/// Brazilian postal code: eight ASCII digits; leading zeros are significant.
final class Cep {
  const Cep._(this.digits);
  final String digits;

  factory Cep.parse(String input) {
    final value = input.trim();
    if (!RegExp(r'^[0-9]{5}-?[0-9]{3}$').hasMatch(value)) {
      throw const FormatException('Informe um CEP com 8 dígitos.');
    }
    return Cep._(value.replaceAll('-', ''));
  }

  String get formatted => '${digits.substring(0, 5)}-${digits.substring(5)}';
}
```

### `lib/models/result_cep.dart`

```dart
import 'dart:convert';

import '../domain/cep.dart';

/// Immutable validated response. Empty optional fields are legitimate in ViaCEP.
final class ResultCep {
  ResultCep._(this._fields);
  final Map<String, String> _fields;

  factory ResultCep.fromJson(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected an address object');
    }
    return ResultCep.fromMap(value);
  }

  factory ResultCep.fromMap(Map<String, dynamic> map) {
    final fields = <String, String>{};
    for (final key in [
      'cep',
      'logradouro',
      'complemento',
      'bairro',
      'localidade',
      'uf',
      'unidade',
      'ibge',
      'gia',
      'ddd',
      'siafi',
      'estado',
      'regiao',
    ]) {
      final value = map[key];
      if (value != null && value is! String) {
        throw FormatException('Invalid $key');
      }
      fields[key] = (value as String? ?? '').trim();
    }
    fields['cep'] = Cep.parse(fields['cep']!).formatted;
    if (fields['localidade']!.isEmpty ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(fields['uf']!)) {
      throw const FormatException('Missing city or state');
    }
    return ResultCep._(Map.unmodifiable(fields));
  }

  String get cep => _fields['cep']!;
  String get logradouro => _fields['logradouro']!;
  String get complemento => _fields['complemento']!;
  String get bairro => _fields['bairro']!;
  String get localidade => _fields['localidade']!;
  String get uf => _fields['uf']!;
  String get ibge => _fields['ibge']!;
  String get ddd => _fields['ddd']!;
  Map<String, String> toMap() => Map.of(_fields);
  String toJson() => jsonEncode(_fields);
}
```

### `lib/services/via_cep_service.dart`

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/cep.dart';
import '../models/result_cep.dart';

enum FailureKind { notFound, unavailable, invalidResponse, timeout, network }

final class LookupFailure implements Exception {
  const LookupFailure(this.kind);
  final FailureKind kind;
  String get message => switch (kind) {
    FailureKind.notFound =>
      'CEP não encontrado. Confira os números e tente outro CEP.',
    FailureKind.unavailable =>
      'O ViaCEP está indisponível. Tente novamente em instantes.',
    FailureKind.invalidResponse =>
      'O serviço retornou uma resposta inválida. Tente novamente.',
    FailureKind.timeout => 'A consulta demorou demais. Tente novamente.',
    FailureKind.network =>
      'Não foi possível conectar. Verifique sua conexão e tente novamente.',
  };
}

abstract interface class AddressLookup {
  Future<ResultCep> lookup(Cep cep);
}

class ViaCepService implements AddressLookup {
  ViaCepService(this.client, {this.timeout = const Duration(seconds: 10)});
  final http.Client client;
  final Duration timeout;

  @override
  Future<ResultCep> lookup(Cep cep) async {
    try {
      final response = await client
          .get(Uri.https('viacep.com.br', '/ws/${cep.digits}/json/'))
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw const LookupFailure(FailureKind.unavailable);
      }
      return _decode(utf8.decode(response.bodyBytes), cep);
    } on TimeoutException {
      throw const LookupFailure(FailureKind.timeout);
    } on http.ClientException {
      throw const LookupFailure(FailureKind.network);
    } on FormatException {
      throw const LookupFailure(FailureKind.invalidResponse);
    }
  }

  ResultCep _decode(String body, Cep requested) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    if (decoded['erro'] == true || decoded['erro'] == 'true') {
      throw const LookupFailure(FailureKind.notFound);
    }
    final address = ResultCep.fromMap(decoded);
    if (address.cep != requested.formatted) {
      throw const FormatException('Unexpected CEP');
    }
    return address;
  }
}
```

### `lib/services/demo_cep_service.dart`

```dart
import 'package:flutter/services.dart';

import '../domain/cep.dart';
import '../models/result_cep.dart';
import 'via_cep_service.dart';

/// Explicit offline classroom sample; never silently replaces live data.
final class DemoCepService implements AddressLookup {
  @override
  Future<ResultCep> lookup(Cep cep) async {
    if (cep.digits != '01001000') {
      throw const LookupFailure(FailureKind.notFound);
    }
    return ResultCep.fromJson(
      await rootBundle.loadString('assets/sao_paulo.json'),
    );
  }
}
```

### `lib/state/search_controller.dart`

```dart
import 'package:flutter/foundation.dart';

import '../domain/cep.dart';
import '../models/result_cep.dart';
import '../services/via_cep_service.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.address);
  final ResultCep address;
}

final class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;
}

/// Each edit/search invalidates older responses without blocking the input.
class SearchController extends ChangeNotifier {
  SearchController(this.service);
  final AddressLookup service;
  SearchState state = const SearchIdle();
  int _generation = 0;
  bool _disposed = false;

  void inputChanged() {
    _generation++;
    _emit(const SearchIdle());
  }

  Future<void> search(String input) async {
    final generation = ++_generation;
    try {
      final cep = Cep.parse(input);
      _emit(const SearchLoading());
      final address = await service.lookup(cep);
      if (generation == _generation) _emit(SearchSuccess(address));
    } on FormatException {
      if (generation == _generation) {
        _emit(
          const SearchError(
            'Informe um CEP com 8 dígitos. Exemplo: 01001-000.',
          ),
        );
      }
    } on LookupFailure catch (error) {
      if (generation == _generation) _emit(SearchError(error.message));
    }
  }

  void _emit(SearchState next) {
    if (_disposed) return;
    state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
```

### `lib/main.dart`

```dart
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
```

### `lib/views/home_page.dart`

```dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/result_cep.dart';
import '../state/search_controller.dart' as search;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});
  final search.SearchController controller;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _example(String cep) {
    _input.text = cep;
    widget.controller.search(cep);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.local_post_office_outlined,
                      color: Color(0xFF14695C),
                      size: 32,
                    ),
                    Text(
                      'consulta cep',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (const bool.fromEnvironment('DEMO'))
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'DEMONSTRAÇÃO LOCAL • Somente o exemplo de São Paulo',
                    ),
                  ),
                const SizedBox(height: 48),
                Text(
                  'DO CÓDIGO AO ENDEREÇO',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Encontre seu\npróximo endereço.',
                  style: TextStyle(
                    fontSize: 46,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uma consulta simples, um caminho mais curto.\nBusque endereços de todo o Brasil pelo CEP.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Color(0xFF4D5E58),
                  ),
                ),
                const SizedBox(height: 36),
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) => LayoutBuilder(
                    builder: (context, constraints) {
                      final form = _form();
                      final result = _result(widget.controller.state);
                      if (constraints.maxWidth < 760) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [form, const SizedBox(height: 20), result],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: form),
                          const SizedBox(width: 24),
                          Expanded(flex: 6, child: result),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  bool.fromEnvironment('DEMO')
                      ? 'Exemplo local • Nenhuma consulta externa é realizada neste modo.'
                      : 'Dados públicos do ViaCEP • Sem cadastro e sem chave de API\nAs consultas são enviadas ao ViaCEP. Nenhum histórico é salvo neste app.',
                  style: TextStyle(color: Color(0xFF4D5E58), height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _form() => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Qual CEP você procura?',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Digite 8 números, com ou sem hífen.'),
        const SizedBox(height: 24),
        TextField(
          controller: _input,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'CEP',
            hintText: '01001-000',
            suffixIcon: IconButton(
              tooltip: 'Limpar CEP',
              icon: const Icon(Icons.close),
              onPressed: () {
                _input.clear();
                widget.controller.inputChanged();
                _focus.requestFocus();
              },
            ),
          ),
          onChanged: (_) => widget.controller.inputChanged(),
          onSubmitted: widget.controller.search,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => widget.controller.search(_input.text),
          icon: const Icon(Icons.search),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Buscar endereço'),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'EXPERIMENTE UM CEP',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              label: const Text('São Paulo'),
              onPressed: () => _example('01001-000'),
            ),
            ActionChip(
              label: const Text('Belo Horizonte'),
              onPressed: () => _example('30140-071'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _result(search.SearchState state) => switch (state) {
    search.SearchSuccess(:final address) => _AddressPanel(address: address),
    search.SearchLoading() => const _StatusPanel(
      icon: Icons.travel_explore,
      title: 'Consultando o ViaCEP…',
      message: 'Você pode alterar o CEP enquanto espera.',
      loading: true,
    ),
    search.SearchError(:final message) => _StatusPanel(
      icon: Icons.info_outline,
      title: 'Vamos tentar de novo?',
      message: message,
      error: true,
    ),
    search.SearchIdle() => const _StatusPanel(
      icon: Icons.location_on_outlined,
      title: 'Seu próximo destino começa aqui',
      message: 'O endereço aparecerá aqui após a consulta.\nSe preferir, comece por um dos exemplos.',
    ),
  };
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFDAE2DC)),
    ),
    child: child,
  );
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.error = false,
  });
  final IconData icon;
  final String title, message;
  final bool loading, error;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: _Panel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 56,
              color: error
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.7, color: Color(0xFF4D5E58)),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    ),
  );
}

class _AddressPanel extends StatelessWidget {
  const _AddressPanel({required this.address});
  final ResultCep address;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    explicitChildNodes: true,
    child: _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ENDEREÇO ENCONTRADO',
            style: TextStyle(
              color: Color(0xFF14695C),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          SelectableText(
            address.cep,
            semanticsLabel: address.cep,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const Divider(height: 32),
          _field('Logradouro', address.logradouro),
          _field('Bairro', address.bairro),
          _field('Cidade / UF', '${address.localidade} / ${address.uf}'),
          if (address.complemento.isNotEmpty)
            _field('Complemento', address.complemento),
          Wrap(
            spacing: 24,
            children: [
              if (address.ddd.isNotEmpty) _field('DDD', address.ddd),
              if (address.ibge.isNotEmpty) _field('IBGE', address.ibge),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await Clipboard.setData(
                  ClipboardData(
                    text:
                        '${address.cep}\n${address.logradouro}\n${address.bairro}\n${address.localidade} / ${address.uf}',
                  ),
                );
                messenger.showSnackBar(
                  const SnackBar(content: Text('Endereço copiado.')),
                );
              } on PlatformException {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Não foi possível copiar. Selecione o texto do endereço.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copiar endereço'),
          ),
        ],
      ),
    ),
  );

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4D5E58)),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value.isEmpty ? 'Não informado pelo ViaCEP' : value,
          semanticsLabel: value.isEmpty ? 'Não informado pelo ViaCEP' : value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
```

### `assets/sao_paulo.json`

```json
{"cep":"01001-000","logradouro":"Praça da Sé","complemento":"lado ímpar","bairro":"Sé","localidade":"São Paulo","uf":"SP","unidade":"","ibge":"3550308","gia":"1004","ddd":"11","siafi":"7107"}
```

## Resultado e controles

Digite 01001-000 ou 01001000 e pressione Enter/Buscar endereço. Experimente também o atalho São Paulo. O retorno aparece em cartão com logradouro, bairro, cidade/UF, complemento, DDD e IBGE quando disponíveis. O botão Copiar endereço envia o texto à área de transferência; Limpar CEP remove o resultado e devolve o foco ao campo. A tela permite editar o CEP durante a consulta. A geração de cada busca evita que uma resposta atrasada substitua a busca mais recente. Ao usar Tab, o foco segue os controles nativos do Flutter. O layout usa duas colunas em telas largas e uma coluna com rolagem em telas estreitas.

## Testes e build

```sh
flutter analyze
flutter test --coverage
flutter build web
dart run tool/smoke.dart
```

Os testes de unidade usam fixtures locais e `MockClient`: resposta válida, CEP inexistente, HTTP inválido, JSON inválido, timeout, falha de conexão, entrada inválida e mudanças rápidas de busca. Os testes de widgets verificam estados e texto ampliado. O comando `tool/smoke.dart` é uma consulta de integração real e depende da rede/ViaCEP; ele não faz parte dos testes determinísticos. Não confunda fixture local com consulta real nem build sem assinatura com execução em telefone.

Para Android, é preciso configurar o SDK e aceitar pessoalmente as licenças necessárias. Não aceite termos automaticamente. Os identificadores originais de Android/iOS foram preservados. Nenhum armazenamento mudou, pois a versão anterior também não persistia dados. A API Dart interna mudou de `ViaCepService.fetchCep(cep: ...)` estático para uma instância que recebe `http.Client` e consulta um `Cep` validado.

## Overrides verificados

A versão 2.0.1+3 compartilha os overrides exatos material_color_utilities 0.13.1 e test_api 0.7.15 após o experimento passar em análise, 21 testes e builds Web/macOS release/iOS sem assinatura. Eles substituem as restrições do SDK; a compatibilidade observada vale para a combinação testada. Compare `flutter pub outdated` e `flutter pub outdated --no-dependency-overrides` e revalide a cada atualização. A versão didática publicada explica a manutenção e a remoção futura desses overrides.

## Cinco desafios finais

Alternância de temas. Adicione um controle para escolher tema claro, escuro ou do sistema com ThemeMode. Critério de entrega: a troca funciona por teclado, mantém o resultado visível e apresenta texto legível nos três modos.

Laboratório offline ampliado. Acrescente três fixtures, incluindo um endereço sem logradouro ou bairro, e permita escolher os exemplos no modo de demonstração. Critério de entrega: cada exemplo tem um teste que confere seus campos e a tela identifica claramente que são dados locais.

Histórico local com limpeza. Armazene os cinco últimos CEPs consultados com sucesso, sem duplicatas, e ofereça uma ação para apagar o histórico. Critério de entrega: os itens continuam disponíveis após reiniciar o app, a limpeza funciona e existe um teste de compatibilidade para uma mudança no formato salvo.

Cópia e compartilhamento completos. Inclua o complemento, quando houver, no texto copiado e implemente compartilhamento nas plataformas escolhidas. Critério de entrega: campos vazios não criam linhas desnecessárias, o conteúdo compartilhado corresponde ao endereço e o usuário recebe uma alternativa quando a ação não estiver disponível.

Busca automática sem respostas antigas. Consulte após 400 ms sem digitação, somente quando houver um CEP válido, preservando a geração de cada consulta. Critério de entrega: digitação rápida não dispara consultas incompletas e um teste com respostas fora de ordem prova que o resultado antigo não substitui o novo.
