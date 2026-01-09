# Docker Deployment Guide

## 📦 Dockerfile Explanation

### Multi-Stage Build Benefits

**Why use multi-stage builds?**
- **Smaller final image**: Only includes runtime dependencies, not build tools
- **Faster deployments**: Smaller images download faster
- **Better security**: Fewer tools in production image = smaller attack surface
- **Cost savings**: Less storage and bandwidth usage

### Stage 1: Builder Stage

```dockerfile
FROM maven:3.9-eclipse-temurin-17 AS builder
```
**What it does**: Starts with a Maven image that has Java 17 and Maven pre-installed.
**Why**: We need Maven to compile the code, but we don't need it in the final image.

```dockerfile
WORKDIR /app
```
**What it does**: Sets `/app` as the working directory.
**Why**: All commands run from this directory, keeps things organized.

```dockerfile
COPY mvnw .
COPY .mvn .mvn
RUN chmod +x ./mvnw
```
**What it does**: Copies Maven wrapper and makes it executable.
**Why**: Maven wrapper ensures consistent Maven version across environments.

```dockerfile
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B -DskipTests
```
**What it does**: Downloads all Maven dependencies first.
**Why**: Docker caches this layer. If `pom.xml` doesn't change, dependencies aren't re-downloaded.

```dockerfile
COPY src ./src
RUN ./mvnw clean package -B -DskipTests
```
**What it does**: Copies source code and builds the JAR file.
**Why**: Separating dependency download from build optimizes caching.

### Stage 2: Runtime Stage

```dockerfile
FROM eclipse-temurin:17-jre-alpine
```
**What it does**: Uses a minimal Java 17 runtime image (Alpine Linux).
**Why**: 
- **Alpine**: Very small Linux distribution (~5MB base)
- **JRE**: Only runtime, not development tools (saves ~350MB)
- **Total size**: ~150MB vs ~500MB for full JDK

```dockerfile
RUN addgroup -S spring && adduser -S spring -G spring
```
**What it does**: Creates a non-root user named "spring".
**Why**: Security best practice - if container is compromised, attacker doesn't have root access.

```dockerfile
COPY --from=builder /app/target/stock-management-1.0.0.jar app.jar
```
**What it does**: Copies only the JAR file from the builder stage.
**Why**: We don't need source code, Maven, or build tools in production.

```dockerfile
RUN mkdir -p /tmp/uploads/products && \
    mkdir -p /tmp && \
    chown -R spring:spring /app /tmp
```
**What it does**: Creates directories and sets ownership.
**Why**: Application needs write access to these directories.

```dockerfile
USER spring
```
**What it does**: Switches to the non-root user.
**Why**: Application runs without root privileges.

```dockerfile
EXPOSE 8080
```
**What it does**: Documents that the app uses port 8080.
**Why**: Documentation for developers and deployment tools.

```dockerfile
ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE=production \
    PORT=8080
```
**What it does**: Sets default environment variables.
**Why**: 
- `JAVA_OPTS`: Limits memory usage (adjust based on your needs)
- `SPRING_PROFILES_ACTIVE`: Activates production profile
- `PORT`: Default port (Render will override this)

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/api/reports/summary || exit 1
```
**What it does**: Checks if application is healthy every 30 seconds.
**Why**: 
- Docker/Render can detect if app crashes
- Automatic restart on failure
- Load balancers can route traffic only to healthy instances

```dockerfile
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]
```
**What it does**: Runs the Spring Boot application.
**Why**: 
- `$JAVA_OPTS`: Applies memory settings
- `${PORT:-8080}`: Uses PORT env var, defaults to 8080
- `-Dserver.port`: Sets Spring Boot port dynamically

## 🚀 Building the Docker Image

### Local Build

```bash
# Navigate to backend directory
cd backend

# Build the image
docker build -t sudharshini-stock-management:latest .

# View image size
docker images sudharshini-stock-management
```

### Build with Tags

```bash
# Build with version tag
docker build -t sudharshini-stock-management:1.0.0 .

# Build with multiple tags
docker build -t sudharshini-stock-management:latest \
             -t sudharshini-stock-management:1.0.0 \
             -t your-dockerhub-username/sudharshini-stock-management:latest .
```

## 🧪 Testing Locally

### Run the Container

```bash
# Run with default port
docker run -p 8080:8080 sudharshini-stock-management:latest

# Run with environment variables
docker run -p 8080:8080 \
  -e PORT=8080 \
  -e SPRING_PROFILES_ACTIVE=production \
  -e JWT_SECRET=your-secret-key \
  -e CORS_ORIGINS=http://localhost:3000 \
  sudharshini-stock-management:latest

