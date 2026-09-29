# 🚀 SoundDesk Mobile API — Roadmap

API responsável pelas integrações externas e processamento online do **SoundDesk Mobile**.

A aplicação mobile será **local-first**, mantendo biblioteca, playlists, arquivos e reprodução no dispositivo. A API hospedada será utilizada principalmente para funcionalidades que dependem de serviços externos, como Spotify, YouTube, busca, importação e matching.

---

## 🏗️ Arquitetura

```text
                         INTERNET
                            │
              ┌─────────────┴─────────────┐
              │                           │
          Spotify                     YouTube
              │                           │
              └─────────────┬─────────────┘
                            │
                       ┌────▼─────┐
                       │ FastAPI  │
                       │  Cloud   │
                       └────┬─────┘
                            │
                   metadata / URLs
                            │
                     ┌──────▼──────┐
                     │   Flutter   │
                     │             │
                     │  SQLite     │
                     │  Filesystem │
                     │  Downloader │
                     │  FFmpeg     │
                     │  Player     │
                     └─────────────┘
```

### Responsabilidades

| Responsabilidade   | Local               |
| ------------------ | ------------------- |
| Playlists          | 📱 Flutter + SQLite |
| Biblioteca         | 📱 Flutter + SQLite |
| Músicas            | 📱 Filesystem       |
| Capas              | 📱 Filesystem       |
| Player             | 📱 Flutter          |
| Downloads          | 📱 Flutter          |
| Progresso          | 📱 Flutter          |
| Importação Spotify | ☁️ FastAPI          |
| Importação YouTube | ☁️ FastAPI          |
| Matching           | ☁️ FastAPI          |
| Busca externa      | ☁️ FastAPI          |
| Metadados externos | ☁️ FastAPI          |
| PostgreSQL         | ❌ Inicialmente      |
| Redis              | ❌ Inicialmente      |
| Celery             | ❌ Inicialmente      |
| Storage de músicas | ❌ Inicialmente      |

---

# 📌 Fase 1 — Fundação

* [ ] Criar estrutura FastAPI
* [ ] Configurar `pyproject.toml`
* [ ] Configurar `.env` / Settings
* [ ] Configurar CORS
* [ ] Configurar tratamento global de exceções
* [ ] Configurar logging
* [ ] Criar endpoint `/health`
* [ ] Configurar Swagger/OpenAPI
* [ ] Criar Dockerfile
* [ ] Criar README da API

### Estrutura inicial

```text
apps/api/
├── app/
│   ├── core/
│   │   ├── config.py
│   │   ├── exceptions.py
│   │   └── logging.py
│   │
│   ├── health/
│   │   └── router.py
│   │
│   └── main.py
│
├── tests/
├── Dockerfile
├── pyproject.toml
└── README.md
```

---

# 📌 Fase 2 — Providers

Criar uma arquitetura para integração com diferentes provedores externos.

```text
providers/
├── base.py
├── factory.py
├── youtube.py
└── spotify.py
```

Criar uma interface comum:

```text
ImportProvider
├── validate_url()
├── extract_playlist()
└── extract_track()
```

## YouTube

* [ ] Validar URLs
* [ ] Extrair vídeo
* [ ] Extrair playlist
* [ ] Extrair título
* [ ] Extrair artista/canal
* [ ] Extrair duração
* [ ] Extrair thumbnail
* [ ] Obter informações necessárias para download

## Spotify

* [ ] Configurar Spotify Client Credentials
* [ ] Validar URLs
* [ ] Resolver `spotify.link`
* [ ] Extrair playlist
* [ ] Implementar paginação
* [ ] Extrair título
* [ ] Extrair artistas
* [ ] Extrair duração
* [ ] Extrair capa
* [ ] Extrair IDs

---

# 📌 Fase 3 — Importação

Criar o módulo responsável por transformar uma URL externa em dados que o Flutter consiga armazenar localmente.

### Endpoint

```http
POST /imports/playlist
```

### Request

```json
{
  "url": "https://open.spotify.com/playlist/..."
}
```

### Response

