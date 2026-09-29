# Deployment Strategy Lab

A lightweight DevOps project demonstrating production deployment strategies using Docker, Nginx, Flask, Docker Compose, and Bash automation.

This project demonstrates how different deployment strategies can be used to release new application versions while controlling production traffic and providing rollback capabilities.

---

## Project Objective

This project demonstrates three common deployment strategies:

- Rolling Deployment
- Blue-Green Deployment
- Canary Deployment
- Automated Rollback

The application uses two versions:

- v1.0 — stable version
- v2.0 — new version

---

## Architecture

                         Client
                           |
                           v
                    +-------------+
                    |    Nginx    |
                    |   Traffic   |
                    |   Routing   |
                    +------+------+
                           |
              +------------+------------+
              |                         |
              v                         v
       +-------------+           +-------------+
       |    Blue     |           |    Green    |
       |    v1.0     |           |    v2.0     |
       |   Stable    |           |     New     |
       +-------------+           +-------------+
              |                         |
              +------------+------------+
                           |
                         Docker
                           |
                    Docker Compose

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Python Flask | Application |
| Docker | Containerization |
| Docker Compose | Container orchestration |
| Nginx | Reverse proxy and traffic routing |
| Bash | Deployment automation |
| Git | Version control |
| AWS EC2 | Deployment environment |

---

## Application

The application is a simple Flask service that exposes application version and health information.

### Endpoints

- GET /
- GET /version
- GET /health

Example:

    curl http://localhost:8080/version

Example response:

    {
      "hostname": "container-id",
      "version": "v2.0"
    }

Health check:

    curl http://localhost:8080/health

Example response:

    {
      "status": "healthy",
      "version": "v2.0"
    }

---

# Deployment Strategies

## 1. Rolling Deployment

Rolling deployment gradually introduces a new application version while the existing version is still running.

Flow:

    v1 → v1 + v2 → v2

The simplified implementation in this project:

    1. Start the new version
    2. Verify the new version
    3. Switch traffic
    4. Complete the deployment

Run:

    ./scripts/rolling-deploy.sh

### Benefits

- Minimal downtime
- Gradual version transition
- Lower resource requirements
- Suitable for standard application releases

---

## 2. Blue-Green Deployment

Blue-Green deployment maintains two application environments.

    Blue  → v1.0
    Green → v2.0

Only one environment receives production traffic at a time.

### Initial State

    Client
       |
       v
     Nginx
       |
       v
    Blue v1.0

Green v2.0 is running but does not receive production traffic.

### Switch to Green

    ./scripts/blue-green-deploy.sh green

Traffic becomes:

    Client
       |
       v
     Nginx
       |
       v
    Green v2.0

### Roll Back to Blue

    ./scripts/blue-green-deploy.sh blue

Traffic returns to:

    Client
       |
       v
     Nginx
       |
       v
    Blue v1.0

### Benefits

- Fast rollback
- Simple traffic switching
- Previous version remains available
- Reduced deployment risk
- Useful when rapid recovery is important

---

## 3. Canary Deployment

Canary deployment exposes the new version to a small percentage of traffic before gradually increasing exposure.

Initial release:

    90% → v1.0
    10% → v2.0

Progressive rollout:

    10% → 25% → 50% → 100%

### Start with 10%

    ./scripts/canary-deploy.sh 10

### Increase to 25%

    ./scripts/canary-deploy.sh 25

### Increase to 50%

    ./scripts/canary-deploy.sh 50

### Complete rollout

    ./scripts/canary-deploy.sh 100

Nginx uses request-based traffic distribution to simulate the canary release.

Example:

    for i in {1..20}; do
        echo -n "client-$i -> "
        curl -s -H "X-Canary-ID: client-$i" \
        http://localhost:8080/version
    done

### Benefits

- Controlled exposure to the new version
- Reduced release risk
- Progressive rollout
- Easy to stop before full production exposure

---

# Rollback

The project includes a dedicated rollback script.

    ./scripts/rollback.sh

The rollback switches production traffic back to the stable version.

Expected result:

    Production → v1.0

Rollback flow:

    v1.0 Stable
         |
         v
    Canary v2.0
         |
         | Failure detected
         v
      Rollback
         |
         v
    v1.0 Stable

---

# Testing

Check running containers:

    docker compose ps

Test the application:

    curl http://localhost:8080/

Check version:

    curl http://localhost:8080/version

Check health:

    curl http://localhost:8080/health

