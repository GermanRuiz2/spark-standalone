#!/bin/bash
# =============================================================
# Práctica: Spark Standalone — Comandos utilizados
# Entorno: Windows + Docker Desktop (terminal: PowerShell)
# =============================================================

# -------------------------------------------------------------
# 1. Preparar el entorno (en la terminal de Windows)
# -------------------------------------------------------------

# Verificar que Docker esté funcionando
docker --version

# Crear la carpeta de trabajo y entrar a ella
mkdir spark-local
cd spark-local

# Iniciar el contenedor con Jupyter + PySpark
# (PowerShell)
docker run -it -p 8888:8888 -p 4040:4040 -v ${PWD}:/home/jovyan/work/projects/ jupyter/pyspark-notebook

# (CMD de Windows)
# docker run -it -p 8888:8888 -p 4040:4040 -v %cd%:/home/jovyan/work/projects/ jupyter/pyspark-notebook

# (Linux / macOS)
# docker run -it -p 8888:8888 -p 4040:4040 -v $(pwd):/home/jovyan/work/projects/ jupyter/pyspark-notebook

# Accesos:
#   Jupyter:  http://127.0.0.1:8888/lab?token=...   (copiar el enlace que aparece en la terminal)
#   Spark UI: http://localhost:4040                  (solo mientras haya una sesión de Spark activa)

# -------------------------------------------------------------
# 2. Descarga de datos (dentro de las celdas del notebook,
#    con "!" al inicio para ejecutarlos como comandos)
# -------------------------------------------------------------

# !mkdir -p DATOS
# !wget "https://github.com/josepgarcia/datos/raw/refs/heads/main/pdi_sales_small.csv" -P ./DATOS
# !wget "https://github.com/josepgarcia/datos/raw/refs/heads/main/persons.csv" -P ./DATOS
# !wget "https://github.com/josepgarcia/datos/raw/refs/heads/main/stocks.txt" -P ./DATOS
# !head ./DATOS/stocks.txt

# -------------------------------------------------------------
# 3. Carpeta de resultados del proyecto (dentro del notebook)
# -------------------------------------------------------------

# !mkdir -p RESULTADOS
# Si se vuelve a ejecutar el proyecto, borrar antes los resultados anteriores:
# !rm -rf RESULTADOS/volumen_por_fecha RESULTADOS/stats_por_simbolo

# -------------------------------------------------------------
# 4. Detener el contenedor
# -------------------------------------------------------------

# En la terminal donde corre Docker: Ctrl + C
