@echo off
setlocal

:: Configuración de versión
set "MAVEN_VERSION=3.9.6"
set "MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/%MAVEN_VERSION%/binaries/apache-maven-%MAVEN_VERSION%-bin.zip"
set "INSTALL_DIR=%~dp0.mvn_auto"
set "MAVEN_BIN=%INSTALL_DIR%\apache-maven-%MAVEN_VERSION%\bin"

echo ==========================================
echo   Instalador Automatico de Dependencias
echo ==========================================

:: 1. Intentar detectar Java en el sistema
java -version >nul 2>&1
if %errorlevel% equ 0 goto :java_found

:: 2. Si no esta en PATH, buscar en JAVA_HOME
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        set "PATH=%JAVA_HOME%\bin;%PATH%"
        goto :java_found
    )
)

:: 3. Buscar en ubicaciones comunes (especifico para este usuario)
set "POTENTIAL_JAVA=C:\Users\rossi\.jdks\ms-17.0.18"
if exist "%POTENTIAL_JAVA%\bin\java.exe" (
    echo [INFO] Java encontrado en: %POTENTIAL_JAVA%
    set "JAVA_HOME=%POTENTIAL_JAVA%"
    set "PATH=%POTENTIAL_JAVA%\bin;%PATH%"
    goto :java_found
)

:: Si llegamos aqui, no se encontro Java
echo [ERROR] Java no se encuentra instalado o no se pudo autodetectar.
echo Por favor, instala el JDK o asegurate de que esta en tu PATH.
pause
exit /b 1

:java_found
echo [INFO] Usando Java:
java -version

:: 4. Descargar e instalar Maven si no existe
if not exist "%MAVEN_BIN%\mvn.cmd" (
    echo [INFO] Maven no encontrado localmente. Descargando Maven %MAVEN_VERSION%...
    if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
    
    powershell -Command "Invoke-WebRequest -Uri '%MAVEN_URL%' -OutFile '%INSTALL_DIR%\maven.zip'"
    
    echo [INFO] Extrayendo Maven...
    powershell -Command "Expand-Archive -Path '%INSTALL_DIR%\maven.zip' -DestinationPath '%INSTALL_DIR%' -Force"
    
    if exist "%INSTALL_DIR%\maven.zip" del "%INSTALL_DIR%\maven.zip"
    echo [INFO] Maven instalado en %INSTALL_DIR%
) else (
    echo [INFO] Maven local ya existe. Usando version existente.
)

:: Configurar entorno para esta sesion
set "PATH=%MAVEN_BIN%;%PATH%"

echo.
echo [INFO] Verificando version de Maven...
call mvn -version

echo.
echo [INFO] Descargando todas las dependencias del proyecto (incluyendo plugins)...
:: Usamos go-offline para descargar dependencias y plugins necesarios
call mvn dependency:go-offline

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Hubo un problema al descargar las dependencias. Revisa los logs arriba.
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   Proceso completado con Exito!
echo   Todas las dependencias estan descargadas.
echo ==========================================
pause
