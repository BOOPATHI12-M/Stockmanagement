@echo off
echo ========================================
echo Fixing Compilation Error
echo ========================================
echo.

echo Step 1: Checking Java version...
java -version
if %errorlevel% neq 0 (
    echo ERROR: Java not found! Please install Java 17+
    pause
    exit /b 1
)
echo.

echo Step 2: Cleaning previous builds...
call mvn clean
if %errorlevel% neq 0 (
    echo ERROR: Maven clean failed!
    pause
    exit /b 1
)
echo.

echo Step 3: Removing target directory...
if exist target rmdir /s /q target
echo.

echo Step 4: Updating dependencies...
call mvn dependency:resolve -U
if %errorlevel% neq 0 (
    echo ERROR: Dependency resolution failed!
    pause
    exit /b 1
)
echo.

echo Step 5: Compiling project...
call mvn clean compile
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo COMPILATION FAILED
    echo ========================================
    echo.
    echo Try these solutions:
    echo 1. Ensure Java 17 is installed and JAVA_HOME is set
    echo 2. Install Lombok plugin in your IDE
    echo 3. Enable annotation processing in IDE settings
    echo 4. See FIX_COMPILATION_ERROR.md for more solutions
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo COMPILATION SUCCESSFUL!
echo ========================================
echo.
echo You can now run: mvn spring-boot:run
echo.
pause