---

# Blue-Green Deployment Test

Switch to Blue:

    ./scripts/blue-green-deploy.sh blue

Verify:

    curl http://localhost:8080/version

Expected:

    v1.0

Switch to Green:

    ./scripts/blue-green-deploy.sh green

Verify:

    curl http://localhost:8080/version

Expected:

    v2.0

Rollback:

    ./scripts/blue-green-deploy.sh blue

Verify:

    curl http://localhost:8080/version

Expected:

    v1.0

---

# Canary Deployment Test

Start with 10%:

    ./scripts/canary-deploy.sh 10

Test multiple clients:

    for i in {1..100}; do
        curl -s -H "X-Canary-ID: client-$i" \
        http://localhost:8080/version
    done

Increase exposure:

    ./scripts/canary-deploy.sh 25

Then:

    ./scripts/canary-deploy.sh 50

Finally:

    ./scripts/canary-deploy.sh 100

---

# Deployment Strategy Comparison

| Strategy | Traffic Model | Rollback | Resource Usage | Main Use Case |
|---|---|---|---|---|
| Rolling | Gradual replacement | Moderate | Low | Standard application releases |
| Blue-Green | Instant traffic switch | Very fast | Higher | Fast switching and rollback |
| Canary | Percentage based | Controlled | Medium | Risk-controlled releases |

---

# Project Structure

    deployment-strategy-lab/
    │
    ├── app/
    │   ├── Dockerfile
    │   ├── app.py
    │   └── requirements.txt
    │
    ├── nginx/
    │   └── nginx.conf
    │
    ├── scripts/
    │   ├── rolling-deploy.sh
    │   ├── blue-green-deploy.sh
    │   ├── canary-deploy.sh
    │   └── rollback.sh
    │
    ├── docker-compose.yml
    └── README.md

---

# Running the Project

Clone the repository:

    git clone <repository-url>
    cd deployment-strategy-lab

Start the application:

    docker compose up -d

Check containers:

    docker compose ps

Test the application:

    curl http://localhost:8080/

---

# Docker Images

The project uses two application images:

    deployment-strategy-lab:v1
    deployment-strategy-lab:v2

Build v1:

    docker build -t deployment-strategy-lab:v1 ./app

Build v2:

    docker build -t deployment-strategy-lab:v2 ./app

---

# Key DevOps Concepts Demonstrated

- Containerization
- Docker image versioning
- Docker Compose
- Nginx reverse proxy
- Traffic routing
- Rolling deployment
- Blue-Green deployment
- Canary deployment
- Progressive traffic shifting
- Automated rollback
- Bash automation
- Application health checks
- Versioned releases
- Git version control
- Deployment risk management

---

# Interview Explanation

I built a lightweight deployment strategy lab using Flask, Docker, Docker Compose, Nginx, and Bash automation.

I created two application versions and implemented rolling, blue-green, and canary deployment strategies.

For blue-green deployment, I maintain separate Blue and Green application environments and switch Nginx traffic between them, allowing rapid rollback to the previous version.

For canary deployment, Nginx distributes a controlled percentage of traffic to the new version. The traffic can progressively increase from 10% to 25%, 50%, and finally 100%.

I also implemented automated rollback so production traffic can be returned to the stable version when a deployment needs to be reverted.

The project demonstrates how different deployment strategies can reduce release risk while maintaining control over production traffic.

---

# Production Extension

This project is intentionally lightweight so it can run on a small EC2 instance.

A production implementation could extend the architecture with:

    GitHub Actions
           |
           v
    Container Registry
           |
           v
       Amazon EKS
           |
           +---- Rolling Deployment
           |
           +---- Blue-Green
           |
           +---- Canary
           |
           v
      Argo Rollouts
           |
           v
       Prometheus
           |
           v
    Automated Analysis
           |
           v
    Automatic Rollback

Possible future technologies:

- Amazon EKS
- Amazon ECR
- GitHub Actions
- Argo CD
- Argo Rollouts
- Prometheus
- Grafana
- AWS Application Load Balancer

---

# Project Outcome

This project demonstrates practical understanding of deployment and release strategies rather than simply deploying an application.

The deployment lifecycle demonstrated in this project is:

    Build
      ↓
    Version
      ↓
    Deploy
      ↓
    Control Traffic
      ↓
    Validate Release
      ↓
    Promote
      ↓
    Rollback if Required

---

## Author

Ashish Thakur

DevOps / Cloud Engineer
