# 🎬 Cinema Management System

A desktop application for managing a cinema complex — ticket sales with an interactive seat map, movie and session management, financial reports, and auxiliary record lookups.

Built with **Java (Swing + FlatLaf)**, **JDBC**, and **PostgreSQL**, following a **three-layer architecture** (Presentation → Service → DAO).

> Course project — Database II, UDESC CCT.

---

## 📸 Features

- **Ticket Sales** — Interactive seat map: select seats, choose ticket type (full / half-price / promotional), payment method, and finalize the sale. Sold seats turn red in real time. Triggers in the database automatically calculate prices, apply promotions, generate QR codes, and update session status.
- **Movies** — Register new movies (title, duration, year, rating, director, distributor, genres) and view all registered movies.
- **Sessions** — Create screening sessions (date, time, format, language, base price, room, movie) and view all sessions.
- **Reports** — Revenue reports by movie (with distributor share), by room, and by date range.
- **Records Lookup** — Quick lookup of all auxiliary tables (employees, users, distributors, movies, rooms, complexes, genres, promotions) so you can easily find the codes needed in other forms.

---

## 🛠️ Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| **Java JDK** | 17 or higher | [Eclipse Adoptium](https://adoptium.net/) recommended |
| **PostgreSQL** | 12 or higher | [Download](https://www.postgresql.org/download/) |
| **pgAdmin 4** | any | Included with PostgreSQL installer |
| **NetBeans** | 17+ | [Download](https://netbeans.apache.org/) — comes with Maven built-in |

---

## 🚀 Setup & Run

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/cinema-management-system.git
cd cinema-management-system
```

### 2. Create the database (pgAdmin 4)

1. Open **pgAdmin 4** and connect to your PostgreSQL server.
2. Right-click **Databases** → **Create** → **Database**.
3. Name it `cinema` and click **Save**.

### 3. Run the SQL scripts (in order)

In pgAdmin, open the **Query Tool** (right-click the `cinema` database → **Query Tool**) and execute these files **one at a time, in this exact order**:

| Order | File | Description |
|-------|------|-------------|
| 1st | [`sql/trabalho_parte2_Kelwin_Uriel.sql`](sql/trabalho_parte2_Kelwin_Uriel.sql) | DDL — creates all tables, constraints, and indexes |
| 2nd | [`sql/trabalho_parte3_Kelwin_Uriel.sql`](sql/trabalho_parte3_Kelwin_Uriel.sql) | Functions & Triggers — validation, price calculation, reports |
| 3rd | [`sql/seed.sql`](sql/seed.sql) | Sample data — complex, rooms, seats, movies, sessions, users, etc. |

> **Tip:** In pgAdmin, click the 📂 folder icon in the Query Tool to open each `.sql` file, then click ▶️ **Execute** (or press `F5`).

### 4. Configure the database connection

The application connects using these defaults:

| Parameter | Default | Environment Variable |
|-----------|---------|---------------------|
| URL | `jdbc:postgresql://localhost:5432/cinema` | `DB_URL` |
| User | `postgres` | `DB_USER` |
| Password | `udesc` | `DB_PASS` |

If your PostgreSQL password is different, set the environment variable before running:

**Windows (PowerShell):**
```powershell
$env:DB_PASS = "your_password"
```

**Windows (CMD):**
```cmd
set DB_PASS=your_password
```

**Linux / macOS:**
```bash
export DB_PASS="your_password"
```

### 5. Build and run

**Option A — Command line (Maven):**

```bash
mvn compile exec:java
```

**Option B — NetBeans:**

1. **File** → **Open Project** → select the project folder.
2. NetBeans will detect the `pom.xml` and load it as a Maven project.
3. Right-click the project → **Run** (or press `F6`).

---

## 🏗️ Architecture

```
cinema/
├── src/main/java/cinema/
│   ├── Main.java                  # Entry point (FlatLaf L&F setup)
│   ├── ui/                        # Presentation layer (Swing)
│   │   ├── MainFrame.java         # Main window with tabbed pane
│   │   ├── PainelVenda.java       # Ticket sales + seat map
│   │   ├── PainelFilmes.java      # Movie registration & listing
│   │   ├── PainelSessoes.java     # Session registration & listing
│   │   ├── PainelRelatorios.java  # Revenue reports
│   │   ├── PainelCadastros.java   # Auxiliary records lookup
│   │   └── Ui.java                # UI utilities (table filling, error dialogs)
│   ├── service/                   # Business logic layer
│   │   ├── FilmeService.java
│   │   ├── SessaoService.java
│   │   ├── VendaService.java
│   │   ├── RelatorioService.java
│   │   └── NegocioException.java
│   ├── dao/                       # Data access layer (JDBC)
│   │   ├── ConexaoDB.java         # Connection factory (env-configurable)
│   │   ├── Consulta.java          # Generic SELECT executor
│   │   ├── FilmeDAO.java
│   │   ├── SessaoDAO.java
│   │   └── VendaDAO.java
│   └── model/                     # Data transfer objects
│       └── Modelo.java            # Records: Filme, Poltrona, ResultadoVenda, Tabela
├── sql/
│   ├── trabalho_parte2_*.sql      # DDL (tables)
│   ├── trabalho_parte3_*.sql      # Functions & triggers
│   └── seed.sql                   # Sample data
└── pom.xml                        # Maven config (Java 17, PostgreSQL driver, FlatLaf)
```

### Three-Layer Design

```
┌──────────────────────────────────────────────┐
│  Presentation (cinema.ui)                    │
│  Swing panels + FlatLaf Look & Feel          │
├──────────────────────────────────────────────┤
│  Service (cinema.service)                    │
│  Business rules, input validation,           │
│  exception translation                       │
├──────────────────────────────────────────────┤
│  Data Access (cinema.dao)                    │
│  JDBC queries, transactions, connection mgmt │
├──────────────────────────────────────────────┤
│  PostgreSQL                                  │
│  13 triggers, 3 report functions, constraints│
└──────────────────────────────────────────────┘
```

---

## 📋 Database Highlights

The PostgreSQL backend includes **13 triggers** and **3 report functions**:

| # | Trigger / Function | Purpose |
|---|---|---|
| 1 | `valida_sessao` | Prevents overlapping sessions in the same room |
| 2 | `valida_ingresso` | Validates seat ownership, session status, promotions |
| 3 | `valida_promocao` | Validates promotion dates and discount values |
| 4 | `calcula_valor_ingresso` | Auto-calculates ticket price (half-price + promotions) |
| 5 | `atualiza_total_venda` | Keeps sale total in sync with its tickets |
| 6 | `atualiza_status_sessao` | Sets session to SOLD OUT when all seats are taken |
| 7 | `gera_cod_confirmacao` | Generates unique confirmation codes (VND-XXXXXXXX) |
| 8 | `criptografa_senha` | Hashes user passwords with MD5 |
| 9 | `valida_item_vendido` | Prevents selling unavailable food items |
| 10 | `atualiza_total_alimento` | Keeps food sale totals updated |
| 11 | `impede_alteracao_preco` | Blocks price changes on items already sold |
| 12 | `valida_poltrona` | Ensures seats fit within the room layout |
| 13 | `atualiza_capacidade_sala` | Keeps room capacity in sync with seat count |
| 14 | `atualiza_numero_salas` | Keeps complex room count updated |
| R1 | `faturamento_por_filme()` | Revenue by movie with distributor share |
| R2 | `faturamento_por_sala()` | Revenue by room |
| R3 | `faturamento_por_periodo()` | Daily revenue for a date range |

---

## 📄 License

This project was developed for academic purposes (Database II — UDESC CCT).
