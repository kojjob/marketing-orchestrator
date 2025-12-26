# Marketing Orchestrator (GrowthOS)

A B2B SaaS platform for marketing automation, powered by AI agents and a robust workflow engine.

## 🚀 Features

*   **Multi-Tenancy**: Built-in support for organizations, teams, and data isolation.
*   **Workflow Automation**: Visual workflow builder to trigger actions based on webhooks, schedules, or manual inputs.
*   **AI Agents**: Integrated AI agents (OpenAI) to perform tasks like lead qualification, copywriting, and data analysis.
*   **CRM**: Built-in Contact Relationship Management to store and update leads.
*   **Integrations**: Webhook ingestion for connecting with tools like Stripe, Typeform, etc.

## 🛠 Tech Stack

*   **Framework**: Phoenix (Elixir)
*   **Database**: PostgreSQL
*   **Frontend**: Phoenix LiveView + Tailwind CSS
*   **AI**: OpenAI API

## 🏁 Getting Started

### Prerequisites

*   Elixir 1.15+
*   PostgreSQL 14+
*   OpenAI API Key (optional, for real AI features)

### Local Development

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-org/marketing-orchestrator.git
    cd marketing-orchestrator
    ```

2.  **Setup dependencies and database:**
    ```bash
    mix setup
    ```

3.  **Start the server:**
    ```bash
    export OPENAI_API_KEY="your-key-here"
    mix phx.server
    ```

4.  **Visit:** `http://localhost:4000`

### Running Tests

```bash
mix test
```

## 🐳 Deployment

This project includes a `Dockerfile` for production deployment.

1.  **Build the image:**
    ```bash
    docker build -t growth_os .
    ```

2.  **Run container:**
    ```bash
    docker run -e DATABASE_URL=... -e SECRET_KEY_BASE=... -e OPENAI_API_KEY=... -p 4000:4000 growth_os
    ```

## 📖 Architecture

### Core Contexts

*   **Tenancy**: Handles Users, Tenants (Organizations), and Memberships.
*   **Crm**: Manages Contacts, Deals, and Companies.
*   **Automation**: The workflow engine (Workflows, Steps, Executions).
*   **Agents**: AI Agent profiles and execution logic.
*   **Integrations**: External connectivity (Webhooks, OpenAI).

### Workflow Engine

The engine follows a linear execution model:
1.  **Trigger**: An event (e.g., `webhook_received`) starts an execution.
2.  **Steps**: The engine iterates through defined steps.
3.  **Context**: Data is passed and transformed between steps.
4.  **Side Effects**: Steps can call AI agents or update the CRM.

## 🤝 Contributing

1.  Fork the repo
2.  Create a feature branch (`git checkout -b feature/amazing-feature`)
3.  Commit changes (`git commit -m 'Add amazing feature'`)
4.  Push to branch (`git push origin feature/amazing-feature`)
5.  Open a Pull Request
