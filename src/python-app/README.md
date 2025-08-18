# Python Web Application for Kubernetes

A simple, production-ready Python web application designed for Kubernetes deployment with comprehensive health checks and monitoring capabilities.

## Features

- 🚀 **Flask-based web application** with RESTful API endpoints
- 🏥 **Health checks** for Kubernetes liveness and readiness probes
- 📊 **Metrics endpoint** for monitoring and observability
- 🔒 **Security-focused** with non-root user and proper security contexts
- 📈 **Auto-scaling** with Horizontal Pod Autoscaler (HPA)
- 🐳 **Dockerized** with multi-stage build for optimal image size
- 🔧 **Configurable** via environment variables and ConfigMaps

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Main application endpoint with status information |
| `/health` | GET | Basic health check |
| `/health/live` | GET | Kubernetes liveness probe endpoint |
| `/health/ready` | GET | Kubernetes readiness probe endpoint |
| `/metrics` | GET | Application metrics (request count, uptime, memory) |
| `/info` | GET | Application information and configuration |

## Quick Start

### Prerequisites

- Docker
- kubectl configured to connect to a Kubernetes cluster
- Python 3.11+ (for local development)

### Local Development

1. **Clone and navigate to the project:**
   ```bash
   cd src/python-app
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application locally:**
   ```bash
   python main.py
   ```

4. **Test the endpoints:**
   ```bash
   curl http://localhost:8080/
   curl http://localhost:8080/health
   curl http://localhost:8080/metrics
   ```

### Docker Build

```bash
# Build the Docker image
docker build -t genocs/python-web-app:latest -t genocs/python-web-app:1.0.0 .

# Run the container locally
docker run -p 8080:8080 genocs/python-web-app:latest

# Push the image to the registry
docker push genocs/python-web-app:1.0.0 
docker push genocs/python-web-app:latest
```

### Kubernetes Deployment

#### Option 1: Using the deployment script (Recommended)

```bash
# Make the script executable (if not already)
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

#### Option 2: Manual deployment

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/python-web-app
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | `0.0.0.0` | Host to bind the application to |
| `PORT` | `8080` | Port to run the application on |
| `DEBUG` | `false` | Enable debug mode |
| `ENVIRONMENT` | `development` | Environment name |

### Kubernetes Configuration

The application includes several Kubernetes manifests:

- **Deployment**: Main application deployment with 3 replicas
- **Service**: ClusterIP service to expose the application
- **Ingress**: NGINX ingress for external access
- **HPA**: Horizontal Pod Autoscaler for automatic scaling
- **ConfigMap**: Application configuration

## Health Checks

### Liveness Probe (`/health/live`)

Checks if the application is alive and functioning:
- Verifies application uptime (must be > 5 seconds)
- Monitors memory usage (must be < 1GB)
- Returns 503 if unhealthy

### Readiness Probe (`/health/ready`)

Checks if the application is ready to serve traffic:
- Simulates database connectivity check
- Simulates cache connectivity check
- Simulates external service availability
- Returns 503 if not ready

### Startup Probe (`/health`)

Used during application startup to determine when the application is ready to receive traffic.

## Monitoring and Observability

### Metrics Endpoint

The `/metrics` endpoint provides:
- Total request count
- Application uptime
- Memory usage (if psutil is available)

### Logging

The application uses structured logging with:
- Timestamp
- Log level
- Component name
- Detailed messages

## Security Features

- **Non-root user**: Application runs as user `appuser` (UID 1000)
- **Security contexts**: Proper security contexts in Kubernetes manifests
- **Capability dropping**: All Linux capabilities are dropped
- **Privilege escalation**: Disabled

## Scaling

The application includes a Horizontal Pod Autoscaler (HPA) that:
- Scales based on CPU usage (target: 70%)
- Scales based on memory usage (target: 80%)
- Minimum replicas: 2
- Maximum replicas: 10
- Includes scale-up and scale-down behavior configuration

## Troubleshooting

### Common Issues

1. **Application not starting:**
   ```bash
   kubectl logs deployment/python-web-app
   ```

2. **Health checks failing:**
   ```bash
   kubectl describe pod -l app=python-web-app
   ```

3. **Service not accessible:**
   ```bash
   kubectl get svc python-web-app-service
   kubectl port-forward svc/python-web-app-service 8080:80
   ```

### Useful Commands

```bash
# Check pod status
kubectl get pods -l app=python-web-app

# View logs
kubectl logs -f deployment/python-web-app

# Check service endpoints
kubectl get endpoints python-web-app-service

# Check HPA status
kubectl get hpa python-web-app-hpa

# Describe deployment
kubectl describe deployment python-web-app
```

## Development

### Adding New Endpoints

1. Add the route to `main.py`
2. Include proper error handling
3. Add logging for the endpoint
4. Update this README with endpoint documentation

### Customizing Health Checks

Modify the health check functions in `main.py`:
- `check_database_connection()`
- `check_cache_connection()`
- `check_external_service()`

### Building for Production

```bash
# Build optimized image
docker build -t python-web-app:production .

# Push to registry (replace with your registry)
docker tag python-web-app:production your-registry/python-web-app:latest
docker push your-registry/python-web-app:latest
```

## License

This project is provided as-is for educational and demonstration purposes.
