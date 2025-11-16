# TODO List API - DDD

API REST para gerenciamento de TODOs com sistema de dependências, construída com **Domain-Driven Design (DDD)**.

## :dart: Sobre

Sistema de tarefas com:
- CRUD completo de TODOs
- Dependências entre tarefas
- Validação de dependências circulares
- Atualização em cascata de datas
- Arquitetura DDD (Domain, Application, Infrastructure, Presentation)

---

## :package: Tecnologias/Requisitos

- Ruby 2.7.8
- Rails 6.1
- PostgreSQL

---

## :rocket: Como Rodar

### 1. Instalar dependências

```bash
bundle install
```

### 2. Configurar banco de dados

**⚠️ Importante:** Configure as variáveis de banco no arquivo `.env`

```bash
rails db:create
rails db:migrate
```

### 3. Iniciar servidor

```bash
rails server
```

Servidor disponível em: **http://localhost:3000**

### 4. Rodar testes

```bash
rspec
```

---

## :world_map: Rotas da API

**Base URL:** `http://localhost:3000/api/v1`

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| **GET** | `/todo_items` | Lista todos os TODOs |
| **GET** | `/todo_items/:id` | Busca TODO por ID |
| **POST** | `/todo_items` | Cria novo TODO |
| **PUT/PATCH** | `/todo_items/:id` | Atualiza TODO |
| **DELETE** | `/todo_items/:id` | Deleta TODO |

### Ver rotas completas

```bash
rails routes -c todo_items
```

---

## :book: Exemplos de Uso

### Criar TODO

```bash
curl -X POST http://localhost:3000/api/v1/todo_items \
  -H "Content-Type: application/json" \
  -d '{
    "todo_item": {
      "title": "Implementar feature",
      "due_date": "2025-12-01",
      "completed": false
    }
  }'
```

### Criar TODO com dependências

```bash
curl -X POST http://localhost:3000/api/v1/todo_items \
  -H "Content-Type: application/json" \
  -d '{
    "todo_item": {
      "title": "Deploy",
      "due_date": "2025-12-10",
      "dependency_ids": [1, 2]
    }
  }'
```

### Listar TODOs

```bash
curl -X GET http://localhost:3000/api/v1/todo_items \
  -H "Content-Type: application/json"
```

### Atualizar TODO

```bash
curl -X PUT http://localhost:3000/api/v1/todo_items/1 \
  -H "Content-Type: application/json" \
  -d '{"todo_item": {"completed": true}}'
```

### Deletar TODO

```bash
curl -X DELETE http://localhost:3000/api/v1/todo_items/1 \
  -H "Content-Type: application/json"
```

---

## :clipboard: Regras de Negócio

- `title` e `due_date` são obrigatórios
- `due_date` deve ser **posterior** à data das dependências
- Não pode haver **dependência circular**
- Ao atualizar `due_date`, todos os dependents são atualizados em cascata
- Ao deletar TODO, os links de dependência são removidos automaticamente

---

## :toolbox: Testar com Insomnia

Importe `insomnia_collection.yaml` no Insomnia:

1. **Application** → **Preferences** → **Data**
2. **Import Data** → **From File**
3. Selecione `insomnia_collection.yaml`

---

## :bar_chart: Cobertura de Testes

Este projeto utiliza [SimpleCov](https://github.com/simplecov-ruby/simplecov) para medir a cobertura dos testes automatizados.

Após rodar os testes com RSpec, um relatório de cobertura é gerado em `coverage/index.html`.

Para visualizar:

```bash
bundle exec rspec
open coverage/index.html
```

O arquivo HTML mostra o percentual de cobertura por arquivo e linha.

---

## :building_construction: Arquitetura

Projeto organizado em camadas DDD:

```
app/contexts/todos/
├── presentation/      # Serializers
├── application/       # Services (casos de uso)
├── domain/            # Entities, Repositories, Specifications
└── infrastructure/    # ActiveRecord, Repositories
