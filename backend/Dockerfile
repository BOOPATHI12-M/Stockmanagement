# ============================================
# Stage 1: Build Stage
# This stage compiles the Java code and creates the JAR file
# ============================================

# Use Maven image with Java 17 for building
# maven:3.9-eclipse-temurin-17 is an official Maven image with Java 17
# eclipse-temurin is the recommended OpenJDK distribution
FROM maven:3.9-eclipse-temurin-17 AS builder

# Set the working directory inside the container
# All subsequent commands will run in this directory
WORKDIR /app

# Copy the pom.xml file first
# This is done before copying source code to leverage Docker layer caching
# If pom.xml doesn't change, Docker can reuse cached layers
COPY pom.xml .

# Download dependencies using Maven from the base image
# This step is cached separately - if dependencies don't change, this layer is reused
# -B runs in batch mode (non-interactive)
# -DskipTests skips tests during dependency download (faster)
# Using 'mvn' directly from the base image (Maven is pre-installed)
RUN mvn dependency:go-offline -B -DskipTests

# Copy the source code
# Now we copy all source files
COPY src ./src

# Build the application and create the JAR file
# -B: batch mode (non-interactive)
# -DskipTests: skip tests (run tests separately in CI/CD if needed)
# package: Maven goal that compiles, tests, and packages the application
RUN mvn clean package -B -DskipTests

# Verify the JAR file was created
# This helps catch build failures early
RUN ls -la target/*.jar

# ============================================
# Stage 2: Runtime Stage
# This stage creates a minimal image with only what's needed to run the app
# ============================================

# Use a minimal Java 17 runtime image
# eclipse-temurin:17-jre-alpine is much smaller than the full JDK
# alpine uses musl libc and is very lightweight (~150MB vs ~500MB for full JDK)
# jre (Java Runtime Environment) doesn't include compiler tools, only runtime
FROM eclipse-temurin:17-jre-alpine

# Add metadata to the image
# LABEL adds metadata that can be inspected with docker inspect
LABEL maintainer="Sudharshini Stock Management"
LABEL description="Spring Boot Stock Management Application"
LABEL version="1.0.0"

# Create a non-root user for security
# Running as root is a security risk - if container is compromised, attacker has root access
# -D means no password, -S means no shell (more secure)
RUN addgroup -S spring && adduser -S spring -G spring

# Set the working directory
WORKDIR /app

# Copy the JAR file from the builder stage
# --from=builder means copy from the previous stage
# The JAR file is the only thing we need from the build stage
COPY --from=builder /app/target/stock-management-1.0.0.jar app.jar

# Create directories for application data
# These directories will be used by the application at runtime
RUN mkdir -p /tmp/uploads/products && \
    mkdir -p /tmp && \
    chown -R spring:spring /app /tmp

# Switch to the non-root user
# This ensures the application doesn't run with root privileges
USER spring

# Expose the port the application will run on
# EXPOSE is documentation - it doesn't actually publish the port
# Render will map this to the PORT environment variable
EXPOSE 8080

# Set environment variables with defaults
# These can be overridden at runtime
ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE=production \
    PORT=8080

# Health check
# Docker will periodically check if the application is healthy
# curl checks if the application responds (adjust endpoint as needed)
# --fail: fail silently on server errors
# --max-time: timeout after 10 seconds
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/api/reports/summary || exit 1

# Run the application
# java -jar runs the Spring Boot JAR file
# ${PORT} uses the environment variable (Render provides this)
# -Dserver.port sets the Spring Boot server port dynamically
# The application.properties already has server.port=${PORT:8080}, but this ensures it works
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]

