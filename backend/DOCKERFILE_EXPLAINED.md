# Dockerfile Line-by-Line Explanation

## 📋 Complete Dockerfile Breakdown

### Stage 1: Build Stage (Lines 1-48)

#### Line 9: `FROM maven:3.9-eclipse-temurin-17 AS builder`
**What**: Starts with a pre-built image containing Maven 3.9 and Java 17.
**Why**: We need build tools (Maven, JDK) to compile code, but don't need them in final image.
**Size**: ~800MB (but discarded after build)

#### Line 13: `WORKDIR /app`
**What**: Creates and sets `/app` as the working directory.
**Why**: All commands run from here - keeps things organized.

#### Line 28: `COPY pom.xml .`
**What**: Copies only the Maven configuration file.
**Why**: Docker caches layers. If `pom.xml` doesn't change, we can reuse cached dependencies.

#### Line 34: `RUN mvn dependency:go-offline -B -DskipTests`
**What**: Downloads all Maven dependencies.
**Why**: 
- Cached separately from source code
- If dependencies don't change, this step is skipped
- `-B`: batch mode (no interactive prompts)
- `-DskipTests`: faster (tests run later if needed)

#### Line 38: `COPY src ./src`
**What**: Copies all source code files.
**Why**: Source code changes frequently, so it's copied after dependencies.

#### Line 44: `RUN mvn clean package -B -DskipTests`
**What**: Compiles code and creates JAR file.
**Why**: 
- `clean`: removes old build artifacts
- `package`: compiles, tests (skipped), and packages into JAR
- Creates `target/stock-management-1.0.0.jar`

#### Line 48: `RUN ls -la target/*.jar`
**What**: Lists the created JAR file.
**Why**: Verifies build succeeded - fails early if JAR wasn't created.

---

### Stage 2: Runtime Stage (Lines 50-114)

#### Line 59: `FROM eclipse-temurin:17-jre-alpine`
**What**: Starts fresh with minimal Java 17 runtime.
**Why**: 
- **Alpine**: Tiny Linux (~5MB base)
- **JRE**: Only runtime, not development tools
- **Result**: ~150MB vs ~500MB for full JDK
- **Security**: Smaller = fewer vulnerabilities

#### Lines 63-65: `LABEL` commands
**What**: Adds metadata to the image.
**Why**: Documentation - can view with `docker inspect`.

#### Line 70: `RUN addgroup -S spring && adduser -S spring -G spring`
**What**: Creates a non-root user named "spring".
**Why**: Security best practice - if container is compromised, attacker doesn't have root access.

#### Line 73: `WORKDIR /app`
**What**: Sets working directory.
**Why**: Application runs from `/app` directory.

#### Line 78: `COPY --from=builder /app/target/stock-management-1.0.0.jar app.jar`
**What**: Copies only the JAR file from build stage.
**Why**: 
- `--from=builder`: copies from previous stage
- We only need the JAR, not source code or build tools
- Renames to `app.jar` for simplicity

#### Lines 82-84: `RUN mkdir -p ... && chown -R spring:spring ...`
**What**: Creates directories and sets ownership.
**Why**: 
- Application needs to write files (database, uploads, logs)
- `chown`: gives ownership to spring user
- User can write to these directories

#### Line 88: `USER spring`
**What**: Switches to non-root user.
**Why**: Application runs without root privileges (security).

#### Line 93: `EXPOSE 8080`
**What**: Documents that app uses port 8080.
**Why**: 
- Documentation for developers
- Deployment tools (like Render) read this
- Doesn't actually open the port (that's done at runtime)

#### Lines 97-99: `ENV` commands
**What**: Sets default environment variables.
**Why**: 
- `JAVA_OPTS`: Limits memory (512MB max, 256MB initial)
- `SPRING_PROFILES_ACTIVE`: Activates production profile
- `PORT`: Default port (Render will override)
- Can be overridden at runtime

#### Lines 106-107: `HEALTHCHECK`
**What**: Checks if application is healthy every 30 seconds.
**Why**: 
- Docker/Render can detect crashes
- Automatic restart on failure
- Load balancers route only to healthy instances
- `wget --spider`: checks if endpoint responds (doesn't download)

#### Line 114: `ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]`
**What**: Command that runs when container starts.
**Why**: 
- `java -jar`: runs Spring Boot application
- `$JAVA_OPTS`: applies memory settings
- `${PORT:-8080}`: uses PORT env var, defaults to 8080
- `-Dserver.port`: sets Spring Boot port dynamically
- `sh -c`: allows variable expansion

---

## 🔍 Key Concepts Explained

### Multi-Stage Build
**What**: Two separate stages - one for building, one for running.
**Why**: 
- Builder stage: Has Maven, JDK, source code (~800MB)
- Runtime stage: Only JRE and JAR (~150MB)
- **Result**: 5x smaller final image!

### Layer Caching
**What**: Docker caches each step (layer).
**Why**: 
- If `pom.xml` doesn't change → dependencies aren't re-downloaded
- If only source code changes → dependencies layer is reused
- **Result**: Faster builds!

### Alpine Linux
**What**: Minimal Linux distribution.
**Why**: 
- Uses `musl libc` instead of `glibc` (smaller)
- No unnecessary packages
- **Result**: ~5MB base vs ~100MB for Ubuntu

### Non-Root User
**What**: Application runs as regular user, not root.
**Why**: 
- If container is compromised, attacker has limited access
- Can't modify system files
- **Result**: Better security!

### Health Check
**What**: Docker periodically checks if app is responding.
**Why**: 
- Detects crashes automatically
- Can trigger restarts
- Load balancers can route traffic intelligently

---

## 📊 Size Comparison

| Component | Size | Included? |
|-----------|------|-----------|
| Maven | ~200MB | ❌ (only in builder) |
| JDK | ~300MB | ❌ (only in builder) |
| Source Code | ~10MB | ❌ (only in builder) |
| JRE (Alpine) | ~150MB | ✅ (runtime) |
| JAR File | ~50MB | ✅ (runtime) |
| **Total Builder** | **~800MB** | Discarded |
| **Total Runtime** | **~150MB** | Final image |

**Savings**: 650MB smaller final image!

---

## 🎯 Best Practices Used

✅ **Multi-stage build** - Reduces final image size  
✅ **Layer caching** - Optimizes build speed  
✅ **Alpine base** - Minimal attack surface  
✅ **Non-root user** - Security best practice  
✅ **Health check** - Automatic failure detection  
✅ **Dynamic PORT** - Render compatibility  
✅ **Memory limits** - Prevents OOM errors  
✅ **Environment variables** - Flexible configuration  

---

## 🚀 Quick Reference

**Build**: `docker build -t app:latest .`  
**Run**: `docker run -p 8080:8080 -e JWT_SECRET=secret app:latest`  
**Size**: ~150MB final image  
**Port**: 8080 (configurable via PORT env var)  
**User**: spring (non-root)  
**Health**: Checks `/api/reports/summary` every 30s  

---

For deployment instructions, see `DOCKER_GUIDE.md`!

