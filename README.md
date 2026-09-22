# CineStream 🎬

Aplicativo mobile de descoberta de filmes, desenvolvido em Flutter, com visual inspirado em serviços de streaming (tema escuro, banner rotativo, carrosséis por categoria). Projeto criado com fins de aprendizado, cobrindo consumo de API REST, autenticação, banco de dados local e navegação entre múltiplas telas.

<!-- Adicione aqui os screenshots do app, por exemplo:
<p align="center">
  <img src="screenshots/login.png" width="220" />
  <img src="screenshots/home.png" width="220" />
  <img src="screenshots/detalhes.png" width="220" />
</p>
-->

## Funcionalidades

- **Login e cadastro** de usuários, com dados salvos localmente
- **Home** com banner rotativo automático (troca de filme em destaque a cada alguns segundos, com transição suave) e indicadores de posição
- **Carrosséis por categoria** (Em alta, Ação, Comédia, Terror, Romance, Drama, Animação), cada um com opção "Ver tudo" que abre a lista completa em grid
- **Busca** de filmes em tempo real
- **Tela de Detalhes** com sinopse, nota, elenco (fotos e personagens) e trailer (abre no app do YouTube)
- **Minha Lista** — favoritos salvos por usuário, cada conta com sua própria lista
- **Pull-to-refresh** na Home
- Ícone e splash screen personalizados

## Tecnologias

- **Flutter / Dart**
- **SQLite** via `sqflite` (usuários e favoritos, armazenados localmente no dispositivo)
- **API do TMDB** ([The Movie Database](https://www.themoviedb.org/)) — dados de filmes, elenco e trailers
- `http` — requisições à API
- `url_launcher` — abertura de trailers no YouTube

## Estrutura do projeto

```
lib/
├── main.dart
├── api_config.dart          # Não versionado — veja "Como configurar" abaixo
├── models/                  # Estruturas de dados (Filme, Ator)
├── services/                 # Comunicação com a API e o banco local
├── screens/                  # Telas completas do app
├── widgets/                  # Componentes reutilizáveis (cards, carrosséis)
└── theme/                    # Cores e estilo visual centralizados
```

## Como rodar o projeto

### Pré-requisitos

- [Flutter SDK](https://flutter.dev) instalado
- Um editor com suporte a Flutter (VS Code ou Android Studio)
- Um emulador Android/iOS configurado, ou um dispositivo físico

### Passos

1. Clone o repositório:
   ```
   git clone https://github.com/MychelLima/cine_stream.git
   cd cine_stream
   ```
2. Instale as dependências:
   ```
   flutter pub get
   ```
3. **Configure a chave da API do TMDB** (obrigatório — o app não funciona sem isso):
   - Crie uma conta gratuita em [themoviedb.org](https://www.themoviedb.org/) e gere uma **API Key (v3 auth)** em Configurações → API
   - Duplique o arquivo `lib/api_config.example.dart`, renomeie a cópia para `lib/api_config.dart`
   - Substitua `'SUA_CHAVE_AQUI'` pela sua chave real
4. Rode o app:
   ```
   flutter run
   ```

## Limitações conhecidas

Este é um projeto de estudo, e algumas simplificações foram feitas de propósito:

- **Dados armazenados apenas localmente** — não há sincronização entre dispositivos; reinstalar o app apaga os dados (usuários e favoritos)
- **Senha sem hash** — a senha é salva em texto puro no banco local, o que não seria aceitável em um app de produção
- **Uso não-comercial da API do TMDB** — conforme os Termos de Uso da TMDB, este projeto é estritamente educacional e não deve ser usado como base para um produto comercial sem um acordo de licenciamento próprio

## Roadmap / próximas ideias

- Filmes parecidos/recomendados na tela de Detalhes
- Skeleton loading e tela de "sem conexão"
- Migração dos dados locais para um backend com sincronização (Firebase/Supabase)

## Créditos

Este produto usa a API do TMDB, mas não é endorsado ou certificado pelo TMDB.

<p align="left">
  <img src="https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bafe5dcb6f8a62a4c6bc55cd9ba82bb2cd95f6c.svg" width="120" alt="TMDB Logo" />
</p>
