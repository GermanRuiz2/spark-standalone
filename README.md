# Práctica: Spark Standalone

**Materia:** Manejo Masivo de Datos — Universidad Politécnica de Querétaro
**Alumno:** _Nombre completo — Matrícula_

Esta práctica es una introducción a **Apache Spark**, una herramienta que sirve para procesar muchos datos de forma rápida. Spark reparte el trabajo en pedazos y los procesa al mismo tiempo, en lugar de uno por uno, y guarda los datos en la memoria de la computadora mientras trabaja, lo que lo hace mucho más rápido que otras herramientas.

Todo se hizo con **Python** dentro de **Jupyter Notebook** (una libreta donde se escribe y ejecuta código por bloques). Para no tener que instalar nada a mano, se usó **Docker**, que permite descargar un "paquete" con todo lo necesario ya listo para usarse.

---

## ¿Qué hay en este repositorio?

| Archivo o carpeta | Qué contiene |
|---|---|
| `Practica_Spark.ipynb` | Primeras pruebas: cómo se inicia Spark y cómo se configura. |
| `PrimerPrograma.ipynb` | El primer programa ("Hola Spark"), el panel de monitoreo de Spark y el ejemplo de ventas por país. |
| `Ejercicios_Practicos.ipynb` | Los 7 ejercicios de la práctica. |
| `ProyectoFinal.ipynb` | El proyecto final: análisis completo del archivo `stocks.txt`. |
| `DATOS/` | Los archivos de datos que se descargaron para trabajar. |
| `RESULTADOS/` | Los resultados que guardó el proyecto final. |
| `comandos.sh` | Todos los comandos usados para preparar el entorno, en un solo lugar. |

---

## Proyecto final: análisis de `stocks.txt`

El proyecto junta todo lo aprendido en un solo análisis, dividido en 6 pasos:

1. **Cargar el archivo.** Se inició Spark y se leyó el archivo `stocks.txt`.
2. **Limpiar los datos.** Cada línea se separó en sus partes (nombre, categoría, cantidad y precio). Las líneas que no se podían leer bien, como la de los títulos, se descartaron. Quedaron **30 registros válidos**.
3. **Estadísticas por categoría.** Para cada categoría se calculó el precio más alto, el más bajo y el promedio.
4. **Lo más vendido.** Se sumaron las cantidades y se ordenaron de mayor a menor para obtener el top 10.
5. **Variación de precios.** Para cada categoría se midió qué tan grande es la diferencia entre su producto más caro y su producto más barato (en porcentaje). A esto la práctica le llama "volatilidad".
6. **Guardar y resumir.** Los resultados se guardaron en la carpeta `RESULTADOS/` y se mostró un resumen final.

### Un detalle importante sobre el archivo

La práctica decía que `stocks.txt` tendría datos de acciones de la bolsa (símbolo, fecha, precio y volumen). Pero el archivo que se descarga en realidad es un **inventario de 30 productos** con estas columnas: `id, name, category, quantity, price`.

Por eso se hizo una pequeña adaptación: se cambió **solo la parte que lee cada línea** para que tomara las columnas correctas. El resto del análisis se dejó igual:

| Lo que pedía la práctica | Lo que se usó del archivo real |
|---|---|
| Símbolo | Categoría (`category`) |
| Fecha | Nombre del producto (`name`) |
| Precio | Precio (`price`) |
| Volumen | Cantidad (`quantity`) |

### Resultados

| Categoría | Precio más alto | Precio más bajo | Promedio | Cantidad total | Variación |
|---|---|---|---|---|---|
| Accessories | $29.99 | $24.99 | $27.49 | 55 | 20.01 % |
| Clothing | $199.99 | $14.99 | $99.28 | 200 | 1234.16 % |
| Electronics | $1299.99 | $129.99 | $586.66 | 98 | 900.07 % |
| Food | $5.99 | $0.25 | $2.30 | 450 | 2296.00 % |
| Furniture | $249.99 | $79.99 | $141.99 | 41 | 212.53 % |
| Sports | $49.99 | $19.99 | $34.99 | 35 | 150.08 % |

**Resumen final:**
- Registros procesados: **30**
- Categorías distintas: **6**
- Categoría con el precio promedio más alto: **Electronics ($586.66)**
- Producto con más unidades: **Bananas (150)**
- Categoría con más variación de precios: **Food (2296 %)**, porque va desde $0.25 (plátanos) hasta $5.99 (salmón).

---

## Ejercicios (resumen)

