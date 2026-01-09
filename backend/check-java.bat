@echo off
echo ========================================
echo Java Version Checker
echo ========================================
echo.

echo Current Java version:
java -version
echo.

echo Current JAVA_HOME:
echo %JAVA_HOME%
echo.

echo Searching for Java 17 installations...
echo.

if exist "C:\Program Files\Eclipse Adoptium\jdk-17*" (
    echo Found Java 17 in: C:\Program Files\Eclipse Adoptium\
    dir "C:\Program Files\Eclipse Adoptium\jdk-17*" /b
    echo.
    echo To use Java 17, set JAVA_HOME to one of these paths
) else (
    echo Java 17 not found in default location
)

if exist "C:\Program Files\Java\jdk-17*" (
    echo Found Java 17 in: C:\Program Files\Java\
    dir "C:\Program Files\Java\jdk-17*" /b
    echo.
    echo To use Java 17, set JAVA_HOME to one of these paths
) else (
    echo Java 17 not found in C:\Program Files\Java\
)

echo.
echo ========================================
echo Recommendation
echo ========================================
echo.
echo Your current Java version may be incompatible.
echo Please install Java 17 from: https://adoptium.net/temurin/releases/?version=17
echo.
echo After installing, set JAVA_HOME to point to Java 17
echo.
pause

