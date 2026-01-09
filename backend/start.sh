#!/bin/bash
# Start script for Render deployment

echo "🚀 Starting Spring Boot application..."

# Use PORT from environment variable (Render provides this)
PORT=${PORT:-8080}

# Start the application
java -jar target/stock-management-1.0.0.jar --spring.profiles.active=production --server.port=$PORT

