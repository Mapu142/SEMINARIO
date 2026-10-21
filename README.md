# Cafeína y enfermedad cardiovascular (NHANES 2017-2018)

Guía de este repositorio: qué hay, para qué sirve cada parte, y qué
dice cada sección de la propuesta. Pensada para retomar el proyecto
rápido (por ejemplo, si lo revisa María Paula) sin tener que releer
todo desde cero.

## 1. De qué se trata el proyecto

Queremos saber si el consumo diario de cafeína se asocia con la
prevalencia autorreportada de enfermedad cardiovascular (ECV) en
adultos de Estados Unidos, usando los datos públicos de NHANES
2017-2018, y si esa asociación se mantiene o se explica por la edad y
el sexo de las personas (que están asociados con ambas cosas).

Es un estudio **observacional, transversal y no experimental**: no se
puede concluir causalidad, solo asociación. Esto se repite varias
veces a propósito en el documento porque fue un punto explícito de la
retroalimentación de la primera entrega.

## 2. Estado actual

- Datos ya descargados, integrados y depurados: muestra analítica de
  **4.180 adultos** (casos completos, ≥20 años).
- `df.xlsx` ya incluye las variables de diseño muestral complejo
  (`peso_dieta`, `estrato`, `psu`), necesarias para declarar el
  `svydesign` en R.
- **Objetivo 1 completo**: caracterización ponderada (sociodemográfica,
  cafeína y prevalencia de ECV) ya corrida con el diseño muestral real
  (`analisis_objetivo1.R`) e incorporada al documento en la sección
  "Resultados preliminares". Hallazgo clave: la prevalencia de ECV
  ponderada (7,9 %) es menor que la sin ponderar (10,4 %).
- Anteproyecto redactado completo (19 páginas): problema, justificación,
  objetivos, antecedentes, marco conceptual, metodología, avance
  descriptivo exploratorio, resultados preliminares (objetivo 1), plan
  de análisis, cronograma y anexos. Compila a PDF sin errores. Las
  tablas y figuras se referencian en el texto con numeración automática
  (`bookdown`), no a mano.
- **Pendiente:** objetivos 2 a 6 (comparación de prevalencia por
  categoría de cafeína, estratificación, modelo logístico ajustado,
  término cuadrático, análisis por tipo de evento).

## 3. Archivos del repositorio

| Archivo | Qué es |
|---|---|
| `Propuesta_de_investigacion_cafeina_ECV.Rmd` | **El documento fuente.** Todo el texto del anteproyecto, en R Markdown. Se edita aquí. |
| `Propuesta_de_investigacion_cafeina_ECV.pdf` | El PDF ya compilado, listo para entregar/leer. |
| `bibliografia_seminario.bib` | Las referencias citadas en el `.Rmd` (10 en total, todas citadas en el texto — nada de relleno). |
| `df.xlsx` | **La base de datos lista para análisis** (4.180 filas, 17 columnas). Es el insumo directo para correr los modelos. |
| `analisis_objetivo1.R` | Script de R que declara el diseño muestral (`survey::svydesign`) y corre la caracterización ponderada del objetivo 1 (tablas + gráficas). Es la base para replicar el mismo patrón en los objetivos 2-6. |
| `figuras_objetivo1/` | Gráficas generadas por ese script (distribución por categoría, histogramas, prevalencia ponderada vs. sin ponderar). Solo un resumen de estas quedó incrustado en el PDF; el resto queda aquí para consulta. |
| `base_real_cafeina.ipynb` | Notebook (Python) que descarga los `.xpt` de NHANES, los integra, limpia los faltantes, construye las variables derivadas y genera `df.xlsx`. **Este es el notebook actualizado** (incluye `estrato`/`psu`). |
| `base_datos_cafeina_ecv.ipynb` | Otro notebook con un proceso parecido, pero es una versión **anterior** (no tiene las variables de diseño muestral). Conviene no seguir editando este en paralelo — ver nota abajo. |
| `base_cafeina_ecv.csv` / `datos/base_cafeina_ecv.csv` | Mismo contenido que `df.xlsx`, en CSV. Se genera en el mismo notebook. |
| `DEMO_J.xpt`, `DR1TOT_J.xpt`, `MCQ_J.xpt`, `DR2TOT_J.xpt`, `BMX_J.xpt`, `BPX_J.xpt`, `BPXO_J.xpt` | Archivos originales de NHANES descargados del CDC (demografía, dieta, condiciones médicas, examen físico). Los tres primeros son los que efectivamente se usan; los demás quedaron descargados pero no se usan en el análisis actual. |
| `Plantilla_para_Anteproyecto_de_Investigacion_seminario_2026_II.Rmd/.pdf` | La plantilla del curso para el anteproyecto (no se edita, es la referencia de estructura). |
| `Plantilla_para_propuesta_de_Investigacion...Rmd/.pdf` | La plantilla del curso para la propuesta (primera entrega). |
| `expo_propuesta.docx` | Documento aparte (revisar si sigue vigente o es de una entrega anterior). |

