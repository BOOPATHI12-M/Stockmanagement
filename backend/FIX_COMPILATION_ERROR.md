# Fix: ExceptionInInitializerError - TypeTag::UNKNOWN

## Quick Fix Steps

### Step 1: Clean Everything
```bash
cd backend
mvn clean
rm -rf target
rm -rf .mvn
```

### Step 2: Verify Java Version
```bash
java -version
# Must show: java version "17" or higher
# If not, install Java 17+

javac -version
# Must match Java version
```

### Step 3: Set JAVA_HOME (if not set)
**Windows:**
```cmd
set JAVA_HOME=C:\Program Files\Java\jdk-17
set PATH=%JAVA_HOME%\bin;%PATH%
```

**Linux/Mac:**
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH
```

### Step 4: Rebuild
```bash
mvn clean install -U
```

## If Still Failing - Try These Solutions

### Solution 1: Remove Lombok (Temporary)
If Lombok is causing issues, we can remove it temporarily:

1. Comment out Lombok dependency in `pom.xml`
2. Manually add getters/setters to entities
3. Rebuild

### Solution 2: Use Different Lombok Version
Try Lombok 1.18.26 (more stable):
```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.26</version>
    <scope>provided</scope>
</dependency>
```

### Solution 3: IDE-Specific Fixes

**IntelliJ IDEA:**
1. File → Settings → Build, Execution, Deployment → Compiler → Annotation Processors
2. Enable "Enable annotation processing"
3. File → Invalidate Caches → Invalidate and Restart
4. File → Project Structure → Project → Set SDK to Java 17
5. Maven → Reload Project

**Eclipse:**
1. Project → Properties → Java Build Path → Libraries
2. Remove and re-add JRE System Library (Java 17)
3. Project → Clean → Clean all projects
4. Project → Properties → Java Compiler → Set to 17

**VS Code:**
1. Install "Language Support for Java" extension
2. Install "Lombok Annotations Support" extension
3. Reload window

### Solution 4: Maven Wrapper
Use Maven wrapper to ensure consistent Maven version:
```bash
mvnw clean install
```

### Solution 5: Check for Conflicting Dependencies
```bash
mvn dependency:tree
# Look for conflicting versions
```

## Alternative: Downgrade to Java 11

If Java 17 is not available, update `pom.xml`:

```xml
<properties>
    <java.version>11</java.version>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
</properties>
```

And change Spring Boot version to 2.7.18:
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.18</version>
</parent>
```

## Still Not Working?

1. **Check Maven version:**
   ```bash
   mvn -version
   # Should be 3.6.3 or higher
   ```

2. **Clear Maven cache:**
   ```bash
   rm -rf ~/.m2/repository/org/projectlombok
   mvn clean install -U
   ```

3. **Try without Lombok:**
   - Remove `@Data`, `@NoArgsConstructor`, `@AllArgsConstructor`
   - Add manual getters/setters
   - Rebuild

4. **Check for special characters in paths:**
   - Ensure project path has no spaces or special characters
   - Try moving project to `C:\projects\stock-management`

## Verify Fix

After applying fixes, verify:
```bash
mvn clean compile
# Should complete without errors
```

If compilation succeeds, run:
```bash
mvn spring-boot:run
```

