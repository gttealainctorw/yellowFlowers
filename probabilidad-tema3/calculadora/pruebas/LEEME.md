# Pruebas del programa

Simulador mínimo de la API Lua de TI-Nspire para correr `tema3.lua` en una computadora.

```sh
cd probabilidad-tema3/calculadora/pruebas
lua5.1 run_examples.lua . ../tema3.lua   # resuelve todos los ejemplos del menú
lua5.1 edge.lua . ../tema3.lua           # datos con errores: deben dar mensajes claros
lua5.1 scenario.lua . ../tema3.lua && python3 render.py   # dibuja pantallas simuladas (shot_*.png)
```

`resultados_ejemplos.txt` tiene la salida completa de todos los ejemplos y `pantallas/` las
pantallas simuladas a 318×212 (ampliadas 2×).
