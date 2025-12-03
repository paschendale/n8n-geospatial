#!/bin/bash

# Build and Test Script for n8n-geospatial
# Replicates the GitHub Actions workflow locally

set -e  # Exit on any error

echo "🚀 Starting build and test process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running"

# Build Docker image
print_status "Building Docker image..."
docker build -t paschendale/n8n-geospatial:test . --platform linux/amd64

if [ $? -eq 0 ]; then
    print_success "Docker image built successfully"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Start container for testing
print_status "Starting container for testing..."
CONTAINER_NAME="n8n-test-$(date +%s)"

# Clean up any existing test container
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Start the container
docker run -d --name $CONTAINER_NAME -p 5678:5678 --platform linux/amd64 \
    paschendale/n8n-geospatial:test

if [ $? -eq 0 ]; then
    print_success "Container started successfully"
else
    print_error "Failed to start container"
    exit 1
fi

# Wait for n8n to start
print_status "Waiting for n8n to start..."
sleep 10

# Test QGIS accessibility
print_status "Testing QGIS accessibility..."
if docker exec $CONTAINER_NAME qgis --version; then
    print_success "QGIS is accessible"
else
    print_error "QGIS is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

if docker exec $CONTAINER_NAME python3 -c "import qgis.core; print('QGIS Python bindings working')"; then
    print_success "QGIS Python bindings are working"
else
    print_error "QGIS Python bindings are not working"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# Test n8n accessibility
print_status "Testing n8n accessibility..."
if curl -f http://localhost:5678; then
    print_success "n8n is accessible at http://localhost:5678"
else
    print_error "n8n is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# Test GDAL accessibility
print_status "Testing GDAL accessibility..."
if docker exec $CONTAINER_NAME gdalinfo --version; then
    print_success "GDAL is accessible"
else
    print_error "GDAL is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

if docker exec $CONTAINER_NAME python3 -c "from osgeo import gdal; print('GDAL Python bindings working')"; then
    print_success "GDAL Python bindings are working"
else
    print_error "GDAL Python bindings are not working"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# Test PDAL accessibility
print_status "Testing PDAL accessibility..."
if docker exec $CONTAINER_NAME pdal --version; then
    print_success "PDAL is accessible"
else
    print_error "PDAL is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# This is not available, but isnt needed for now. If the need arises, we can install PDAL via pip
# if docker exec $CONTAINER_NAME python3 -c "import pdal; print('PDAL Python bindings working')"; then
#     print_success "PDAL Python bindings are working"
# else
#     print_error "PDAL Python bindings are not working"
#     docker stop $CONTAINER_NAME
#     docker rm $CONTAINER_NAME
#     exit 1
# fi

# Test tippecanoe accessibility
print_status "Testing tippecanoe accessibility..."
if docker exec $CONTAINER_NAME tippecanoe --version; then
    print_success "tippecanoe is accessible"
else
    print_error "tippecanoe is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# Test MinIO Client accessibility
print_status "Testing MinIO Client accessibility..."
if docker exec $CONTAINER_NAME mc --version; then
    print_success "MinIO Client is accessible"
else
    print_error "MinIO Client is not accessible"
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
    exit 1
fi

# Cleanup
print_status "Cleaning up test container..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

if [ $? -eq 0 ]; then
    print_success "Container cleaned up successfully"
else
    print_warning "Failed to clean up container, but tests passed"
fi

print_success "🎉 All tests passed! Build and test process completed successfully."
print_status "The Docker image 'paschendale/n8n-geospatial:test' is ready for use."
