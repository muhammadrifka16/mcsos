# M0 Dependency Graph

```mermaid
graph TD;
    A[Install WSL2] --> B[Install Linux Packages];
    B --> C[Create Repository];
    C --> D[Create Directory Structure];
    D --> E[Create tools/check_env.sh];
    E --> F[Run Smoke Test];
    F --> G[Create Makefile];
    G --> H[Collect Evidence];
    H --> I[Run Validations];
    I --> J[Generate Reports];
