#!/usr/bin/env python3
"""
Test script for the Python Web Application
Validates all endpoints and health checks
"""

import requests
import time
import json
import sys
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8080"
TIMEOUT = 10

def test_endpoint(endpoint, expected_status=200, description=""):
    """Test a specific endpoint"""
    url = f"{BASE_URL}{endpoint}"
    try:
        response = requests.get(url, timeout=TIMEOUT)
        print(f"✅ {description or endpoint}: {response.status_code}")
        
        if response.status_code == expected_status:
            try:
                data = response.json()
                print(f"   Response: {json.dumps(data, indent=2)}")
            except json.JSONDecodeError:
                print(f"   Response: {response.text}")
            return True
        else:
            print(f"   ❌ Expected {expected_status}, got {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ {description or endpoint}: {str(e)}")
        return False

def test_health_checks():
    """Test all health check endpoints"""
    print("\n🏥 Testing Health Checks...")
    
    tests = [
        ("/health", 200, "Basic Health Check"),
        ("/health/live", 200, "Liveness Probe"),
        ("/health/ready", 200, "Readiness Probe"),
    ]
    
    results = []
    for endpoint, expected_status, description in tests:
        result = test_endpoint(endpoint, expected_status, description)
        results.append(result)
    
    return all(results)

def test_main_endpoints():
    """Test main application endpoints"""
    print("\n🚀 Testing Main Endpoints...")
    
    tests = [
        ("/", 200, "Home Endpoint"),
        ("/info", 200, "Info Endpoint"),
        ("/metrics", 200, "Metrics Endpoint"),
    ]
    
    results = []
    for endpoint, expected_status, description in tests:
        result = test_endpoint(endpoint, expected_status, description)
        results.append(result)
    
    return all(results)

def test_error_handling():
    """Test error handling"""
    print("\n⚠️  Testing Error Handling...")
    
    # Test 404
    result = test_endpoint("/nonexistent", 404, "404 Error Handling")
    
    return result

def test_startup_behavior():
    """Test startup behavior (simulate startup phase)"""
    print("\n🔄 Testing Startup Behavior...")
    
    # The application should return 503 during startup (first 5 seconds)
    # This is a simulation - in real testing, you'd need to restart the app
    print("   Note: Startup behavior testing requires app restart")
    print("   During startup (< 5s), /health/live should return 503")
    
    return True

def main():
    """Main test function"""
    print("🧪 Python Web Application Test Suite")
    print("=" * 50)
    print(f"Testing application at: {BASE_URL}")
    print(f"Timestamp: {datetime.now().isoformat()}")
    
    # Wait a moment for app to be ready
    print("\n⏳ Waiting for application to be ready...")
    time.sleep(2)
    
    # Run all tests
    test_results = []
    
    # Test main endpoints
    test_results.append(test_main_endpoints())
    
    # Test health checks
    test_results.append(test_health_checks())
    
    # Test error handling
    test_results.append(test_error_handling())
    
    # Test startup behavior (informational)
    test_startup_behavior()
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Test Summary")
    print("=" * 50)
    
    passed = sum(test_results)
    total = len(test_results)
    
    if passed == total:
        print(f"✅ All {total} test categories passed!")
        print("🎉 Application is working correctly!")
        sys.exit(0)
    else:
        print(f"❌ {total - passed} out of {total} test categories failed")
        print("🔧 Please check the application logs and configuration")
        sys.exit(1)

if __name__ == "__main__":
    main()