# Run with all environment variables (using .env file)
docker run -p 8080:8080 --env-file .env sudharshini-stock-management:latest
```

### Test Health Check

```bash
# Check if container is healthy
docker ps

# View health check status
docker inspect --format='{{.State.Health.Status}}' <container-id>
```

## 📤 Deploying to Render with Docker

### Option 1: Using Dockerfile (Recommended)

1. **Push code to GitHub** (with Dockerfile)

2. **Create Web Service on Render**:
   - Go to Render Dashboard
   - Click "New +" → "Web Service"
   - Connect GitHub repository
   - Select your repository

3. **Configure Service**:
   - **Name**: `sudharshini-stock-backend`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `backend/Dockerfile` (or just `Dockerfile` if in root)
   - **Docker Context**: `backend` (directory containing Dockerfile)

4. **Set Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=production
   PORT=8080
   JWT_SECRET=<your-secret>
   CORS_ORIGINS=https://your-frontend.onrender.com
   MAIL_USERNAME=<your-email>
   MAIL_PASSWORD=<your-password>
   # ... all other environment variables
   ```

5. **Deploy**: Click "Create Web Service"

### Option 2: Using Docker Hub

1. **Build and push to Docker Hub**:
   ```bash
   # Login to Docker Hub
   docker login

   # Build image
   docker build -t your-username/sudharshini-stock-management:latest backend/

   # Push to Docker Hub
   docker push your-username/sudharshini-stock-management:latest
   ```

2. **On Render**:
   - Create Web Service
   - Select "Docker"
   - Enter image: `your-username/sudharshini-stock-management:latest`
   - Set environment variables
   - Deploy

## 🔧 Optimizing the Dockerfile

### Current Image Size
- **Builder stage**: ~800MB (includes Maven and JDK)
- **Final image**: ~150MB (only JRE and JAR)

### Further Optimization Options

1. **Use JRE with jlink** (create custom minimal JRE):
   ```dockerfile
   # This creates a minimal JRE with only needed modules
   # Can reduce size to ~80MB, but more complex
   ```

2. **Use distroless images**:
   ```dockerfile
   FROM gcr.io/distroless/java17-debian11
   # Even smaller, but harder to debug
   ```

3. **Multi-architecture builds**:
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 .
   ```

## 🐛 Troubleshooting

### Issue: Build fails with "Maven not found"

**Solution**: Ensure `mvnw` and `.mvn` directory are in the repository.

### Issue: "Port already in use"

**Solution**: 
- Check if another container is using port 8080
- Use different port: `docker run -p 3000:8080 ...`

### Issue: "Permission denied" when writing files

**Solution**: 
- Check directory permissions in Dockerfile
- Ensure `USER spring` has write access to `/tmp`

### Issue: Application can't connect to database

**Solution**: 
- Verify database path is writable
- Check `DB_PATH` environment variable
- For SQLite, ensure directory exists and is writable

### Issue: Health check fails

**Solution**: 
- Verify endpoint exists: `/api/reports/summary`
- Check if authentication is required (may need to adjust health check)
- Increase `--start-period` if app takes longer to start

### Issue: Out of memory errors

**Solution**: 
- Adjust `JAVA_OPTS` in Dockerfile or environment variables
- Increase Render service memory limit
- Example: `JAVA_OPTS=-Xmx1024m -Xms512m`

## 📊 Image Size Comparison

| Approach | Image Size | Build Time | Security |
|----------|-----------|------------|----------|
| Single-stage (full JDK) | ~500MB | Fast | Medium |
| Multi-stage (JRE Alpine) | ~150MB | Medium | Good |
| Distroless | ~100MB | Medium | Excellent |
| Custom jlink | ~80MB | Slow | Excellent |

**Recommendation**: Multi-stage with JRE Alpine (current setup) provides the best balance.

## ✅ Best Practices Checklist

- [x] Multi-stage build to reduce size
- [x] Non-root user for security
- [x] Minimal base image (Alpine)
- [x] Layer caching optimization
- [x] Health check configured
- [x] Dynamic PORT support
- [x] Environment variable configuration
- [x] .dockerignore to exclude unnecessary files
- [x] Proper working directory
- [x] Memory limits configured

## 🔗 Additional Resources

- **Docker Best Practices**: https://docs.docker.com/develop/dev-best-practices/
- **Spring Boot Docker Guide**: https://spring.io/guides/gs/spring-boot-docker/
- **Render Docker Docs**: https://render.com/docs/docker

---

**Ready to deploy?** Push your code with the Dockerfile to GitHub and deploy on Render!