Antes del proyecto se resolvieron 7 ejercicios cortos:

1. **Configurar Spark** con un nombre propio y ajustes de memoria.
2. **Operaciones básicas:** contar, sumar y encontrar el mayor y el menor de una lista de números.
3. **Transformar y filtrar:** multiplicar números por 3 y quedarse solo con los mayores a 50.
4. **Agrupar por producto:** sumar las ventas de cada producto y encontrar el que más vendió.
5. **Leer un archivo CSV:** buscar a las personas mayores de 30 años en `persons.csv`. Ese archivo también era distinto al que describía la práctica, pero el código funcionó igual y encontró **10 personas**.
6. **Hacer el código más rápido:** separar cada línea una sola vez en lugar de tres.
7. **Encontrar y corregir errores** en un código que venía mal escrito.

---

## Preguntas de reflexión

### 1. Eficiencia: ¿Por qué es importante hacer split() una sola vez por línea? ¿Cuánto tiempo ahorrarías con 1 millón de líneas?

Cada split recorre la cadena y crea una lista nueva en memoria. Si se hace dos o tres veces por línea, pues ese trabajo se multiplica sin aportar nada, porque el resultado es el mismo.

Con muchas líneas, hacer split dos veces implica hacer el doble de trabajo , y con tres splits, el triple. Hacerlo una sola vez ahorra aproximadamente la mitad del tiempo del parseo, además reduce la memoria temporal y tambien el trabajo del recolector de basura.

### 2. Particionamiento: ¿Cuántas particiones tiene tu RDD? ¿Cómo afecta esto al rendimiento? ¿Qué pasaría si tuvieras solo 1 partición?

Depende de cómo se crea el RDD. Con el parallelizre sin indicar particiones se obtuvieron 12 (una por núcleo; se ve en los 12/12 tasks de Spark UI). Con textFile sobre archivos pequeños, Spark crea por defecto 2 particiones (por eso el stage de reduceByKey muestra 2/2 tasks). Se puede comprobar con `rdd.getNumPartitions()`.

Cada partición es una tarea que puede ejecutarse en paralelo, así que más particiones aprovechan más núcleos, hasta cierto límite: demasiadas particiones pequeñas agregan sobrecarga de planificación.

Con 1 sola partición no hay paralelismo: todo se procesa en una tarea y un solo núcleo, como un programa secuencial, y se pierde la ventaja de Spark.

### 3. Lazy Evaluation: ¿En qué momento se ejecutaron realmente las transformaciones? ¿Qué ventajas tiene este modelo?

Las transformaciones solo construyen un plan de ejecución. Se ejecutaron hasta que se llamó a una acción, como las de `count()`, `take()`, `collect()`, `sum()`, `first()` o `saveAsTextFile()`.

Spark UI lo confirma: cada job lleva el nombre de una acción, nunca de una transformación.

**Ventajas:** Spark ve el plan completo y lo optimiza; encadena map y filter en un mismo stage sin crear resultados intermedios, no calcula lo que nunca se usa y puede reconstruir particiones perdidas a partir del linaje, lo que le da tolerancia a fallos.

### 4. Memoria: ¿Qué pasaría si intentaras hacer collect() en un RDD de 10GB? ¿Cómo evitarías este problema?

collect trae todos los datos al Driver. Con 10 GB y un Driver configurado con 1 o 2 GB, se produciría un error de memoria (OutOfMemoryError / Py4JJavaError) y la aplicación fallaría.

Para evitarlo: usar `take(n)` para ver una muestra; usar `count()` u otras agregaciones (`reduceByKey`) y traer solo el resultado reducido; o guardar el resultado en disco o HDFS con `saveAsTextFile()` sin pasar por ese Driver como tal.

### 5. Optimización: Si tuvieras que procesar 100x más datos, ¿qué cambiarías en tu código? ¿Usarías más particiones? ¿Cachearías algún RDD?

**Más particiones:** sí usaría más, con los comandos de: `sc.textFile(ruta, minPartitions)` o `repartition()`, para repartir la carga entre más núcleos o nodos.

**Cache:** Si, ya que algunas variables se reutilizan en los diversos pasos, y sin cache cada acción vuelve a leer y parsear el archivo desde el inicio. Cachearlos evita repetir ese trabajo.

**Que cambiaria:** Se podrian agregar calculos de máximo, mínimo y promedio en un solo aggregateByKey en lugar de tres recorridos. Migraría quizá a DataFrames, o aumentar la memoria de los executors.