**Nota sobre los dos notebooks:** `base_real_cafeina.ipynb` es el que
genera la versión actual de `df.xlsx` (con `estrato` y `psu` ya
incluidos). `base_datos_cafeina_ecv.ipynb` parece ser una versión
previa del mismo proceso. Para no terminar con dos bases distintas
circulando, lo más seguro es que ambas trabajemos sobre
`base_real_cafeina.ipynb` de aquí en adelante, o que se decida cuál
de los dos es "el" notebook oficial y se borre o archive el otro.

## 4. Guía de la propuesta, sección por sección

### Problema de investigación
Plantea que la literatura de cohortes (Ding et al. 2014, Poole et al.
2017, Stevens et al. 2021) no encuentra que la cafeína aumente el
riesgo cardiovascular, pero son estudios longitudinales. Nosotras
miramos la misma pregunta con una fuente distinta (NHANES, transversal),
aclarando desde el principio que solo podemos hablar de **asociación**,
no de riesgo ni de causalidad, y que la edad y el sexo son posibles
factores de confusión a tener en cuenta.

### Justificación
Por qué vale la pena: relevancia en salud pública (la cafeína es casi
universal y modificable), relevancia estadística (permite practicar
descripción, comparación de grupos y ajuste por confusión) y
viabilidad (datos públicos, ya con un acercamiento exploratorio hecho).

### Objetivos
Un objetivo general y 6 específicos, pensados para ir de lo simple a
lo complejo:
1. Caracterizar la muestra.
2. Describir/comparar prevalencia de ECV por categoría de cafeína.
3. Explorar (de forma descriptiva) si eso cambia por edad/sexo.
4. Estimar la asociación ajustando por confusión (el modelo principal).
5. Ver si la relación es lineal o tiene curvatura (término cuadrático).
6. Revisar si los resultados son estables por tipo de evento (coronaria,
   infarto, ACV).

### Antecedentes
Compara los tres estudios de cohorte citados arriba: en qué coinciden
(no ven aumento de riesgo con consumo habitual) y qué les falta frente
a lo que haremos nosotras (ninguno es transversal/nacional, ninguno
discute edad/sexo como confusores). De ahí sale el "vacío" que
justifica el proyecto.

### Marco conceptual
Define los conceptos que hay que tener claros para no sobre-interpretar
los resultados: qué es la cafeína y cómo se mide en NHANES, qué
significa que la ECV sea "autorreportada" (y sus sesgos), qué es una
variable de confusión y por qué un diseño transversal no permite hablar
de causalidad, y qué implica que NHANES tenga un diseño muestral
complejo (pesos, estratos, conglomerados).

### Metodología
- **Enfoque y diseño:** cuantitativo, observacional, transversal.
- **Población y muestra:** población civil de EE. UU., datos ya
  existentes (no hay muestreo nuevo). Aquí está la parte más técnica:
  qué peso usar (`WTDRD1`, porque la exposición viene del recordatorio
  dietético) y por qué `estrato`/`psu` son necesarios.
- **Variables e indicadores:** tabla con la variable respuesta (`ecv`),
  la explicativa (`cafeina_mg`) y las de control (sexo, raza,
  educación, pir, kcal).
- **Fuentes e instrumentos:** de qué cuestionarios/instrumentos de
  NHANES sale cada variable.
- **Procedimiento:** cómo se integraron las tres bases (8.366 → 5.265
  tras filtrar por edad → 4.180 casos completos), cómo se trataron los
  faltantes (523 sin dieta, 697 sin PIR, 20,5 % de la población
  elegible con algún faltante), y cómo se construyeron las variables
  derivadas (`ecv`, categorías de cafeína, grupos de edad).
