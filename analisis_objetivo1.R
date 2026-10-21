# Objetivo 1 — Caracterizacion ponderada de la muestra analitica
# (edad, sexo, raza, educacion, PIR, consumo de cafeina y prevalencia de ECV)
# usando el diseno muestral complejo de NHANES (pesos, estratos, conglomerados).

library(readxl)
library(survey)
library(ggplot2)

dir.create("figuras_objetivo1", showWarnings = FALSE)

df <- read_excel("df.xlsx")

df$sexo        <- factor(df$sexo)
df$raza        <- factor(df$raza)
df$educacion   <- factor(df$educacion,
  levels = c("Menos de 9no grado", "9-11 grado (sin terminar)",
             "Bachiller / GED", "Universidad incompleta / tecnico",
             "Universitario o mas"))
df$cat_cafeina <- factor(df$cat_cafeina,
  levels = c("0 mg", "1-100 mg", "101-200 mg", "201-400 mg", ">400 mg"))
df$grupo_edad  <- factor(df$grupo_edad, levels = c("20-39", "40-59", "60+"))

cat("Filas en df.xlsx:", nrow(df), "\n")
cat("NA por variable clave:\n")
print(colSums(is.na(df[c("sexo","raza","educacion","pir","cafeina_mg","kcal","ecv",
                          "peso_dieta","estrato","psu")])))

# --- Diseno muestral complejo ---
diseno <- svydesign(
  ids     = ~psu,
  strata  = ~estrato,
  weights = ~peso_dieta,
  nest    = TRUE,
  data    = df
)

cat("\n================ VARIABLES CATEGORICAS (ponderadas) ================\n")

tabla_categorica <- function(var, design) {
  f <- as.formula(paste0("~", var))
  est <- svymean(f, design, na.rm = TRUE)
  pct <- round(100 * coef(est), 1)
  se  <- round(100 * SE(est), 2)
  data.frame(variable = var, nivel = sub(var, "", names(coef(est))),
             porcentaje = pct, ee = se, row.names = NULL)
}

categoricas <- do.call(rbind, lapply(c("sexo", "raza", "educacion", "cat_cafeina"),
                                      tabla_categorica, design = diseno))
for (v in unique(categoricas$variable)) {
  cat("\n---", v, "---\n")
  print(categoricas[categoricas$variable == v, ])
}

# --- Grafica 1: variables categoricas ponderadas ---
categoricas$variable <- factor(categoricas$variable,
  levels = c("sexo", "raza", "educacion", "cat_cafeina"),
  labels = c("Sexo", "Raza/etnia", "Educación", "Categoría de cafeína"))

p_categoricas <- ggplot(categoricas, aes(x = nivel, y = porcentaje)) +
  geom_col(fill = "#4C72B0") +
  facet_wrap(~variable, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, y = "Porcentaje ponderado (%)",
       title = "Caracterización sociodemográfica y de consumo de cafeína") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("figuras_objetivo1/01_categoricas.png", p_categoricas,
       width = 9, height = 6.5, dpi = 150)

cat("\n--- Prevalencia de ECV (ponderada) ---\n")
ecv_prop <- svyciprop(~I(ecv == 1), diseno, method = "logit", na.rm = TRUE)
cat("Prevalencia:", round(100 * coef(ecv_prop), 1), "%  IC95%: [",
    round(100 * attr(ecv_prop, "ci")[1], 1), ",",
    round(100 * attr(ecv_prop, "ci")[2], 1), "]\n")

cat("\n================ VARIABLES CUANTITATIVAS (ponderadas) ================\n")

tabla_cuantitativa <- function(var, design) {
  f <- as.formula(paste0("~", var))
  m   <- svymean(f, design, na.rm = TRUE)
  q   <- svyquantile(f, design, quantiles = c(0.25, 0.5, 0.75), na.rm = TRUE)
  qm  <- unname(q[[1]][, "quantile"])
  data.frame(
    variable = var,
    media    = unname(round(coef(m), 1)),
    ee       = unname(round(SE(m), 2)),
    p25      = round(qm[1], 1),
    mediana  = round(qm[2], 1),
    p75      = round(qm[3], 1),
    stringsAsFactors = FALSE
  )
}

cuant <- do.call(rbind, lapply(c("edad", "pir", "kcal", "cafeina_mg"),
                                tabla_cuantitativa, design = diseno))
print(cuant, row.names = FALSE)

# --- Grafica 2: distribucion ponderada de las variables cuantitativas ---
cuant_vars <- c("edad", "pir", "kcal", "cafeina_mg")
cuant_long <- do.call(rbind, lapply(cuant_vars, function(v) {
  data.frame(variable = v, valor = df[[v]], peso = df$peso_dieta)
}))
cuant_long$variable <- factor(cuant_long$variable, levels = cuant_vars,
  labels = c("Edad (años)", "Razón ingreso/pobreza", "Energía (kcal/día)",
             "Cafeína (mg/día)"))

p_cuant <- ggplot(cuant_long, aes(x = valor, weight = peso)) +
  geom_histogram(bins = 30, fill = "#4C72B0", color = "white") +
  facet_wrap(~variable, scales = "free", ncol = 2) +
  labs(x = NULL, y = "Frecuencia ponderada",
       title = "Distribución ponderada de las variables cuantitativas") +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("figuras_objetivo1/02_cuantitativas.png", p_cuant,
       width = 9, height = 6.5, dpi = 150)

cat("\n================ COMPARACION PONDERADA vs. SIN PONDERAR ================\n")
cat("Prevalencia ECV sin ponderar:", round(100 * mean(df$ecv), 1), "%\n")
cat("Prevalencia ECV ponderada:   ", round(100 * coef(ecv_prop), 1), "%\n")

# --- Grafica 3: prevalencia de ECV, ponderada vs. sin ponderar ---
comparacion <- data.frame(
  tipo = c("Sin ponderar", "Ponderada (diseño NHANES)"),
  prevalencia = c(100 * mean(df$ecv), 100 * coef(ecv_prop))
)
comparacion$tipo <- factor(comparacion$tipo, levels = comparacion$tipo)

p_comparacion <- ggplot(comparacion, aes(x = tipo, y = prevalencia)) +
  geom_col(fill = c("#C44E52", "#4C72B0"), width = 0.5) +
  geom_text(aes(label = paste0(round(prevalencia, 1), "%")), vjust = -0.6) +
  labs(x = NULL, y = "Prevalencia de ECV (%)",
       title = "Prevalencia de ECV autorreportada: ponderada vs. sin ponderar") +
  ylim(0, max(comparacion$prevalencia, na.rm = TRUE) + 3) +
  theme_minimal(base_size = 11)

ggsave("figuras_objetivo1/03_prevalencia_ecv.png", p_comparacion,
       width = 6, height = 5, dpi = 150)

cat("\nFiguras guardadas en figuras_objetivo1/\n")
