# Tema 3 en la TI-Nspire CX II: asistente paso a paso

`tema3.lua` es un programa Lua para la TI-Nspire CX II. Tú sólo sustituyes los datos del
enunciado en campos con nombre y el programa escribe el procedimiento completo, paso por
paso, con el resultado en fracción y en decimal, listo para copiarlo en el examen.

> **Versión 1, hecha sin ver tus programas.** Cuando me compartas cómo haces tus programas
> en Lua (ver la última sección), la adapto a tu estilo.

## Cómo pasarlo a la calculadora

Necesitas el software TI-Nspire CX (Student o Teacher) en tu computadora.

1. Abre un documento nuevo.
2. **Insertar → Editor de scripts → Insertar script** (en inglés: *Insert → Script Editor → Insert Script*). Ponle de nombre `tema3`.
3. Borra el texto de ejemplo del editor y pega **todo** el contenido de `tema3.lua`.
4. Pulsa **Fijar script** (*Set Script*). La app aparece en la página del documento.
5. Guarda el documento (por ejemplo `tema3.tns`) y envíalo a la calculadora con el mismo
   software (explorador de contenido → arrastrar a la calculadora conectada).

Si en tu computadora tienes [Luna](https://github.com/ndless-nspire/Luna), también sirve:
`luna tema3.lua tema3.tns`.

## Cómo se usa

- **menu → Pestañas**: escoges la herramienta (las 7 de abajo).
- **menu → Ejemplos**: llena los campos con un ejercicio de tu serie o de tus apuntes. Úsalo
  para ver cómo se escriben los datos y para comprobar que todo funciona.
- **Flechas arriba/abajo o tab**: cambias de campo. **Flechas izquierda/derecha**: mueves el cursor.
  **clear**: borras el campo.
- **enter**: resuelve. **esc**: regresas a los datos.
- En los resultados, **arriba/abajo** avanzan renglón por renglón, **izquierda/derecha** una
  pantalla, y **tab** salta a la siguiente sección.
- Los datos se guardan con el documento. Las pestañas 2, 3 y 4 comparten `f(x,y)` y el soporte:
  si lo escribes en una, ya está en las otras.

## Las 7 pestañas

| Pestaña | Úsala cuando el ejercicio… | Qué escribes (ejemplo) | Qué te da |
|---|---|---|---|
| **1 Tabla discreta** | te da una **tabla** f(x,y) | Valores de X `0,1,2` · Valores de Y `0,1,2` · Renglones `y` · Celdas renglón por renglón `.10,.20,.20,.04,...` · Evento `x>y` · g `x+y` · Condición `y=1` | Tabla con márgenes, marginales, E, Var, σ, E(XY), Cov, ρ, ρ², independencia (con la celda que falla), P(evento) con las celdas marcadas, E[g], condicional y E condicional, F(x,y) |
| **2 Densidad: k y P** | da una **densidad con constante** o pide **P(región)** o **P(A\|B)** | f `k(x+y)` · Soporte `0<=x<=1, 0<=y<=1` · Evento `x+y<=1` · Dado `y<=1/2` | Vértices, flecha y piezas, integral doble completa para k, integral de la probabilidad, P(A\|B) |
| **3 Marginal y condicional** | pide **fX, fY, f(y\|x), f(x\|y)**, **P(X<a \| Y=b)** o **¿independientes?** | f `24xy` · Soporte `x>=0, y>=0, x+y<=1` · Valor conocido `y=3/4` · Evento `x<1/8` | Marginales paso a paso y factorizadas, condicionales simplificadas, independencia justificada, condicional en un valor y su probabilidad |
| **4 E, Cov y regresión** | pide **E(X), Var, E(XY), Cov, ρ**, **curva de regresión** o **E[g(X,Y)]** con densidad | f `k(x^2+y^2)` · Soporte `20<=x<=30, 20<=y<=30` · g `y-x` | Momentos con las marginales, E(XY) con la conjunta, Cov, ρ, ρ², E[Y\|x] y E[X\|y] simplificadas, E[g] |
| **5 Combinación lineal** | da medias, variancias (o σ, o E(X²)) y Cov (o ρ, o independencia) y pide **E o Var de aX+bY+c** | Coeficientes `2,-3` · c `7` · Medias `3,10` · Te dan `e` · Valores `25,164` · Relación `i` | Datos convertidos, E(W) y Var(W) con la parte de cuadrados y la cruzada, σW. Acepta 2 o más variables |
| **6 Integral doble** | ya sabes los límites y quieres la cuenta | f `24xy` · Orden `dydx` · Afuera `1/2,1` · Adentro `0,1-x` | La integral paso a paso: adentro, sustitución, afuera, evaluación |
| **7 Ayuda** | no sabes qué pestaña usar | — | Esta tabla y cómo escribir los datos |

## Cómo escribir los datos

- Multiplicación sin `*`: `24xy`, `k(x+y)`, `3x^2y`.
- Fracciones con `/`: `3/4`. Decimales: `0.05` o `.05`.
- La constante desconocida siempre se llama `k`. Si el enunciado trae `x y^2 / a`, escribe
  `kxy^2`; al final `a = 1/k`.
- Regiones y eventos: desigualdades separadas por coma, como en el enunciado:
  `0<=x<=4, y>=0, y>=2-x, y<=4-x`. Sirven `≤` y `<=`.
- `|x-y| <= 2` se escribe como dos condiciones: `x-y<=2, y-x<=2`.
- En la tabla, los eventos pueden usar `abs`: `abs(x-y)>=2`, `x+y>=4`, `x<=9, y<=9`.

## Límites

- Las densidades deben ser polinomios en x, y sobre regiones limitadas por rectas (como todos
  los de tu serie). No acepta `e^x` ni regiones infinitas (como el Ej. 3.12).
- Si ves cuadritos en lugar de símbolos (∫, ≤, σ, ρ), usa **menu → Opciones → Símbolos simples**.
- Para ver más texto por pantalla: **menu → Opciones → Letra chica**.

## Cómo se comprobó

El programa no se ha probado todavía en una calculadora real. Se probó con un simulador
de la pantalla y las teclas de la TI-Nspire (carpeta `pruebas/`) usando Lua 5.1, la versión
de la calculadora. Todos los ejemplos del menú dan los mismos resultados que las respuestas
de la Serie 3 y de los ejemplos de los apuntes. Si algo no se ve bien en tu calculadora,
mándame una foto de la pantalla.

## Para adaptarlo a tus programas

Para revisar cómo haces tus programas necesito ver su código. Cualquiera de estas sirve:

- En el Editor de scripts, copia el código de uno de tus programas y pégalo en el chat, o
  súbelo como archivo `.lua` o `.txt`.
- Abre esta conversación desde la app de escritorio de Claude en tu computadora y comparte la
  carpeta donde guardas tus programas (Configuración → Claude Code → Remote Control).