- **Avance: análisis descriptivo preliminar:** esto es nuevo y es lo
  más mostrable que tenemos. Con los datos reales (sin ponderar
  todavía) se ve que la prevalencia de ECV sube con la cafeína (9,3 %
  → 16,1 %), pero la edad también sube en el mismo sentido, y la
  prevalencia varía mucho más con la edad (1,2 % → 21,1 %) que con la
  cafeína. Es justo el patrón de confusión que motivó el estudio desde
  el planteamiento del problema — y por eso el texto insiste en que
  esto **no** es evidencia de que la cafeína sea un factor de riesgo.
- **Plan de análisis:** tabla que conecta cada objetivo específico con
  el procedimiento estadístico exacto (qué prueba, qué modelo, qué se
  reporta). Es literalmente la hoja de ruta para cuando corramos los
  modelos de verdad.
- **Consideraciones éticas:** datos públicos, desidentificados, sin
  consentimiento nuevo necesario; la conclusión siempre se interpretará
  como asociación, no como causalidad.

### Resultados preliminares
El objetivo 1 ya corrido de verdad, con el diseño muestral completo
(no sin ponderar como el avance). Trae dos tablas (sociodemografía y
cafeína; edad/PIR/energía/cafeína) y una gráfica con el hallazgo
central: la prevalencia ponderada de ECV (7,9 %, IC 95 % 6,2-9,9 %) es
más de dos puntos menor que la cruda sin ponderar (10,4 %) — confirma
con datos reales por qué insistimos tanto en el diseño muestral.

### Cronograma
Cuatro períodos: revisión bibliográfica, preparación de datos, análisis
estadístico, informe final. Ajustar fechas según el calendario real del
curso.

### Anexos
Diccionario completo de variables (nombre en la base, variable original
de NHANES, descripción, codificación). Es la referencia rápida cuando
alguien no recuerda qué es `pir` o de dónde salió `cat_cafeina`.

## 5. Cómo compilar el documento (knit)

Se necesita R + RStudio instalados, con los paquetes `rmarkdown`,
`knitr`, `readxl`, `tinytex`, `survey` y **`bookdown`** (el documento
usa `bookdown::pdf_document2` para que las referencias a "Cuadro N" /
"Figura N" en el texto se numeren solas — si falta, instalarlo con
`install.packages(c("bookdown", "survey"))`). Si se knitea desde
RStudio, "Knit" normal funciona. Si se hace desde la terminal sin abrir
RStudio, primero hay que apuntar a su pandoc empaquetado:

```powershell
$env:RSTUDIO_PANDOC = "C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools"
Rscript -e "rmarkdown::render('Propuesta_de_investigacion_cafeina_ECV.Rmd')"
```

El `.Rmd` lee `df.xlsx` directamente (secciones de avance y resultados),
así que ese archivo debe estar en la misma carpeta al momento de
compilar.

Nota: si el knit falla con un error de `xfun`/`bookdown` (versión muy
vieja), es porque algún proceso (RStudio, la extensión de R de VS Code)
tiene el paquete cargado y bloquea la actualización. Cerrar esas
sesiones y volver a instalar suele resolverlo.

## 6. Próximos pasos (lo que falta)

En el orden del plan de análisis:

1. ~~Declarar el diseño muestral en R~~ — hecho en `analisis_objetivo1.R`
   (`svydesign` con `weights = peso_dieta`, `strata = estrato`,
   `ids = psu`).
2. ~~Objetivo 1: caracterización ponderada~~ — hecho, ver "Resultados
   preliminares" en el documento.
3. Objetivo 2: prevalencia de ECV por categoría de cafeína, ponderada,
   con prueba de Rao-Scott.
4. Objetivo 3: estratificar por edad/sexo para decidir ajuste e
   interacciones.
5. Objetivo 4: `svyglm()` logístico ajustado — el modelo principal.
6. Objetivo 5: agregar el término cuadrático y probarlo con Wald.
7. Objetivo 6: repetir el modelo por tipo de evento (coronaria, infarto,
   ACV).
8. Si da el tiempo: sensibilidad con imputación múltiple vs. casos
   completos (mencionado como complementario en Procedimiento).
