# ============================================
# Stage 1: Build Stage
# ============================================
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy pom.xml (from backend)
COPY backend/pom.xml .
RUN mvn dependency:go-offline -B -DskipTests

# Copy source code
COPY backend/src ./src

# Build JAR
RUN mvn clean package -B -DskipTests
RUN ls -la target/*.jar

# ============================================
# Stage 2: Runtime Stage
# ============================================
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="Sudharshini Stock Management"
LABEL description="Spring Boot Stock Management Application"
LABEL version="1.0.0"

RUN addgroup -S spring && adduser -S spring -G spring
WORKDIR /app

# Copy JAR safely
COPY --from=builder /app/target/*.jar app.jar

RUN mkdir -p /tmp/uploads/products && \
    chown -R spring:spring /app /tmp

USER spring
EXPOSE 8080

ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE=production \
    PORT=8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/ || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]
