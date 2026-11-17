# Brazilian Postal Code Lookup

[![Language: Dart](https://img.shields.io/badge/Language-Dart-0175C2)](https://github.com/kleberandrade/search-cep-aulas-flutter/blob/master/pubspec.yaml)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter-02569B)](https://github.com/kleberandrade/search-cep-aulas-flutter/blob/master/pubspec.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-555555)](https://github.com/kleberandrade/search-cep-aulas-flutter/blob/master/LICENSE)

Flutter classroom app for looking up Brazilian postal codes with the ViaCEP API.

## Getting started

- Select a Flutter release whose bundled Dart SDK satisfies the manifest constraint, then run the commands below from the repository root.

```sh
flutter pub get
flutter run
```

- If the app depends on Firebase or another external service, configure your own service project using the dependencies and original notes; credentials are not supplied by this guide.

## Recorded requirements

- Dart SDK constraint from [`pubspec.yaml`](https://github.com/kleberandrade/search-cep-aulas-flutter/blob/master/pubspec.yaml): `>=2.1.0 <3.0.0`.

## Repository map

- [lib](https://github.com/kleberandrade/search-cep-aulas-flutter/tree/master/lib)
- [android](https://github.com/kleberandrade/search-cep-aulas-flutter/tree/master/android)
- [ios](https://github.com/kleberandrade/search-cep-aulas-flutter/tree/master/ios)

## Validation status

This update documents the tracked source and project metadata. It does not certify a successful build, device test or compatibility with a current toolchain. Follow any project-specific validation instructions in the original material.

## License and attribution

See [LICENSE](https://github.com/kleberandrade/search-cep-aulas-flutter/blob/master/LICENSE) and any notices accompanying third-party code and assets. This documentation update does not change licensing or authorship.

---

## Original project material

# Consulta de CEP

Aplicativo para consultar CEP através da API do VIA CEP

Tutorial de criação deste app: http://bit.ly/2kcGFQh

<p align="center">
    <img src="https://miro.medium.com/max/1440/1*St_MBopTzlcfQzasVw1-GA.png" width="800"/>
</p>

## Como clonar e importar

-   Faça um fork do projeto
-   Abra o terminal do Visual Studio Code
-   Digite (troque kleberandrade pelo nome do seu usuários): git clone https://github.com/kleberandrade/search-cep-aulas-flutter search_cep

## Desafios

-   Criar e usar temas Light e Dart (para saber mais sobre temas [clique aqui](https://flutter.dev/docs/cookbook/design/themes), e se você quiser usar um editor de temas [clique aqui](https://rxlabz.github.io/panache/#/))
-   Criar um IconButton na AppBar para alternar entre os temas (dica: use o [plugin dynamic_theme](https://pub.dev/packages/dynamic_theme))
-   Criar um formulário para adicionar todas os campos do JSON ([formulários](https://flutter.dev/docs/cookbook/forms))
-   Validar o campo de digitação de CEP ([validações em flutter](https://medium.com/@nitishk72/form-validation-in-flutter-d762fbc9212c))
-   Tratar todas [exceções](https://www.youtube.com/watch?v=qAzxZJ8NRwI) e utilize [Flushbar](https://pub.dev/packages/flushbar) para exibir os erros para o usuário
-   Adicionar um IconButton na AppBar para compartilhar o CEP (utilize o [plugin share](https://pub.dev/packages/share))

## Licença

    Copyright 2019 Kleber de Oliveira Andrade
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
