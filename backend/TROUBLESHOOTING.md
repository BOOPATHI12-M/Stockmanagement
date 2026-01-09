# Troubleshooting Compilation Errors

## Error: java.lang.ExceptionInInitializerError - TypeTag::UNKNOWN

This error is typically caused by:
1. Java version mismatch
2. Lombok annotation processor not configured
3. Maven compiler plugin issues

### Solution Steps:

1. **Clean and Rebuild:**
```bash
cd backend
mvn clean
mvn clean install
```

2. **Verify Java Version:**
```bash
java -version
# Should show Java 17 or higher
javac -version
# Should match Java version
```

3. **If using IDE (IntelliJ/Eclipse):**
   - Invalidate caches and restart
   - Ensure IDE is using Java 17
   - Reimport Maven project

4. **Check Maven Configuration:**
```bash
mvn -version
# Should show Maven 3.6+ and Java 17
```

5. **If error persists, try:**
```bash
# Delete target directory
rm -rf target

# Delete .m2 cache (optional, last resort)
# rm -rf ~/.m2/repository/com/sudharshini

# Rebuild
mvn clean install -U
```

6. **For Lombok issues specifically:**
   - Ensure Lombok plugin is installed in your IDE
   - Enable annotation processing in IDE settings
   - Restart IDE after enabling

### Alternative: Use Java 11 (if Java 17 not available)

If you must use Java 11, update `pom.xml`:
```xml
<properties>
    <java.version>11</java.version>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
</properties>
```

And update Spring Boot version to 2.7.x (compatible with Java 11).

