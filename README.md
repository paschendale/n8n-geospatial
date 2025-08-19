# n8n-geospatial

n8n workflow automation platform enhanced with comprehensive geospatial capabilities including QGIS, GDAL, and PDAL.

## Features

- **n8n 1.107.3** - Workflow automation platform
- **QGIS 3.44.2** - Geographic Information System with Python bindings
- **GDAL** - Geospatial Data Abstraction Library for raster/vector data
- **PDAL** - Point Data Abstraction Library for LiDAR/point cloud processing
- **GraphicsMagick** - Image processing capabilities
- **Node.js 20.x** - JavaScript runtime

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-username/n8n-geospatial.git
cd n8n-geospatial

# Start the service
docker-compose up -d

# Access n8n at http://localhost:5678
```

### Using Docker directly

```bash
# Build the image
docker build -t n8n-geospatial .

# Run the container
docker run -d \
  --name n8n-geospatial \
  -p 5678:5678 \
  -v ./n8n-data:/home/node/.n8n \
  n8n-geospatial
```

## Geospatial Capabilities

### QGIS Integration
- Full QGIS 3.44.2 installation with Python bindings
- Access via Python scripts in n8n workflows
- Support for vector and raster processing

### GDAL Tools
- Command-line tools: `gdalinfo`, `gdal_translate`, `ogr2ogr`
- Python bindings for programmatic access
- Support for 200+ geospatial formats

### PDAL Tools
- Point cloud processing and analysis
- LiDAR data manipulation
- Python bindings for workflow integration

## Example Workflows

### 1. Geospatial Data Processing
```python
# In n8n Python node
import qgis.core
from osgeo import gdal

# Load and process vector data
layer = qgis.core.QgsVectorLayer("path/to/data.shp", "layer", "ogr")
# Process data...
```

### 2. Raster Analysis
```python
# GDAL raster operations
dataset = gdal.Open("input.tif")
# Perform analysis...
```

### 3. Point Cloud Processing
```python
# PDAL point cloud operations
import pdal
pipeline = pdal.Pipeline("pipeline.json")
pipeline.execute()
```

## Development

### Building Locally
```bash
# Build for testing
docker build -t n8n-geospatial:test .

# Run tests
./build.sh
```

### Testing
The automated workflow tests:
- QGIS accessibility and Python bindings
- n8n web interface accessibility
- GDAL command-line tools and Python bindings
- PDAL command-line tools and Python bindings

### Logs
```bash
# View container logs
docker-compose logs n8n

# Access container shell
docker exec -it n8n-geospatial bash
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

