;;; ============================================================
;;;  SISTEMA EXPERTO - MITIGACION DE ESCASEZ HIDRICA
;;;  Archivo: reglas_hidricas.clp
;;;  Compatible con: clipspy (Python bindings para CLIPS 6.4)
;;;  Estrategia: Forward Chaining con modify para inferencias
;;; ============================================================

;;; ----------------------------------------------------------
;;; DEFTEMPLATE: sector
;;; ----------------------------------------------------------
(deftemplate sector
  ;; --- Slots de entrada (hechos iniciales) ---
  (slot dias_sin_agua        (type INTEGER) (default 0))
  (slot nivel_reservorio     (type STRING)  (default "--"))
  (slot estado_red           (type STRING)  (default "--"))
  (slot zona                 (type STRING)  (default "--"))
  (slot presencia_hospitales (type STRING)  (default "--"))
  (slot clima                (type STRING)  (default "--"))
  (slot ruta_pl_calculada    (type STRING)  (default "--"))
  (slot cisternas_disponibles(type STRING)  (default "--"))

  ;; --- Slots inferidos (inicializados en "--") ---
  (slot estres_hidrico       (type STRING)  (default "--"))
  (slot vulnerabilidad       (type STRING)  (default "--"))
  (slot prioridad_atencion   (type STRING)  (default "--"))
  (slot viabilidad_tecnica   (type STRING)  (default "--"))
  (slot logistica            (type STRING)  (default "--"))
  (slot accion_final         (type STRING)  (default "--"))
)

;;; ===========================================================
;;; CAPA 1: ESTRES HIDRICO
;;; ===========================================================

;;; R1: dias_sin_agua > 3 Y nivel_reservorio = "Critico" => estres_hidrico = "CRITICO"
(defrule R1-estres-critico-por-dias-y-reservorio-critico
  "Si llevan mas de 3 dias sin agua y el reservorio es Critico, el estres es CRITICO"
  ?s <- (sector
          (dias_sin_agua ?d&:(> ?d 3))
          (nivel_reservorio "Critico")
          (estres_hidrico "--"))
  =>
  (modify ?s (estres_hidrico "CRITICO"))
)

;;; R2: dias_sin_agua > 3 Y nivel_reservorio = "Medio" => estres_hidrico = "ALTO"
(defrule R2-estres-alto-por-dias-y-reservorio-medio
  "Si llevan mas de 3 dias sin agua y el reservorio es Medio, el estres es ALTO"
  ?s <- (sector
          (dias_sin_agua ?d&:(> ?d 3))
          (nivel_reservorio "Medio")
          (estres_hidrico "--"))
  =>
  (modify ?s (estres_hidrico "ALTO"))
)

;;; R3: dias_sin_agua <= 3 Y estado_red = "Rota" => estres_hidrico = "ALTO"
(defrule R3-estres-alto-por-red-rota
  "Si la red esta rota aunque falten pocos dias, el estres es ALTO"
  ?s <- (sector
          (dias_sin_agua ?d&:(<= ?d 3))
          (estado_red "Rota")
          (estres_hidrico "--"))
  =>
  (modify ?s (estres_hidrico "ALTO"))
)

;;; R4: dias_sin_agua <= 3 Y nivel_reservorio = "Alto" => estres_hidrico = "BAJO"
(defrule R4-estres-bajo-por-reservorio-alto
  "Si el reservorio esta Alto y llevan pocos dias, el estres es BAJO"
  ?s <- (sector
          (dias_sin_agua ?d&:(<= ?d 3))
          (nivel_reservorio "Alto")
          (estres_hidrico "--"))
  =>
  (modify ?s (estres_hidrico "BAJO"))
)

;;; R5: clima = "Ola_de_Calor" Y estres_hidrico = "ALTO" => estres_hidrico = "CRITICO"
(defrule R5-ola-de-calor-escala-estres
  "Una ola de calor con estres ALTO lo escala a CRITICO"
  ?s <- (sector
          (clima "Ola_de_Calor")
          (estres_hidrico "ALTO"))
  =>
  (modify ?s (estres_hidrico "CRITICO"))
)

;;; ===========================================================
;;; CAPA 2: PRIORIDAD SOCIAL
;;; ===========================================================

