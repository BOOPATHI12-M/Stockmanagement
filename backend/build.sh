#!/bin/bash
# Build script for Render deployment

echo "🔨 Building Spring Boot application..."

# Make Maven wrapper executable
chmod +x ./mvnw

# Clean and build
./mvnw clean package -DskipTests

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📦 JAR file location: target/stock-management-1.0.0.jar"
else
    echo "❌ Build failed!"
    exit 1
fi

