#!/usr/bin/env python3
"""
Simple Python Web Application for Kubernetes
Provides health checks and basic web functionality for K8s deployment
"""

import os
import time
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from werkzeug.middleware.proxy_fix import ProxyFix

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

# Application state
app_start_time = time.time()
request_count = 0

# Configuration
HOST = os.getenv('HOST', '0.0.0.0')
PORT = int(os.getenv('PORT', 8080))
DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'

@app.route('/')
def home():
    """Main application endpoint"""
    global request_count
    request_count += 1
    
    response = {
        'message': 'Hello from Python Web App!',
        'timestamp': datetime.utcnow().isoformat(),
        'request_count': request_count,
        'uptime_seconds': int(time.time() - app_start_time),
        'version': '1.0.0',
        'environment': os.getenv('ENVIRONMENT', 'development')
    }
    
    logger.info(f"Home endpoint accessed - Request #{request_count}")
    return jsonify(response)

@app.route('/health')
def health():
    """Basic health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'uptime_seconds': int(time.time() - app_start_time)
    })

@app.route('/health/live')
def liveness():
    """Kubernetes liveness probe endpoint"""
    # Simulate application health check
    # In a real application, you might check database connections, 
    # external service availability, etc.
    
    try:
        # Basic health indicators
        uptime = time.time() - app_start_time
        memory_usage = get_memory_usage()
        
        # Consider unhealthy if uptime is less than 5 seconds (startup phase)
        if uptime < 5:
            logger.warning("Application still starting up")
            return jsonify({
                'status': 'starting',
                'uptime_seconds': int(uptime),
                'memory_mb': memory_usage
            }), 503
        
        # Consider unhealthy if memory usage is too high (example threshold)
        if memory_usage > 1000:  # 1GB threshold
            logger.error(f"Memory usage too high: {memory_usage}MB")
            return jsonify({
                'status': 'unhealthy',
                'error': 'Memory usage exceeded threshold',
                'memory_mb': memory_usage
            }), 503
        
        logger.info("Liveness check passed")
        return jsonify({
            'status': 'healthy',
            'uptime_seconds': int(uptime),
            'memory_mb': memory_usage,
            'timestamp': datetime.utcnow().isoformat()
        })
        
    except Exception as e:
        logger.error(f"Liveness check failed: {str(e)}")
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 503

@app.route('/health/ready')
def readiness():
    """Kubernetes readiness probe endpoint"""
    # Check if the application is ready to serve traffic
    # This might include database connectivity, cache availability, etc.
    
    try:
        # Simulate readiness checks
        checks = {
            'database': check_database_connection(),
            'cache': check_cache_connection(),
            'external_service': check_external_service()
        }
        
        all_healthy = all(checks.values())
        
        if all_healthy:
            logger.info("Readiness check passed")
            return jsonify({
                'status': 'ready',
                'checks': checks,
                'timestamp': datetime.utcnow().isoformat()
            })
        else:
            logger.warning(f"Readiness check failed: {checks}")
            return jsonify({
                'status': 'not_ready',
                'checks': checks,
                'timestamp': datetime.utcnow().isoformat()
            }), 503
            
    except Exception as e:
        logger.error(f"Readiness check failed: {str(e)}")
        return jsonify({
            'status': 'not_ready',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 503

@app.route('/metrics')
def metrics():
    """Application metrics endpoint"""
    return jsonify({
        'requests_total': request_count,
        'uptime_seconds': int(time.time() - app_start_time),
        'memory_mb': get_memory_usage(),
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/info')
def info():
    """Application information endpoint"""
    return jsonify({
        'name': 'python-web-app',
        'version': '1.0.0',
        'description': 'Simple Python web application for Kubernetes',
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'host': HOST,
        'port': PORT,
        'debug': DEBUG,
        'python_version': os.sys.version,
        'timestamp': datetime.utcnow().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Not found',
        'message': 'The requested resource was not found',
        'timestamp': datetime.utcnow().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {error}")
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred',
        'timestamp': datetime.utcnow().isoformat()
    }), 500

def get_memory_usage():
    """Get current memory usage in MB"""
    try:
        import psutil
        process = psutil.Process()
        return round(process.memory_info().rss / 1024 / 1024, 2)
    except ImportError:
        # psutil not available, return 0
        return 0

def check_database_connection():
    """Simulate database connection check"""
    # In a real application, you would check actual database connectivity
    # For demo purposes, we'll simulate a successful connection
    return True

def check_cache_connection():
    """Simulate cache connection check"""
    # In a real application, you would check Redis/Memcached connectivity
    # For demo purposes, we'll simulate a successful connection
    return True

def check_external_service():
    """Simulate external service check"""
    # In a real application, you would check external API availability
    # For demo purposes, we'll simulate a successful connection
    return True

if __name__ == '__main__':
    logger.info(f"Starting Python Web Application on {HOST}:{PORT}")
    logger.info(f"Debug mode: {DEBUG}")
    logger.info(f"Environment: {os.getenv('ENVIRONMENT', 'development')}")
    
    app.run(
        host=HOST,
        port=PORT,
        debug=DEBUG,
        threaded=True
    )
