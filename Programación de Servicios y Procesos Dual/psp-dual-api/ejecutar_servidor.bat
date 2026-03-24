@echo off
setlocal

:: Configuración de versión
set "MAVEN_VERSION=3.9.6"
set "MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/%MAVEN_VERSION%/binaries/apache-maven-%MAVEN_VERSION%-bin.zip"
set "INSTALL_DIR=%~dp0.mvn_auto"
set "MAVEN_BIN=%INSTALL_DIR%\apache-maven-%MAVEN_VERSION%\bin"

echo ==========================================
echo   Iniciando Servidor Spring Boot
echo ==========================================

:: 1. Intentar detectar Java en el sistema
java -version >nul 2>&1
if %errorlevel% equ 0 goto :java_found

:: 2. Si no está en PATH, buscar en JAVA_HOME
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        set "PATH=%JAVA_HOME%\bin;%PATH%"
        goto :java_found
    )
)

:: 3. Buscar en ubicaciones comunes (específico para este usuario)
set "POTENTIAL_JAVA=C:\Users\rossi\.jdks\ms-17.0.18"
if exist "%POTENTIAL_JAVA%\bin\java.exe" (
    echo [INFO] Java encontrado en: %POTENTIAL_JAVA%
    set "JAVA_HOME=%POTENTIAL_JAVA%"
    set "PATH=%POTENTIAL_JAVA%\bin;%PATH%"
    goto :java_found
)

:: Si llegamos aqui, no se encontró Java
echo [ERROR] Java no se encuentra instalado o no se pudo autodetectar.
echo Por favor, instala el JDK o asegúrate de que está en tu PATH.
pause
exit /b 1

:java_found
echo [INFO] Usando Java:
java -version

:: 4. Verificar si Maven está instalado (debería estarlo si ejecutaste el script anterior)
if not exist "%MAVEN_BIN%\mvn.cmd" (
    echo [INFO] Maven no encontrado localmente. Descargando Maven %MAVEN_VERSION%...
    if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
    
    powershell -Command "Invoke-WebRequest -Uri '%MAVEN_URL%' -OutFile '%INSTALL_DIR%\maven.zip'"
    
    echo [INFO] Extrayendo Maven...
    powershell -Command "Expand-Archive -Path '%INSTALL_DIR%\maven.zip' -DestinationPath '%INSTALL_DIR%' -Force"
    
    if exist "%INSTALL_DIR%\maven.zip" del "%INSTALL_DIR%\maven.zip"
    echo [INFO] Maven instalado en %INSTALL_DIR%
)

:: Configurar entorno para esta sesión
set "PATH=%MAVEN_BIN%;%PATH%"

echo.
echo [INFO] Iniciando la aplicación...
echo [INFO] La aplicación estará disponible en: https://localhost:8443
echo [INFO] H2 Console: https://localhost:8443/h2-console
echo.

call mvn spring-boot:run

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] La aplicación falló al iniciar.
    pause
    exit /b 1
)

pause