### 6. HDFS vs Local: ¿Cuáles son las ventajas de usar HDFS en lugar de archivos locales para este análisis?

- **Distribución:** HDFS divide los archivos en bloques repartidos entre nodos, y cada bloque puede procesarse en paralelo como una partición.
- **Tolerancia a fallos:** los bloques están replicados; si un nodo falla, Spark lee otra réplica automáticamente.
- **Localidad de datos:** Spark envía las tareas a los nodos donde ya están los datos, lo que reduce el tráfico de red.
- **Acceso compartido y escalabilidad:** con `file://`, el archivo tendría que existir en la misma ruta en cada nodo del clúster; HDFS ofrece un único sistema de archivos accesible para todos y escala a volúmenes que no caben en un solo equipo.

---

## Cómo replicar

Estos son los pasos que se siguieron para preparar el entorno, desde abrir Docker hasta crear la libreta de trabajo. Se hicieron en **Windows**.

### Lo que necesitas

- **Docker Desktop** instalado.
- Un navegador web (Chrome, Edge, etc.).
- Conexión a internet (la primera vez se descargan algunos GB).

### Paso 1. Abrir Docker Desktop

Abre Docker Desktop y espera a que diga **"Engine running"**. Eso significa que ya está listo.

### Paso 2. Abrir una terminal

Abre **PowerShell**, o la terminal de VS Code (menú *Terminal → New Terminal*). Para confirmar que Docker funciona, escribe:

```powershell
docker --version
```

Si aparece un número de versión, todo está bien.

### Paso 3. Crear la carpeta de trabajo

Ve a la ubicación donde quieras guardar la práctica (por ejemplo, Documentos) y crea una carpeta nueva:

```powershell
mkdir spark-local
cd spark-local
```

> Si descargaste este repositorio, no necesitas crear la carpeta: entra a la carpeta del repositorio con `cd` y continúa con el paso 4.

### Paso 4. Iniciar el contenedor con Spark y Jupyter

Copia y pega este comando **en una sola línea**:

```powershell
docker run -it -p 8888:8888 -p 4040:4040 -v ${PWD}:/home/jovyan/work/projects/ jupyter/pyspark-notebook
```

En palabras simples, este comando:

- **Descarga y abre** un paquete que ya trae Python, Spark y Jupyter instalados. La primera vez tarda unos minutos.
- **Abre la puerta 8888** para entrar a Jupyter desde el navegador.
- **Abre la puerta 4040** para ver el panel de monitoreo de Spark.
- **Conecta tu carpeta** con el contenedor, para que todo lo que guardes aparezca en tu computadora y no se pierda al cerrar.

> Si usas el **Símbolo del sistema (CMD)** en lugar de PowerShell, cambia `${PWD}` por `%cd%`.

### Paso 5. Entrar a Jupyter

Cuando termine de cargar, la terminal mostrará un enlace parecido a este:

```
http://127.0.0.1:8888/lab?token=abc123...
```

Copia el enlace **completo** (incluyendo la parte de `token`) y ábrelo en tu navegador.

### Paso 6. Crear la libreta (notebook)

1. En el panel izquierdo de Jupyter, entra a la carpeta **`work`** y luego a **`projects`**.
   *Es importante hacerlo ahí, porque esa es la carpeta conectada a tu computadora.*
2. Haz clic en **File → New → Notebook** (o en el botón **Python 3** de la pantalla de inicio).
3. Si te pregunta, elige **Python 3 (ipykernel)**.
4. Cambia el nombre de la libreta haciendo clic derecho sobre ella → **Rename**.

Listo: ya puedes escribir y ejecutar código de Spark. Si descargaste este repositorio, en esa misma carpeta verás las cuatro libretas de la práctica y puedes abrirlas directamente.

### Ver el panel de Spark

Mientras una libreta tenga Spark activo, puedes abrir **http://localhost:4040** en el navegador para ver qué trabajos se ejecutaron y cuánto tardaron.

### Para cerrar todo

En la terminal donde está corriendo Docker, presiona **Ctrl + C** (dos veces si lo pide). Tus archivos se quedan guardados en la carpeta.

---

## Datos utilizados

Los archivos de datos provienen del repositorio de prácticas del curso: <https://github.com/josepgarcia/datos>

- `pdi_sales_small.csv`: ventas por país (ejemplo de la práctica).
- `persons.csv`: personas con edad, género y salario (ejercicio 5).
- `stocks.txt`: inventario de productos (proyecto final).
