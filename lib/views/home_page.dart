import 'package:flutter/material.dart';
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
      message:
          'O endereço aparecerá aqui após a consulta.\nSe preferir, comece por um dos exemplos.',
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