```json
{
  "name": "Minha Playlist",
  "description": "...",
  "cover_url": "...",
  "tracks": [
    {
      "title": "Song",
      "artist": "Artist",
      "duration": 213,
      "thumbnail_url": "...",
      "source_url": "..."
    }
  ]
}
```

### Implementação

* [ ] `ImportService`
* [ ] `ImportProviderFactory`
* [ ] Schemas
* [ ] Validação de URL
* [ ] Tratamento de erros
* [ ] Importação de playlist
* [ ] Importação de música individual

---

# 📌 Fase 4 — Matching

Responsável por encontrar uma fonte correspondente para músicas importadas de outros serviços.

### Fluxo

```text
Spotify
   ↓
"Artist - Song"
   ↓
YouTube Search
   ↓
Candidate
   ↓
Matching
   ↓
YouTube URL
```

### Estrutura

```text
matching/
├── service.py
├── schemas.py
└── strategies/
```

### Implementação inicial

* [ ] Busca no YouTube
* [ ] Matching por título + artista
* [ ] Normalização de títulos
* [ ] Remoção de informações irrelevantes
* [ ] Retornar melhor candidato
* [ ] Indicar quando não encontrar correspondência

### Melhorias futuras

* [ ] Score de similaridade
* [ ] Duração como critério
* [ ] Artista como critério
* [ ] Penalizar versões live/remix quando não correspondentes
* [ ] Estratégia de matching configurável

---

# 📌 Fase 5 — Search

Criar busca externa para o aplicativo.

### Endpoint

```http
GET /search?q=...
```

### Response

```json
{
  "results": [
    {
      "title": "Song",
      "artist": "Artist",
      "duration": 213,
      "thumbnail_url": "...",
      "source_url": "..."
    }
  ]
}
```

### Implementação

* [ ] Busca no YouTube
* [ ] Limite de resultados
* [ ] Normalização da resposta
* [ ] Tratamento de erros

### Futuro

* [ ] Busca no Spotify
* [ ] Múltiplos providers
* [ ] Busca unificada

---

# 📌 Fase 6 — Metadata

Criar endpoints para obter informações detalhadas de uma música.

### Exemplo

```http
GET /metadata/youtube/{video_id}
```

### Response

```json
{
  "title": "Song",
  "artist": "Artist",
  "duration": 213,
  "thumbnail_url": "...",
  "source_url": "https://youtube.com/..."
}
```

### Implementação

* [ ] Metadata do YouTube
* [ ] Título
* [ ] Artista
* [ ] Duração
* [ ] Thumbnail
* [ ] URL de origem
* [ ] Tratamento de vídeos indisponíveis

---

# 📌 Fase 7 — Download

O download deve acontecer **preferencialmente no dispositivo**, e não no servidor.

### Fluxo

```text
Flutter
   │
   │ solicita/obtém source
   ▼
FastAPI
   │
   ▼
YouTube
   │
   ▼
informações necessárias
   │
   ▼
Flutter
   │
   ▼
Download local
```

A API poderá fornecer:

* URL;
* metadados;
* informações de formato;
* thumbnail;
* duração.

### Não implementar inicialmente

* [ ] Storage de MP3 no servidor
* [ ] S3
* [ ] PostgreSQL para biblioteca
* [ ] Redis
* [ ] Celery
* [ ] Fila de downloads no servidor

O objetivo é que o arquivo final fique no dispositivo do usuário.

---

# 📌 Fase 8 — Integração com Flutter

Conectar os endpoints da API ao aplicativo mobile.

### Arquitetura no Flutter

```text
Flutter
   ↓
ApiClient
   ↓
Repositories
   ↓
Services
   ↓
Controllers
   ↓
UI
```

### Implementação

* [ ] Cliente HTTP
* [ ] Configuração da URL da API
* [ ] Modelos de response
* [ ] Repository de importação
* [ ] Repository de busca
* [ ] Repository de metadata
* [ ] Integração com matching
* [ ] Tratamento de erros da API
* [ ] Estados de loading/error/success

---

# 📌 Fase 9 — Segurança

Mesmo sendo uma API sem autenticação inicialmente, ela será hospedada e precisa possuir mecanismos básicos de proteção.

