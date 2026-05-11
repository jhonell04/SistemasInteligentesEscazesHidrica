# Sistema Experto para Mitigación de Escasez Hídrica (SGE Hídrico 2.0)

Un sistema inteligente basado en reglas CLIPS para la evaluación y respuesta ante situaciones de escasez hídrica en sectores urbanos, utilizando forward chaining para inferir acciones de mitigación.

## 🎯 Características Principales

- **Motor CLIPS**: Sistema experto con 21 reglas de inferencia jerárquica
- **4 Capas de Análisis**: Estrés Hídrico → Vulnerabilidad Social → Prioridad → Acción Final
- **Interfaz Web Moderna**: Flask + HTML/CSS responsivo
- **Evaluación en Tiempo Real**: Análisis instantáneo de situaciones críticas
- **Alertas Críticas**: Escalamiento automático a INDECI cuando es necesario

## 🏗️ Arquitectura

```
SGE Hídrico 2.0/
├── app.py                 # Backend Flask + CLIPS
├── reglas_hidricas.clp    # Motor de reglas CLIPS
├── requirements.txt        # Dependencias Python
└── templates/
    └── index.html         # Interfaz web
```

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Python 3.8+
- pip

### Instalación
```bash
# Clonar o descargar el proyecto
cd sge_hidrico_2.0

# Instalar dependencias
pip install -r requirements.txt
```

### Ejecución
```bash
python app.py
```

Abre tu navegador en: `http://127.0.0.1:5000`

## 🧠 Motor de Conocimiento CLIPS

### Estructura de Hechos
El sistema evalúa 8 parámetros de entrada:

| Parámetro | Tipo | Valores |
|-----------|------|---------|
| `dias_sin_agua` | INTEGER | 0-∞ |
| `nivel_reservorio` | STRING | "Critico", "Medio", "Alto" |
| `estado_red` | STRING | "Rota", "Falla_Parcial", "Operativa" |
| `zona` | STRING | "Plana", "Laderas_SJL" |
| `presencia_hospitales` | STRING | "Si", "No" |
| `clima` | STRING | "Normal", "Ola_de_Calor" |
| `ruta_pl_calculada` | STRING | "Verdadero", "Falso" |
| `cisternas_disponibles` | STRING | "Disponibles", "Cero" |

### Variables Inferidas
- **Estrés Hídrico**: CRÍTICO, ALTO, BAJO
- **Vulnerabilidad**: EXTREMA, ALTA, BAJA
- **Prioridad de Atención**: INMEDIATA, URGENTE, PROGRAMADA
- **Viabilidad Técnica**: Solo_Red, Mixta, Solo_Cisternas
- **Logística**: Lista_para_Despliegue, Requiere_Calculo
- **Acción Final**: 5 tipos de intervenciones específicas

## 📋 Reglas de Inferencia (21 reglas)

### Capa 1: Estrés Hídrico
- **R1-R3**: Evaluación basada en días sin agua y estado del reservorio/red
- **R4-R5**: Ajustes por clima extremo (ola de calor)

### Capa 2: Vulnerabilidad Social
- **R6-R8**: Consideración de presencia de hospitales y zona geográfica
- **R9-R12**: Determinación de prioridad de atención

### Capa 3: Viabilidad Técnica y Logística
- **R13-R15**: Evaluación del estado de la red de distribución
- **R16-R17**: Cálculo de logística para despliegue de cisternas

### Capa 4: Acciones Terminales
- **R21** (salience 100): **ALERTA ROJA** - Escalamiento a INDECI
- **R18-R20**: Acciones específicas según prioridad y logística

## 🔌 API REST

### POST `/inferir`
Evalúa una situación hídrica y retorna las inferencias.

**Request Body:**
```json
{
  "dias_sin_agua": 5,
  "nivel_reservorio": "Critico",
  "estado_red": "Rota",
  "zona": "Laderas_SJL",
  "presencia_hospitales": "Si",
  "clima": "Ola_de_Calor",
  "ruta_pl_calculada": "Falso",
  "cisternas_disponibles": "Disponibles"
}
```

**Response:**
```json
{
  "ok": true,
  "resultado": {
    "estres_hidrico": "CRITICO",
    "vulnerabilidad": "EXTREMA",
    "prioridad_atencion": "INMEDIATA",
    "viabilidad_tecnica": "Solo_Cisternas",
    "logistica": "Requiere_Calculo",
    "accion_final": "Ejecutar modelo Programacion Lineal urgente"
  },
  "hechos": { /* hechos originales */ }
}
```

## 🎨 Interfaz Web

### Características
- **Formulario Interactivo**: Campos validados para todos los parámetros
- **Visualización Jerárquica**: 4 capas de inferencia con indicadores visuales
- **Código CLIPS**: Muestra las reglas disparadas en tiempo real
- **Alertas Color-Codificadas**: Diferentes colores según severidad
- **Responsive Design**: Funciona en desktop y móvil

### Estados de Alerta
- 🔴 **Roja**: Escalamiento a INDECI (prioridad máxima)
- 🟠 **Inmediata**: Despliegue urgente de convoy
- 🔵 **Urgente**: Aumento de presión + cisternas en 12h
- 🟢 **Programada**: Intervención planificada

## 🛠️ Tecnologías Utilizadas

- **Backend**: Python 3.8+ + Flask
- **Motor Experto**: CLIPS 6.4 (via clipspy)
- **Frontend**: HTML5 + CSS3 (Grid/Flexbox)
- **Estilos**: Diseño moderno con gradientes y animaciones
- **Tipografía**: Syne + DM Sans + DM Mono

## 📊 Ejemplo de Uso

**Escenario Crítico:**
- Días sin agua: 7
- Reservorio: Crítico
- Red: Rota
- Zona: Laderas SJL
- Hospitales: Sí
- Clima: Ola de calor
- Ruta PL: No calculada
- Cisternas: Disponibles

**Resultado:**
- Estrés: CRÍTICO
- Vulnerabilidad: EXTREMA
- Prioridad: INMEDIATA
- Acción: "Ejecutar modelo Programación Lineal urgente"

## 🔧 Desarrollo y Contribución

### Estructura del Código
- `app.py`: Punto de entrada y API REST
- `reglas_hidricas.clp`: Lógica del sistema experto
- `templates/index.html`: Interfaz de usuario

### Modificación de Reglas
Para agregar nuevas reglas CLIPS:
1. Editar `reglas_hidricas.clp`
2. Reiniciar la aplicación
3. Probar con casos de prueba

## 📄 Licencia

Este proyecto es de uso académico y educativo.

## 👥 Autor

Sistema desarrollado como parte del curso de Sistemas Inteligentes.

---

**Nota**: El sistema utiliza forward chaining puro de CLIPS, garantizando inferencias determinísticas y trazables basadas en reglas expertas del dominio hídrico.
