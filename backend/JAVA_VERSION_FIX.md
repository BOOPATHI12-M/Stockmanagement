# Java 24 Compatibility Fix

## Issue
You have Java 24 installed, which may cause compatibility issues with Lombok and some Maven plugins.

## Solution 1: Use Java 17 or 21 (Recommended)

Java 17 and 21 are LTS (Long Term Support) versions and have better compatibility.

### Install Java 17:
1. Download from: https://adoptium.net/temurin/releases/
2. Install Java 17
3. Set JAVA_HOME:
   ```cmd
   setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.x"
   setx PATH "%JAVA_HOME%\bin;%PATH%"
   ```
4. Restart terminal and verify:
   ```cmd
   java -version
   ```

## Solution 2: Keep Java 24 (Current Fix Applied)

I've updated the `pom.xml` to add compiler arguments that should help with Java 24 compatibility.

### Try this:
```cmd
cd backend
mvn clean
mvn clean compile
```

If it still fails, try:
```cmd
mvn clean compile -Dmaven.compiler.release=17
```

## Solution 3: Use Maven Toolchains

Create `~/.m2/toolchains.xml`:
```xml
<?xml version="1.0" encoding="UTF8"?>
<toolchains>
  <toolchain>
    <type>jdk</type>
    <provides>
      <version>17</version>
    </provides>
    <configuration>
      <jdkHome>C:\Program Files\Eclipse Adoptium\jdk-17.0.x</jdkHome>
    </configuration>
  </toolchain>
</toolchains>
```

Then add to `pom.xml`:
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-toolchains-plugin</artifactId>
    <version>3.1.0</version>
    <configuration>
        <toolchains>
            <jdk>
                <version>17</version>
            </jdk>
        </toolchains>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>toolchain</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## Quick Test

Run the fix script:
```cmd
cd backend
compile-fix.bat
```

Or manually:
```cmd
cd backend
mvn clean
mvn clean compile -Dmaven.compiler.release=17
```

## If All Else Fails

Remove Lombok temporarily and use manual getters/setters. See `FIX_COMPILATION_ERROR.md` for details.