;;; R6: presencia_hospitales = "Si" => vulnerabilidad = "EXTREMA"
(defrule R6-hospitales-vulnerabilidad-extrema
  "La presencia de hospitales implica vulnerabilidad EXTREMA"
  ?s <- (sector
          (presencia_hospitales "Si")
          (vulnerabilidad "--"))
  =>
  (modify ?s (vulnerabilidad "EXTREMA"))
)

;;; R7: zona = "Laderas_SJL" Y estres_hidrico = "ALTO" => vulnerabilidad = "ALTA"
(defrule R7-laderas-estres-alto-vulnerabilidad-alta
  "Zona de laderas con estres ALTO tiene vulnerabilidad ALTA"
  ?s <- (sector
          (zona "Laderas_SJL")
          (estres_hidrico "ALTO")
          (vulnerabilidad "--"))
  =>
  (modify ?s (vulnerabilidad "ALTA"))
)

;;; R8: zona = "Plana" Y estres_hidrico = "BAJO" => vulnerabilidad = "BAJA"
(defrule R8-zona-plana-estres-bajo-vulnerabilidad-baja
  "Zona plana con estres BAJO tiene vulnerabilidad BAJA"
  ?s <- (sector
          (zona "Plana")
          (estres_hidrico "BAJO")
          (vulnerabilidad "--"))
  =>
  (modify ?s (vulnerabilidad "BAJA"))
)

;;; R9: vulnerabilidad = "EXTREMA" => prioridad_atencion = "INMEDIATA"
(defrule R9-extrema-prioridad-inmediata
  "Vulnerabilidad EXTREMA requiere atencion INMEDIATA"
  ?s <- (sector
          (vulnerabilidad "EXTREMA")
          (prioridad_atencion "--"))
  =>
  (modify ?s (prioridad_atencion "INMEDIATA"))
)

;;; R10: vulnerabilidad = "ALTA" Y estres_hidrico = "CRITICO" => prioridad_atencion = "INMEDIATA"
(defrule R10-alta-critico-prioridad-inmediata
  "Vulnerabilidad ALTA con estres CRITICO requiere atencion INMEDIATA"
  ?s <- (sector
          (vulnerabilidad "ALTA")
          (estres_hidrico "CRITICO")
          (prioridad_atencion "--"))
  =>
  (modify ?s (prioridad_atencion "INMEDIATA"))
)

;;; R11: vulnerabilidad = "ALTA" Y estres_hidrico = "ALTO" => prioridad_atencion = "URGENTE"
(defrule R11-alta-alto-prioridad-urgente
  "Vulnerabilidad ALTA con estres ALTO requiere atencion URGENTE"
  ?s <- (sector
          (vulnerabilidad "ALTA")
          (estres_hidrico "ALTO")
          (prioridad_atencion "--"))
  =>
  (modify ?s (prioridad_atencion "URGENTE"))
)

;;; R12: vulnerabilidad = "BAJA" => prioridad_atencion = "PROGRAMADA"
(defrule R12-baja-prioridad-programada
  "Vulnerabilidad BAJA permite atencion PROGRAMADA"
  ?s <- (sector
          (vulnerabilidad "BAJA")
          (prioridad_atencion "--"))
  =>
  (modify ?s (prioridad_atencion "PROGRAMADA"))
)

;;; ===========================================================
;;; CAPA 3: VIABILIDAD TECNICA Y LOGISTICA
;;; ===========================================================

;;; R13: estado_red = "Rota" => viabilidad_tecnica = "Solo_Cisternas"
(defrule R13-red-rota-solo-cisternas
  "Red rota implica viabilidad tecnica Solo_Cisternas"
  ?s <- (sector
          (estado_red "Rota")
          (viabilidad_tecnica "--"))
  =>
  (modify ?s (viabilidad_tecnica "Solo_Cisternas"))
)

;;; R14: estado_red = "Falla_Parcial" => viabilidad_tecnica = "Mixta"
(defrule R14-falla-parcial-mixta
  "Falla parcial de red implica viabilidad tecnica Mixta"
  ?s <- (sector
          (estado_red "Falla_Parcial")
          (viabilidad_tecnica "--"))
  =>
  (modify ?s (viabilidad_tecnica "Mixta"))
)

