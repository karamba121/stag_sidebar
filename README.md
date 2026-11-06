# stag_sidebar

Uma sidebar Flutter inspirada no design de referência: tema escuro, grupos de navegação, item selecionado em destaque e modos expandido e compacto.

## Instalação

Adicione ao `pubspec.yaml` do seu projeto:

```yaml
dependencies:
  stag_sidebar: ^0.2.0
```

## Uso

```dart
import 'package:flutter/material.dart';
import 'package:stag_sidebar/stag_sidebar.dart';

StagSidebar(
  selectedId: selectedId,
  onItemSelected: (id) => setState(() => selectedId = id),
  logo: const Icon(Icons.bolt, color: Color(0xFF52C9D7)),
  title: 'Minha marca',
  sections: [
    StagSidebarSection(items: [
      StagSidebarItem(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard),
      StagSidebarItem(id: 'wallet', label: 'Carteira', icon: Icons.account_balance_wallet),
    ]),
  ],
  actions: [
    StagSidebarAction(
      label: 'Comunidade',
      icon: Icons.people,
      onPressed: () => debugPrint('Comunidade'),
    ),
  ],
)
```

Personalize as cores, tipografia, espaçamentos, dimensões, cantos, gradiente ativo e animação com `StagSidebarStyle`. Cada grupo pode receber sua própria cor de fundo e espaçamento; cada item pode sobrescrever seu gradiente ou cor selecionada. `initiallyCollapsed` define o estado inicial e `onCollapsedChanged` informa quando a pessoa alterna o modo compacto. No modo compacto, os atalhos aparecem em uma faixa horizontal ao passar o mouse ou tocar no botão de ações. Em telas estreitas ou com muitos atalhos, a faixa permite rolagem horizontal.

## Tema claro

Use `StagSidebarStyle.light()` para aplicar a paleta clara. Assim como no estilo padrão, todas as propriedades podem ser personalizadas:

```dart
StagSidebar(
  style: const StagSidebarStyle.light(
    accentColor: Colors.teal,
    borderRadius: 16,
  ),
  sections: const [], // Adicione seus itens de navegação.
)
```

Para alternar os temas, atualize `style` para `const StagSidebarStyle.light()` ou `const StagSidebarStyle()` no estado do seu aplicativo. O exemplo incluído demonstra essa troca.

A transição respeita a preferência do sistema por movimento reduzido. A sidebar usa a altura disponível e permite rolagem quando o conteúdo não cabe; forneça largura suficiente para `expandedWidth` e `collapsedWidth` no layout que a contém. Em celulares, `initiallyCollapsed: true` inicia a sidebar no modo compacto, se desejado.

## Submenus

Um item com `children` abre ou fecha seus subitens ao ser acionado, tanto no modo expandido quanto no compacto:

```dart
StagSidebarItem(
  id: 'swap',
  label: 'Swap',
  icon: Icons.swap_horiz,
  children: [
    StagSidebarItem(id: 'add', label: 'Add Liquidity', icon: Icons.add_circle_outline),
    StagSidebarItem(id: 'manage', label: 'Manage Liquidity', icon: Icons.tune),
  ],
)
```

Use IDs únicos em toda a sidebar. Itens com filhos alternam o submenu e executam seu `onTap`, se fornecido; a seleção pelo `onItemSelected` ocorre nos itens sem filhos. `initiallyExpanded` abre um grupo inicialmente. A cor do grupo pode ser ajustada por `submenuBackgroundColor` no item ou em `StagSidebarStyle`; o espaçamento e a duração usam `submenuPadding` e `animationDuration` do estilo.

## Prévia local

O projeto `example` mostra o componente com itens, grupos e ações inspirados na referência. Para abrir no Chrome:

```bash
cd example
flutter run -d chrome
```