* [ ] Rate limiting
* [ ] Limites de tamanho de request
* [ ] Validação rigorosa de URLs
* [ ] Timeouts para requests externos
* [ ] Tratamento de erros dos providers
* [ ] Não expor secrets
* [ ] Configuração adequada de CORS
* [ ] Limitar quantidade de resultados
* [ ] Proteção contra abuso dos endpoints de busca
* [ ] Proteção contra abuso dos endpoints de importação
* [ ] Proteção contra abuso do matching

Endpoints como:

```text
/search
/imports
/matching
```

podem gerar chamadas externas e consumir recursos, portanto devem possuir limites adequados.

---

# 📌 Fase 10 — Cache

Adicionar cache somente caso exista necessidade real.

Possíveis recursos para cache:

```text
YouTube Search
Spotify Metadata
Matching
```

### Exemplo

```text
Mesma música
      ↓
Já fizemos matching?
      ↓
   ┌──┴──┐
  SIM    NÃO
   ↓      ↓
Cache   Pesquisa
```

Se houver necessidade de cache distribuído:

* [ ] Avaliar Redis
* [ ] Definir TTL
* [ ] Definir estratégia de invalidação

> Redis não deve ser adicionado apenas por conveniência. Só utilizar quando houver uma necessidade concreta.

---

# 📌 Fase 11 — Deploy

Preparar a API para produção.

* [ ] Dockerizar aplicação
* [ ] Configurar variáveis de ambiente
* [ ] Health check
* [ ] Logs de produção
* [ ] Deploy
* [ ] HTTPS
* [ ] Domínio/subdomínio
* [ ] Configurar CORS de produção
* [ ] Monitoramento básico
* [ ] Verificar limites de recursos

### Arquitetura

```text
Flutter
   │
   │ HTTPS
   ▼
┌──────────────────┐
│  SoundDesk API   │
│     FastAPI      │
└────────┬─────────┘
         │
    ┌────┴─────┐
    ▼          ▼
 Spotify     YouTube
```

---

# 📌 Fase 12 — Testes e CI

Após os módulos principais estarem funcionando:

## Testes

* [ ] Testes dos providers
* [ ] Testes de importação
* [ ] Testes de matching
* [ ] Testes dos schemas
* [ ] Testes dos endpoints
* [ ] Testes de integração
* [ ] Testes de tratamento de erros

## CI

* [ ] Configurar GitHub Actions
* [ ] Lint
* [ ] Type checking
* [ ] Testes
* [ ] Build da aplicação
* [ ] Verificação do Docker

---

# 🎯 MVP da API

A primeira versão da API pode ser considerada funcional quando possuir:

```text
GET  /health

GET  /search

GET  /metadata/...

POST /imports/playlist

POST /matching
```

Com suporte a:

```text
YouTube
Spotify
Matching
```

e **sem necessidade de banco de dados**.

---

# 🗺️ Ordem de Implementação

A ordem recomendada para desenvolvimento é:

```text
01. Fundação
      ↓
02. YouTube Provider
      ↓
03. Search
      ↓
04. Metadata
      ↓
05. Matching
      ↓
06. Spotify Provider
      ↓
07. Import Playlist
      ↓
08. Integração com Flutter
      ↓
09. Download
      ↓
10. Segurança / Rate Limit
      ↓
11. Deploy
      ↓
12. Testes + CI
```

---

# 🧠 Princípio Arquitetural

O SoundDesk Mobile deve manter uma separação clara entre **responsabilidades locais e remotas**.

### 📱 Dispositivo

Responsável por:

* biblioteca;
* playlists;
* SQLite;
* arquivos;
* player;
* downloads;
* capas;
* progresso;
* funcionamento offline.

### ☁️ API

Responsável por:

* integrações externas;
* Spotify;
* YouTube;
* importação;
* busca;
* matching;
* metadata;
* processamento que dependa de serviços externos.

> **O servidor não deve ser o responsável pela biblioteca do usuário.**

Depois que uma música estiver armazenada no dispositivo, o usuário deve conseguir reproduzi-la e gerenciá-la sem depender da API.