;;; R15: estado_red = "Operativa" => viabilidad_tecnica = "Solo_Red"
(defrule R15-red-operativa-solo-red
  "Red operativa implica viabilidad tecnica Solo_Red"
  ?s <- (sector
          (estado_red "Operativa")
          (viabilidad_tecnica "--"))
  =>
  (modify ?s (viabilidad_tecnica "Solo_Red"))
)

;;; R16: viabilidad_tecnica = "Solo_Cisternas" Y ruta_pl_calculada = "Verdadero" => logistica = "Lista_para_Despliegue"
(defrule R16-cisternas-ruta-lista-despliegue
  "Cisternas con ruta calculada dejan la logistica Lista_para_Despliegue"
  ?s <- (sector
          (viabilidad_tecnica "Solo_Cisternas")
          (ruta_pl_calculada "Verdadero")
          (logistica "--"))
  =>
  (modify ?s (logistica "Lista_para_Despliegue"))
)

;;; R17: viabilidad_tecnica = "Solo_Cisternas" Y ruta_pl_calculada = "Falso" => logistica = "Requiere_Calculo"
(defrule R17-cisternas-sin-ruta-requiere-calculo
  "Cisternas sin ruta calculada requieren calculo de logistica"
  ?s <- (sector
          (viabilidad_tecnica "Solo_Cisternas")
          (ruta_pl_calculada "Falso")
          (logistica "--"))
  =>
  (modify ?s (logistica "Requiere_Calculo"))
)

;;; ===========================================================
;;; CAPA 4: ACCIONES TERMINALES
;;; Nota: R21 (Alerta Roja) tiene maxima prioridad con salience
;;; alto para no ser sobreescrita por reglas de menor jerarquia.
;;; R18 y R19 usan (not ...) para ceder prioridad a R21.
;;; ===========================================================

;;; R21 (salience alto): estres_hidrico = "CRITICO" Y cisternas_disponibles = "Cero"
;;;                      => accion_final = "ALERTA ROJA: Escalar a INDECI..."
(defrule R21-alerta-roja-critico-sin-cisternas
  "ALERTA ROJA: Estres CRITICO sin cisternas disponibles - escalar a INDECI"
  (declare (salience 100))
  ?s <- (sector
          (estres_hidrico "CRITICO")
          (cisternas_disponibles "Cero")
          (accion_final "--"))
  =>
  (modify ?s (accion_final "ALERTA ROJA: Escalar a INDECI y solicitar cisternas privadas"))
)

;;; R18: prioridad_atencion = "INMEDIATA" Y logistica = "Lista_para_Despliegue"
;;;      (solo si NO aplica Alerta Roja)
(defrule R18-inmediata-lista-despliegue
  "Prioridad INMEDIATA con logistica lista: despachar convoy por ruta optima PL"
  (declare (salience 50))
  ?s <- (sector
          (prioridad_atencion "INMEDIATA")
          (logistica "Lista_para_Despliegue")
          (accion_final "--"))
  (not (sector (estres_hidrico "CRITICO") (cisternas_disponibles "Cero")))
  =>
  (modify ?s (accion_final "Despachar convoy siguiendo ruta optima PL"))
)

;;; R19: prioridad_atencion = "INMEDIATA" Y logistica = "Requiere_Calculo"
;;;      (solo si NO aplica Alerta Roja)
(defrule R19-inmediata-requiere-calculo
  "Prioridad INMEDIATA sin ruta: ejecutar modelo PL urgente"
  (declare (salience 50))
  ?s <- (sector
          (prioridad_atencion "INMEDIATA")
          (logistica "Requiere_Calculo")
          (accion_final "--"))
  (not (sector (estres_hidrico "CRITICO") (cisternas_disponibles "Cero")))
  =>
  (modify ?s (accion_final "Ejecutar modelo Programacion Lineal urgente"))
)

;;; R20: prioridad_atencion = "URGENTE" Y viabilidad_tecnica = "Mixta"
(defrule R20-urgente-mixta-aumentar-presion
  "Prioridad URGENTE con red mixta: aumentar presion y programar cisterna"
  (declare (salience 30))
  ?s <- (sector
          (prioridad_atencion "URGENTE")
          (viabilidad_tecnica "Mixta")
          (accion_final "--"))
  =>
  (modify ?s (accion_final "Aumentar presion al 60% y programar cisterna en 12h"))
)

;;; ============================================================
;;; FIN DEL ARCHIVO reglas_hidricas.clp
;;; ============================================================
