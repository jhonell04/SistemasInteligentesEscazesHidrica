"""
Sistema Experto - Mitigación de Escasez Hídrica
Flask + clipspy backend
"""

from flask import Flask, render_template, request, jsonify
import clips
import os

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RULES_FILE = os.path.join(BASE_DIR, "reglas_hidricas.clp")


def run_expert_system(facts: dict) -> dict:
    """
    Crea un entorno CLIPS, carga las reglas, inserta los hechos
    y retorna las variables inferidas.
    """
    env = clips.Environment()
    env.load(RULES_FILE)

    fact_str = (
        f'(sector '
        f'(dias_sin_agua {facts["dias_sin_agua"]}) '
        f'(nivel_reservorio "{facts["nivel_reservorio"]}") '
        f'(estado_red "{facts["estado_red"]}") '
        f'(zona "{facts["zona"]}") '
        f'(presencia_hospitales "{facts["presencia_hospitales"]}") '
        f'(clima "{facts["clima"]}") '
        f'(ruta_pl_calculada "{facts["ruta_pl_calculada"]}") '
        f'(cisternas_disponibles "{facts["cisternas_disponibles"]}")'
        f')'
    )
    env.assert_string(fact_str)
    env.run()

    result = {}
    for hecho in env.facts():
        if hecho.template.name == "sector":
            result = {
                "estres_hidrico":     hecho["estres_hidrico"],
                "vulnerabilidad":     hecho["vulnerabilidad"],
                "prioridad_atencion": hecho["prioridad_atencion"],
                "viabilidad_tecnica": hecho["viabilidad_tecnica"],
                "logistica":          hecho["logistica"],
                "accion_final":       hecho["accion_final"],
            }
            break

    return result


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/inferir", methods=["POST"])
def inferir():
    data = request.get_json()
    try:
        dias = int(data.get("dias_sin_agua", 0))
    except (ValueError, TypeError):
        dias = 0

    facts = {
        "dias_sin_agua":        dias,
        "nivel_reservorio":     data.get("nivel_reservorio", "Medio"),
        "estado_red":           data.get("estado_red", "Operativa"),
        "zona":                 data.get("zona", "Plana"),
        "presencia_hospitales": data.get("presencia_hospitales", "No"),
        "clima":                data.get("clima", "Normal"),
        "ruta_pl_calculada":    data.get("ruta_pl_calculada", "Falso"),
        "cisternas_disponibles":data.get("cisternas_disponibles", "Disponibles"),
    }

    try:
        resultado = run_expert_system(facts)
        return jsonify({"ok": True, "resultado": resultado, "hechos": facts})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500


if __name__ == "__main__":
    print("=" * 55)
    print("  Sistema Experto — Mitigación de Escasez Hídrica")
    print("  Abre tu navegador en: http://127.0.0.1:5000")
    print("=" * 55)
    app.run(debug=True)
