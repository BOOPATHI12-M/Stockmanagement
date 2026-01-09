#!/bin/bash
# Test script to verify Docker build works correctly

echo "🧪 Testing Docker Build..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

echo "✅ Docker is installed: $(docker --version)"
echo ""

# Navigate to backend directory
cd "$(dirname "$0")" || exit 1

# Build the image
echo "🔨 Building Docker image..."
docker build -t sudharshini-stock-management:test .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    
    # Show image size
    echo "📦 Image information:"
    docker images sudharshini-stock-management:test --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    echo ""
    
    # Test running the container (dry run)
    echo "🧪 Testing container startup (will stop after 10 seconds)..."
    timeout 10 docker run --rm \
        -e PORT=8080 \
        -e SPRING_PROFILES_ACTIVE=production \
        -e JWT_SECRET=test-secret \
        -e CORS_ORIGINS=http://localhost:3000 \
        sudharshini-stock-management:test || true
    
    echo ""
    echo "✅ Docker build test completed!"
    echo ""
    echo "To run the container:"
    echo "  docker run -p 8080:8080 -e JWT_SECRET=your-secret sudharshini-stock-management:test"
else
    echo ""
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi

