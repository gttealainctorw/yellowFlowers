# Prompt para Claude Code en mi computadora

Copia todo lo que está dentro del bloque y pégalo en Claude Code, abierto en la carpeta donde
descomprimiste `tema3_probabilidad.zip`.

```text
Estoy estudiando para mi examen del Tema 3 de Probabilidad (variables aleatorias conjuntas,
Facultad de Ingeniería). En esta carpeta hay trabajo ya hecho que quiero que termines:

- probabilidad-tema3/guia_tema3.tex (+ estilo.tex, c00..c09, f02..f08): guía en LaTeX.
  El PDF compilado es probabilidad-tema3/guia_tema3.pdf.
- probabilidad-tema3/calculadora/tema3.lua: programa Lua para mi TI-Nspire CX II con 7
  pestañas (tabla discreta, densidad k y P, marginal y condicional, E/Cov/regresión,
  combinación lineal, integral doble, ayuda). Tiene fracciones exactas, convierte
  desigualdades en regiones, integra paso a paso y factoriza resultados.
  Manual: probabilidad-tema3/calculadora/LEEME.md.
- probabilidad-tema3/calculadora/pruebas/: simulador de la API de la TI-Nspire para Lua 5.1
  (mock.lua), pruebas (run_examples.lua, edge.lua, scenario.lua + render.py) y la salida
  esperada (resultados_ejemplos.txt).
- material_original/: mis apuntes del Tema 3, el formulario, la Serie 3, la Serie 2, los
  apuntes del Tema 2 y una foto de mi examen del Tema 2.

El programa se hizo en la nube SIN ver mis propios programas y SIN probarlo en la calculadora
real. Quiero que lo termines así, en este orden:

1. Lee probabilidad-tema3/calculadora/LEEME.md y tema3.lua completos. Instala Lua 5.1 si no
   está y corre las pruebas desde probabilidad-tema3/calculadora/pruebas/:
     lua5.1 run_examples.lua . ../tema3.lua
     lua5.1 edge.lua . ../tema3.lua
   Compara run_examples con resultados_ejemplos.txt. Esa es tu línea base.

2. Pregúntame dónde guardo mis programas Lua de la TI-Nspire (scripts .lua, o documentos .tns
   que abro en el Editor de scripts del software TI-Nspire). Lee varios y resume mi estilo:
   cómo organizo menús/pestañas, cómo pido los datos, cómo muestro el procedimiento, nombres,
   tamaño de letra, colores, teclas. Muéstrame el resumen y lo que propones cambiar en
   tema3.lua ANTES de editar. Adapta la interfaz a mi estilo sin tocar el motor matemático
   (fracciones Q, polinomios, region/slices, integrate_region, solve*). Las reglas que no
   cambian: yo sólo sustituyo datos en campos claros y el programa me da el procedimiento
   paso a paso con el resultado resaltado.

3. Genera el .tns. Opción A: compila Luna (https://github.com/ndless-nspire/Luna, necesita
   zlib) y corre `luna tema3.lua tema3.tns`. Opción B: dime los pasos exactos en mi software
   TI-Nspire (Insertar > Editor de scripts > Insertar script, pegar, Fijar script, guardar).
   No borres ni sobrescribas archivos míos sin preguntarme.

4. Pruébalo en la calculadora (o en el emulador del software TI-Nspire) conmigo: yo te digo
   qué ves o te mando fotos. Revisa en especial: que se vean los símbolos ∫ ≤ ≥ σ ρ √ ≈ ✓ y
   los acentos (si no, Opciones > Símbolos simples o cambia SYM_U); que las teclas manden lo
   que el código espera en on.charIn (− de la tecla negativa, ≤ ≥, ^, √); el menú de
   toolpalette; on.save/on.restore; y que todo quepa en 318x212. Corrige lo que falle.

5. Después de cada cambio vuelve a correr las pruebas del paso 1 y verifica que los
   resultados no cambien. Valores que deben salir igual (son las respuestas de mi serie y mis
   apuntes): Ej 3.3 P(X>Y)=0.48, P(X<2|Y=1)=0.6, independientes; Serie 1 P(|X1-X2|>=2)=0.22;
   Serie 8 P(X<=9,Y<=9)=0.25, E(X+Y)=18.25 (8.9+9.35), E|X-Y|=1.05; Serie 10 rho=-1/3;
   Autoexamen 10 rho=-0.408; Ej 3.4 k=1, P(X+Y<=1)=1/3; Serie 2 k=3/28, P(1<=X<=3)=5/7;
   Serie 3 P(X>1/2)=5/16, fY=12y(1-y)^2, P(X<1/8|Y=3/4)=1/4; Ej 5.5 P=2/3;
   Serie 7 K=3/380000, P(|X-Y|<=2)=0.3593; Serie 9 Cov=-625/5776≈-0.1082, rho≈-0.0131;
   Serie 5 E(Y-X)=1/3; Ej 3.6 a=8/3 (k=3/8); Ej 3.8 E[Y|x]=5x/9; Serie 11 Var(2X-3Y+7)=640;
   Ej 3.13 E=-22, Var=480; Autoexamen 9 E=13, sigma=12.87.
   El código debe seguir siendo Lua 5.1 (sin goto, //, table.unpack ni la librería utf8) y
   empezar con platform.apilevel = "2.2".

6. Cuando yo te lo pida (no antes): agrega a la guía, en cada capítulo (c03..c08), una caja
   «En tu calculadora» que diga qué pestaña usar y qué escribir en cada campo para ese tipo
   de ejercicio, con el estilo de estilo.tex. Compila con pdflatex (dos o tres pasadas) desde
   probabilidad-tema3/; necesita TeX Live con XCharter, newtx, FiraSans, tcolorbox, tikz,
   titlesec, titletoc, needspace y babel-spanish. Revisa visualmente las páginas que cambies.

7. Opcional, si sobra tiempo y te lo confirmo: soporte para densidades con exponenciales en
   regiones infinitas (Ej 3.12: 4xy e^-(x^2+y^2)) y una pestaña para construir la tabla
   conjunta desde un experimento (Serie 10, transistores).

Explícame en español, en pocas palabras, qué hiciste en cada paso y qué falta.
```
