# PROXTEL AI AGENCY — Arquitectura técnica v3

Versión definitiva · 19 de octubre de 2026 · Agencia freelance multiagente
Estado: aprobada tras corrección del Bloque A

---

## 1. Veredicto del organigrama actual

**Veredicto: SÓLIDO.** No es necesario mover ningún rol.

La arquitectura de seis participantes es adecuada para operar varios proyectos independientes. El ajuste necesario está en la distribución de responsabilidades, los permisos de escritura y los puntos de control, no en el organigrama.

### Jerarquía operativa definitiva

    Vic
      CEO · decisiones y aprobación

    ChatGPT
      Arquitectura estratégica

    Claude Code
      Orquestación y revisión

    Codex CLI
      Implementación técnica backend

    Antigravity CLI
      Implementación frontend

    Playwright MCP
      QA funcional en navegador

### Capacidades reales y límites

| Participante | Capacidades verificadas | Responsabilidad definitiva |
|---|---|---|
| Vic | Autoridad humana y control comercial | Prioridades, aceptación, autorización de producción y merge |
| ChatGPT | Arquitectura, análisis y decisiones a partir de información recibida | Diseñar contratos, evaluar riesgos y resolver decisiones técnicas sin acceso directo al repositorio |
| Claude Code | Lee repositorios, ejecuta comandos, edita archivos, gestiona Git y dispone de /review | Orquestación, definición de tareas, revisión de código y control de integración |
| Codex CLI | Inspecciona y modifica código, ejecuta pruebas y opera con controles de aprobación y aislamiento | Backend, APIs, lógica, integraciones, infraestructura como código y correcciones |
| Antigravity CLI | Lee, edita y ejecuta código; incorpora /diff, /browser, /skills y visualización de artefactos | Implementación frontend, componentes, responsive e integración visual |
| Playwright MCP | Automatización del navegador, inspección de interfaz y validación de flujos | Pruebas E2E, regresión visual y funcional |

### Correcciones obligatorias

- Claude Code no debe convertirse en el programador principal. Coordina, revisa y cierra tareas.
- Codex no debe monopolizar el frontend. Antigravity es su responsable habitual.
- Antigravity no sustituye a Playwright. Una inspección visual no demuestra que los flujos E2E funcionen.
- ChatGPT no debe emitir diagnósticos de código no inspeccionado. Sus decisiones dependen de un State Brief verificable.
- La orquestación entre fabricantes no se presume automática. Claude coordina mediante instrucciones y archivos de entrega; no se presupone API interoperable entre las tres CLI.
- Ninguna IA autoriza su propio despliegue en producción.

**Resultado:** conservar el organigrama; especializar funciones y establecer controles de calidad antes de integrar código.

---

## 2. Ciclo operativo de 5 pasos por tarea

### 2.1 Ciclo definitivo

Cada tarea tendrá un identificador único T-XXXX, alcance cerrado, criterios de aceptación y evidencia verificable.

Regla: **ninguna tarea se considera terminada hasta superar los cinco pasos.**

| Paso | Ejecutor | Entregable | Evidencia en disco |
|---|---|---|---|
| 1. Planificación | Claude Code | Especificación, contratos, alcance y asignaciones | 01-plan.md |
| 2. Implementación backend | Codex CLI | Backend, APIs, lógica e integraciones | 02-codex.md, commits y pruebas |
| 3. Implementación frontend | Antigravity CLI | Componentes, estilos, responsive e integración visual | 03-google.md, commits y pruebas |
| 4. Auditoría de código | Claude Code mediante /review | Dictamen técnico y revisión integrada | 04-claude-review.md |
| 5. QA y auditoría visual humana | Playwright MCP + Vic | Pruebas funcionales, capturas y aprobación visual | 05-playwright.md, capturas y trazas |

### Separación definitiva de responsabilidades

- **Codex** implementa backend.
- **Antigravity** implementa frontend.
- **Claude** audita código.
- **Playwright** audita comportamiento.
- **Vic** audita visualmente el resultado.

### Paso 1 — Claude Code: planificación

Claude recibe el objetivo y:

1. Examina el repositorio y las convenciones existentes.
2. Identifica archivos, dependencias y riesgos.
3. Divide el trabajo entre Codex y Antigravity.
4. Define qué archivos puede modificar cada uno.
5. Registra pruebas exigidas y criterios de aceptación.

Entregable mínimo:

    task_id: T-XXXX
    project: nombre-del-proyecto
    objective: resultado-esperado
    base_branch: origin/main
    codex_scope: backend-y-logica
    google_scope: frontend-y-diseno
    acceptance:
      - build_correcto
      - pruebas_tecnicas_correctas
      - revision_claude_aprobada
      - playwright_aprobado
      - revision_visual_vic

### Paso 2 — Codex: implementación backend

Codex trabaja en su worktree exclusivo. Debe ejecutar las pruebas correspondientes al código modificado, documentar resultados y registrar sus cambios en una rama de tarea.

No puede modificar archivos reservados a Antigravity ni hacer merge a main.

**Salida obligatoria:** CODEX_PASS, CODEX_FAIL o CODEX_BLOCKED, acompañada de evidencia. El estado PASS nunca se declara únicamente por respuesta del modelo.

### Paso 3 — Antigravity: implementación frontend (solo)

Antigravity recibe de Claude el contrato técnico y el alcance frontend autorizado.

Sus responsabilidades son implementar componentes, interfaces, estilos, estados visuales y comportamiento responsive; integrar los contratos API definidos; ejecutar pruebas técnicas correspondientes; y registrar cambios, commits y resultados en 03-google.md.

**Prohibición:** Antigravity no puede emitir el dictamen independiente de aprobación visual sobre su propia implementación.

El resultado será FRONTEND_PASS, FRONTEND_FAIL o FRONTEND_BLOCKED, referido exclusivamente al cumplimiento de implementación y pruebas técnicas, **no a una certificación visual independiente**.

### Paso 4 — Claude Code: integración y /review

**Gate técnico obligatorio.**

Claude reúne las ramas aprobadas de Codex y Antigravity en una rama candidata de integración, **nunca directamente en main**.

Revisa el diff completo frente a la base correcta y ejecuta:

    /review

/review es alias oficial de /code-review; admite revisión del diff actual o un objetivo como rama o PR. Su disponibilidad concreta debe comprobarse en la versión instalada.

La revisión debe cubrir:

- Errores lógicos, seguridad y regresiones.
- Contratos entre frontend y backend.
- Integridad de datos, autenticación y autorizaciones.
- Cambios fuera del alcance.
- Resultados de las pruebas técnicas.

**Dictamen permitido:** REVIEW_PASS, REVIEW_FAIL o REVIEW_BLOCKED.

Ante un fallo, Claude reasigna la corrección al implementador responsable. Todo cambio posterior obliga a repetir la revisión afectada.

**No se permite reemplazar /review por un simple resumen de Claude.**

### Paso 5 — Playwright MCP + Vic: QA y auditoría visual final

Playwright MCP, coordinado por Claude, valida el comportamiento de la versión integrada que ya superó /review.

Verifica navegación, formularios, flujos E2E, errores JavaScript, integraciones visibles y regresiones, además de generar las capturas y trazas necesarias.

**Gate visual humano obligatorio:** Vic revisa las capturas producidas por Playwright y determina si la interfaz cumple el diseño aprobado, la coherencia visual y los criterios responsive.

Claude registra ambas decisiones en 05-playwright.md:

- QA_PASS, QA_FAIL o QA_BLOCKED: resultado funcional de Playwright.
- VISUAL_PASS, VISUAL_FAIL o VISUAL_BLOCKED: resultado de la revisión humana de Vic.

La tarea solo supera el paso 5 cuando **ambos resultados son PASS**.

Si Vic rechaza el resultado visual, Claude devuelve la tarea a Antigravity para corrección. Después se repiten /review y las pruebas pertinentes de Playwright.

**Condición de cierre:** revisión aprobada + QA aprobado + revisión visual Vic aprobada + aceptación de Vic.

---

## 3. Protocolo de concurrencia

### 3.1 Principio de aislamiento

Un repositorio por cliente, una rama por unidad de trabajo y un worktree independiente por escritor concurrente.

Git worktree permite múltiples directorios de trabajo ligados al mismo repositorio, con ramas independientes y estado Git propio.

### 3.2 Convención de ramas

| Rama | Propietario | Uso |
|---|---|---|
| main | Controlado por Vic desde PC | Versión aprobada |
| task/T-XXXX-api | Codex | Backend e integraciones |
| task/T-XXXX-ui | Antigravity | Frontend y estilos |
| task/T-XXXX-int | Claude Code | Integración y revisión |

No todas las tareas requieren dos ramas de implementación. Si una tarea no modifica frontend, se omite la rama UI.

### 3.3 Creación de worktrees en Windows

Desde PowerShell, dentro de la raíz del repositorio correspondiente:

    git fetch --prune origin

    $repoName = Split-Path -Leaf (git rev-parse --show-toplevel)

    git worktree add -b task/T-0001-api "../${repoName}-T-0001-api" origin/main
    git worktree add -b task/T-0001-ui  "../${repoName}-T-0001-ui"  origin/main
    git worktree add -b task/T-0001-int "../${repoName}-T-0001-int" origin/main

    git worktree list

T-0001 es un identificador ilustrativo. El nombre real debe sustituirse por el asignado a cada tarea.

**Precondiciones:** origin/main debe existir, las tres ramas no deben existir previamente y cada directorio de destino debe estar libre.

### 3.4 Matriz de permisos

| Operación | Claude | Codex | Antigravity | Vic |
|---|---|---|---|---|
| Leer código autorizado | Sí | Sí | Sí | Sí |
| Escribir en worktree Codex | No | Sí | No | Sí |
| Escribir en worktree UI | No | No | Sí | Sí |
| Crear rama de integración | Sí | No | No | Sí |
| Resolver conflictos de integración | Sí | No | No | Sí |
| Ejecutar /review obligatorio | Sí | No | No | — |
| Ejecutar QA mediante MCP | Coordina | No | No | Supervisa |
| Autorizar merge a main | No | No | No | Sí |
| Ejecutar merge autorizado desde PC | Sí | No | No | Sí |
| Desplegar producción | Solo con autorización | No | No | Autoriza |

Nota: Claude puede solicitar correcciones, pero no debe reimplementar trabajo ajeno salvo contingencia autorizada.

### 3.5 Reglas de bloqueo

- Nunca dos agentes editando simultáneamente el mismo worktree.
- Nunca dos ramas editando el mismo contrato compartido sin coordinación.
- Migraciones, archivos de dependencias, configuraciones globales y contratos API tienen un propietario único por tarea.
- Un conflicto de merge detiene la integración.
- No se permite git push --force sobre ramas compartidas ni main.
- Los cambios fuera de alcance requieren nueva asignación.

### 3.6 Política de merge

Claude integra las ramas técnicas en task/T-XXXX-int. Una vez aprobados /review, Playwright y revisión visual de Vic, solicita autorización a Vic. Solo entonces Claude o Vic ejecutan el merge desde la PC principal.

**Prohibidos:** automerge a main y promoción directa desde Mac.

---

## 4. Protocolo State Brief para ChatGPT

ChatGPT trabaja sin acceso directo al repositorio. Su entrada obligatoria es un resumen del estado real del proyecto.

### 4.1 Comandos previos a cada sesión estratégica

El State Brief será equivalente en Windows y macOS. Ambos scripts generan:

    <REPO_ROOT>/.agency-local/briefs/STATE-BRIEF.txt

Los informes mantienen exactamente los mismos once encabezados y el mismo orden.

#### Windows — PowerShell 7

Abrir PowerShell en la raíz del repositorio del cliente.

    $ErrorActionPreference = "Stop"

    if ((git rev-parse --is-inside-work-tree) -ne "true") {
        throw "No estás dentro de un repositorio Git."
    }

    Set-Location (git rev-parse --show-toplevel)

    New-Item -ItemType Directory -Force ".agency-local/briefs" | Out-Null

    $report = ".agency-local/briefs/STATE-BRIEF.txt"

    & {
        "=== PROJECT ==="
        git rev-parse --show-toplevel

        "=== CURRENT BRANCH ==="
        git branch --show-current

        "=== GIT STATUS ==="
        git status --short --branch

        "=== RECENT COMMITS ==="
        git log -5 --date=short --format='%h %ad %s'

        "=== ACTIVE WORKTREES ==="
        git worktree list

        "=== LOCAL BRANCHES ==="
        git branch -vv

        "=== MODIFIED FILES ==="
        git diff --name-only
        git diff --cached --name-only

        "=== CHANGE SUMMARY ==="
        git diff --stat
        git diff --cached --stat

        "=== COMMITS VS ORIGIN/MAIN ==="
        git show-ref --verify --quiet refs/remotes/origin/main

        if ($LASTEXITCODE -eq 0) {
            git log --oneline origin/main..HEAD
            git diff --stat origin/main...HEAD
        } else {
            "origin/main no disponible"
        }

        "=== PROJECT SKILLS ==="
        if (Test-Path "PROJECT-SKILLS.md") {
            Get-Content "PROJECT-SKILLS.md"
        } else {
            "PROJECT-SKILLS.md no localizado"
        }

        "=== LOCAL TASK EVIDENCE ==="
        if (Test-Path ".agency-local/audit") {
            Get-ChildItem ".agency-local/audit" -Directory | Select-Object -ExpandProperty Name
        } else {
            "Sin registros locales de auditoría"
        }

    } | Tee-Object -FilePath $report

    Write-Host ""
    Write-Host "STATE BRIEF GENERADO:"
    Write-Host (Resolve-Path $report)

#### macOS — Bash / Zsh

Abrir Terminal en la raíz del repositorio del cliente.

    (
        set -e
        set -o pipefail

        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "No estás dentro de un repositorio Git." >&2
            exit 1
        fi

        cd "$(git rev-parse --show-toplevel)"

        mkdir -p ".agency-local/briefs"

        report=".agency-local/briefs/STATE-BRIEF.txt"

        {
            echo "=== PROJECT ==="
            git rev-parse --show-toplevel

            echo "=== CURRENT BRANCH ==="
            git branch --show-current

            echo "=== GIT STATUS ==="
            git status --short --branch

            echo "=== RECENT COMMITS ==="
            git log -5 --date=short --format='%h %ad %s'

            echo "=== ACTIVE WORKTREES ==="
            git worktree list

            echo "=== LOCAL BRANCHES ==="
            git branch -vv

            echo "=== MODIFIED FILES ==="
            git diff --name-only
            git diff --cached --name-only

            echo "=== CHANGE SUMMARY ==="
            git diff --stat
            git diff --cached --stat

            echo "=== COMMITS VS ORIGIN/MAIN ==="
            if git show-ref --verify --quiet refs/remotes/origin/main; then
                git log --oneline origin/main..HEAD
                git diff --stat origin/main...HEAD
            else
                echo "origin/main no disponible"
            fi

            echo "=== PROJECT SKILLS ==="
            if [ -f "PROJECT-SKILLS.md" ]; then
                cat "PROJECT-SKILLS.md"
            else
                echo "PROJECT-SKILLS.md no localizado"
            fi

            echo "=== LOCAL TASK EVIDENCE ==="
            if [ -d ".agency-local/audit" ]; then
                for directory in .agency-local/audit/*/; do
                    [ -d "$directory" ] || continue
                    basename "$directory"
                done
            else
                echo "Sin registros locales de auditoría"
            fi

        } | tee "$report"

        echo ""
        echo "STATE BRIEF GENERADO:"
        echo "$(pwd)/$report"
    )

### 4.2 Contenido obligatorio del State Brief

Además del resultado anterior, pegar:

    STATE_BRIEF:
      proyecto: nombre
      objetivo: descripcion
      tarea_actual: T-XXXX
      maquina: PC_o_Mac
      ultimo_resultado: PASS_FAIL_BLOCKED
      fase_actual: 1_2_3_4_5
      problema_observado: descripcion
      pruebas_ejecutadas: resultados
      decision_requerida: pregunta
      archivos_relevantes: rutas
      restricciones: condiciones

Acompañar con el extracto del error o de la revisión relevante, no con todos los logs del proyecto.

### 4.3 Autoridad de decisión

| ChatGPT puede decidir | Requiere inspección o ejecución de Claude Code |
|---|---|
| Arquitectura propuesta | Verificar arquitectura implementada |
| Patrones técnicos | Comprobar compatibilidad real |
| Riesgos y prioridades | Confirmar dónde aparecen en el código |
| Criterios de aceptación | Ejecutar o coordinar las validaciones |
| Asignación recomendada de tareas | Confirmar archivos y dependencias reales |
| Contratos e interfaces propuestas | Verificar consumidores y productores existentes |
| Estrategia de corrección | Comprobar causa, diff y consecuencias |
| Recomendación de release | Confirmar gates técnicos y solicitar autorización |

**Regla de autoridad:** ChatGPT define el qué y las restricciones; Claude determina el cómo compatible con el repositorio real.

ChatGPT no puede declarar un PASS basándose únicamente en descripciones del comportamiento esperado.

---

## 5. Mecanismo de reruteo de cuotas

### 5.1 Asignación normal

| Recurso | Trabajo asignado | Política |
|---|---|---|
| Claude Sonnet | Orquestación y /review | Predeterminado |
| Claude Opus | Arquitectura compleja | Uso excepcional |
| Codex CLI | Implementación técnica backend | Motor principal backend |
| Antigravity / Google | Implementación frontend | Motor principal visual |
| Playwright MCP | Validación en navegador | Gate independiente |

Claude permite seleccionar modelos mediante /model. Documentación recomienda Sonnet para la mayoría de tareas y Opus para razonamiento arquitectónico exigente.

### 5.2 Medición

Consultar al menos al inicio de jornada y antes de asignar trabajo considerable:

| CLI | Comando interactivo |
|---|---|
| Claude Code | /usage |
| Codex CLI | /status (cuando presente información de límites) |
| Antigravity CLI | /usage o /quota |

Definición operativa: R = menor porcentaje de cuota restante entre las ventanas que limitan al recurso.

Ejemplo: si quedan 60% en una ventana y 12% en otra, para asignación se usa R = 12%.

Los siguientes umbrales son políticas internas propuestas, no límites garantizados por los proveedores.

### 5.3 Umbrales de reruteo

| Cuota restante R | Estado operativo | Acción |
|---|---|---|
| Mayor de 30% | Normal | Asignaciones habituales |
| 15–30% | Reserva | No iniciar tareas grandes; priorizar pendientes |
| 5–15% | Crítico | Solo trabajo indispensable y cierre |
| 5% o menos | Protección | Detener nuevas asignaciones |
| Límite real alcanzado | Bloqueo | Reasignar o esperar restablecimiento |

### 5.4 Reglas por proveedor

#### Claude

- Sonnet es el modelo predeterminado.
- Opus se permite para decisiones arquitectónicas complejas y justificadas; se suspende preventivamente cuando R ≤ 30%.
- Cuando Sonnet llegue a R ≤ 20%, reservar capacidad para coordinación mínima y /review.
- Si Claude no puede completar el /review obligatorio, se bloquea la promoción a QA. No se sustituye silenciosamente por otra IA.

#### Codex

- Con R ≤ 20%, no recibe tareas técnicas nuevas de gran alcance.
- Cualquier frontend pendiente se asigna directamente a Google (Antigravity).
- Ante agotamiento, se conservan ramas y evidencias; el backend pendiente no se declara terminado.
- Una reasignación extraordinaria de backend requiere que Claude confirme que la tarea es acotada y que el nuevo ejecutor puede cumplirla.

#### Antigravity / Google

- Siempre tiene prioridad para frontend.
- Con R ≤ 20%, prioriza corregir problemas visuales de tareas ya implementadas.
- Con cuota agotada, Codex puede absorber un cambio frontend imprescindible si dispone de capacidad y Claude autoriza el cambio de propietario.
- Playwright sigue siendo obligatorio, independientemente del resultado de la auditoría visual.

### 5.5 Regla económica

No se habilitan automáticamente créditos adicionales, APIs de pago por consumo ni cambios de suscripción.

Si un proveedor ofrece consumo extraordinario, requiere autorización expresa de Vic.

Objetivo del reruteo: preservar continuidad sin sacrificar los gates de seguridad y calidad.

---

## 6. Integración de skills on-demand

### 6.1 Modelo de dos niveles

Se conservan únicamente:

- registry.md: catálogo general de capacidades reutilizables.
- PROJECT-SKILLS.md: habilidades y restricciones requeridas por un proyecto concreto.

No se crean nueve departamentos ni nuevos agentes.

### 6.2 Rutas concretas y estructura del Core

#### Ubicaciones oficiales

| Elemento | Windows — PC Master | macOS — MacBook Pro |
|---|---|---|
| Core de agencia | C:\DEV\PROXTEL-AI-AGENCY\ | ~/DEV/PROXTEL-AI-AGENCY/ |
| Registro global | C:\DEV\PROXTEL-AI-AGENCY\skills\registry.md | ~/DEV/PROXTEL-AI-AGENCY/skills/registry.md |
| Bootstrap | C:\DEV\PROXTEL-AI-AGENCY\bootstrap\ | ~/DEV/PROXTEL-AI-AGENCY/bootstrap/ |
| Documentación | C:\DEV\PROXTEL-AI-AGENCY\docs\ | ~/DEV/PROXTEL-AI-AGENCY/docs/ |
| Skills por proyecto | <REPO_ROOT>\PROJECT-SKILLS.md | <REPO_ROOT>/PROJECT-SKILLS.md |

#### Estructura definitiva del Core

    PROXTEL-AI-AGENCY/
    │
    ├── skills/
    │   ├── registry.md
    │   └── [skills-globales-aprobadas]/
    │
    ├── bootstrap/
    │   ├── windows-setup.ps1
    │   └── mac-setup.sh
    │
    └── docs/
        ├── architecture.md
        ├── certification-plan.md
        └── lessons/

#### Responsabilidades

| Elemento | Responsabilidad |
|---|---|
| skills/registry.md | Catálogo oficial de skills globales, versiones y usos registrados |
| bootstrap/windows-setup.ps1 | Preparación y verificación del entorno Windows |
| bootstrap/mac-setup.sh | Preparación y verificación del entorno macOS |
| docs/architecture.md | Arquitectura técnica aprobada de la agencia |
| docs/certification-plan.md | Plan de certificación, criterios y resultados |
| docs/lessons/ | Lecciones técnicas reutilizables, depuradas de información privada |
| PROJECT-SKILLS.md | Capacidades y restricciones autorizadas exclusivamente para cada proyecto |

Regla: el Core es compartido mediante Git. Cada proyecto conserva su repositorio, configuración y contexto independientes.

### 6.3 Activación por demanda

1. Claude recibe una tarea y consulta PROJECT-SKILLS.md.
2. Busca en registry.md las capacidades necesarias.
3. Selecciona únicamente las aplicables.
4. Activa o entrega las instrucciones compatibles con la CLI ejecutora.
5. Registra el uso y su resultado en la evidencia de tarea.

Las skills no deben cargarse todas en cada sesión. Claude Code y Antigravity admiten capacidades de skills locales, pero sus mecanismos nativos de descubrimiento y activación no son idénticos. El registro común será una capa documental de coordinación, no un instalador universal supuesto.

### 6.4 Promoción de proyecto a global

**Regla definitiva:** mínimo 3 usos satisfactorios en al menos 2 proyectos independientes.

Se consideran usos distintos únicamente cuando corresponden a tareas identificables, no a reintentos de una misma tarea.

| Skill | Proyecto A | Proyecto B | Promoción |
|---|---|---|---|
| laravel-crud | 2 | 1 | Elegible |
| asterisk-pjsip | 3 | 0 | No |
| responsive-audit | 1 | 2 | Elegible |
| tradingview-widget | 1 | 1 | No |

La promoción exige además:

- No contener secretos ni información privada de clientes.
- Ser parametrizable.
- Haber superado las pruebas de sus usos registrados.
- Contar con versión y responsable de mantenimiento.
- Aprobación de Claude para compatibilidad y de Vic para promoción.

La promoción no implica activación automática en todos los proyectos.

### 6.5 Regla de aislamiento

Las skills globales son reutilizables, pero los contextos de clientes no se comparten.

Una skill puede definir cómo construir un módulo Asterisk; no puede transportar credenciales, configuraciones privadas ni datos de una PBX de un cliente a otra.

---

## 7. Arquitectura dual PC ↔ Mac

### 7.1 Autoridad de máquinas

| Responsabilidad | Windows PC | MacBook Pro |
|---|---|---|
| Máquina maestra | Sí | No |
| Repositorios de clientes | Sí | Réplicas mediante Git |
| Desarrollo en ramas | Sí | Sí |
| Worktrees locales | Sí | Sí |
| Auditorías locales | Sí | Sí |
| Push de ramas de tarea | Sí | Sí |
| Merge a main | Sí, autorizado | Prohibido |
| Push a main | Sí, autorizado | Prohibido |
| Despliegue de producción | Según autorización | No es autoridad principal |

### 7.2 Protocolo pull-first en Mac

Antes de trabajar en cualquier proyecto:

    git status --short --branch
    git switch main
    git fetch --prune origin
    git pull --ff-only origin main
    git worktree list

**Precondición:** no debe haber cambios locales pendientes que impidan cambiar a main.

Para trabajar en una rama remota ya publicada:

    git fetch origin
    git switch --track origin/task/T-0001-api

El segundo comando es para una rama que todavía no tenga seguimiento local y no esté ocupada por otro worktree.

La Mac debe crear sus propios worktrees locales cuando necesite concurrencia; no copiar los de Windows.

### 7.3 Protocolo de escritura entre máquinas

**Nunca se trabaja simultáneamente sobre la misma rama desde PC y Mac.** Una rama tiene una sola máquina escritora activa.

Transferencia de control:

1. La máquina actual confirma cambios guardados, commit y push.
2. Se declara libre la rama.
3. La otra máquina hace fetch y actualiza su copia.
4. Comienza a escribir solo cuando el estado remoto coincide con el esperado.

No se utilizan copias manuales, sincronización de carpetas ni servicios ajenos a Git.

### 7.4 Elementos que viajan por Git

| Elemento | Se sincroniza |
|---|---|
| Código fuente aprobado para versionado | Sí |
| Commits y ramas publicadas | Sí |
| Archivos de configuración no secretos | Sí |
| PROJECT-SKILLS.md | Sí |
| registry.md y skills globales (cuando pertenezcan a repo Git autorizado) | Sí |
| Directorios físicos de worktrees | No |
| Metadatos administrativos locales de worktrees | No |
| .agency-local/audit/ | No |
| Capturas, trazas y logs locales | No |
| Credenciales y .env privados | No |

**Regla fundamental:** las ramas y sus commits sí viajan por Git; los directorios físicos de worktrees y sus metadatos locales no.

### 7.5 Evidencia local de auditoría

Estructura lógica dentro de cada repositorio:

    repositorio-cliente/
    ├── PROJECT-SKILLS.md
    ├── .gitignore
    └── .agency-local/                  NO VERSIONADO
        ├── briefs/
        │   └── STATE-BRIEF.txt
        └── audit/
            └── T-XXXX/
                ├── 01-plan.md
                ├── 02-codex.md
                ├── 03-google.md
                ├── 04-claude-review.md
                ├── 05-playwright.md
                ├── screenshots/
                ├── traces/
                └── logs/

Regla para .gitignore:

    .agency-local/

Esta exclusión protege los archivos no rastreados; si alguno ya fue incorporado al índice Git, deberá retirarse del seguimiento de forma controlada.

Los estados de aprobación pueden incluirse en los commits o mensajes de integración sin adjuntar las auditorías privadas.

### 7.6 Recuperación y continuidad

**Escenario A — PC disponible:** trabajo normal. Mac se mantiene actualizada mediante Git.

**Escenario B — PC indisponible:** Mac puede continuar tareas en ramas independientes y publicarlas. Se pospone la integración definitiva en main hasta recuperar la autoridad de la PC.

**Escenario C — conflicto entre máquinas:** se detiene la escritura, se comparan commits y se resuelve en rama de tarea. No se permite forzar la historia.

**Escenario D — auditorías perdidas:** los commits permanecen, pero la evidencia local no puede reconstruirse automáticamente. Deben repetirse las validaciones necesarias antes de certificar una tarea.

### 7.7 CERTIFICATION_GATE

#### Ubicación oficial

    <REPO_ROOT>/
    └── .agency-local/
        └── audit/
            └── T-XXXX/
                ├── 01-plan.md
                ├── 02-codex.md
                ├── 03-google.md
                ├── 04-claude-review.md
                ├── 05-playwright.md
                ├── 06-certification.yaml
                ├── screenshots/
                ├── traces/
                └── logs/

#### Propiedad del gate

- Responsable de escritura: Claude Code.
- Responsable de aprobación visual: Vic.
- Responsable de verificación: Claude Code.
- Responsable de autorización de merge: Vic.

Codex y Antigravity no pueden emitir ni modificar la certificación final.

#### Contrato de 06-certification.yaml

    task_id: T-XXXX

    candidate_branch: task/T-XXXX-int
    candidate_commit: "<COMMIT_SHA>"

    implementation_backend:
      status: PASS
      evidence: 02-codex.md

    implementation_frontend:
      status: PASS
      evidence: 03-google.md

    claude_review:
      status: PASS
      evidence: 04-claude-review.md

    playwright_qa:
      status: PASS
      evidence: 05-playwright.md

    visual_review_vic:
      status: PASS
      reviewer: Vic
      evidence: 05-playwright.md#revision-visual-vic

    acceptance_vic:
      status: APPROVED
      evidence: 05-playwright.md#aceptacion-vic

    main_merge_machine: WINDOWS_PC
    audit_versioned: false
    worktrees_synced: false

    status: READY_FOR_MERGE_AUTHORIZATION

Los valores PASS son ilustrativos: Claude debe escribirlos únicamente cuando estén respaldados por evidencias reales. Un componente inexistente en una tarea podrá registrarse como NOT_APPLICABLE, con justificación expresa y sin omitir /review, Playwright ni las aprobaciones humanas correspondientes.

#### Verificación obligatoria

Antes de generar 06-certification.yaml, Claude comprueba:

1. Que existan los archivos de evidencia referenciados.
2. Que cada resultado PASS esté respaldado por el archivo correspondiente y no contradiga sus resultados.
3. Que 04-claude-review.md contenga la revisión aprobada.
4. Que 05-playwright.md documente las pruebas funcionales aprobadas.
5. Que el informe de Playwright contenga la revisión visual explícita de Vic y su decisión.
6. Que la aceptación final de Vic esté documentada expresamente, sin inferirla del resultado de Playwright.
7. Que candidate_commit coincida con el commit integrado que se revisó y probó.
8. Que no existan modificaciones de código posteriores que invaliden las pruebas.

Los campos evidence son rutas relativas al directorio T-XXXX/. Los fragmentos precedidos de # identifican apartados obligatorios dentro del archivo Markdown correspondiente.

Si algún archivo falta, su contenido no respalda el resultado o la versión del código no coincide, **el gate queda bloqueado**.

Una revisión efectuada en Mac no sustituye automáticamente la evidencia local de PC. Para solicitar merge desde PC, Claude debe disponer allí de evidencias verificables y, si es necesario, repetir las validaciones correspondientes.

#### Condición para solicitar merge

El estado READY_FOR_MERGE_AUTHORIZATION solamente es válido cuando todos los gates aplicables están completos.

Secuencia obligatoria:

    Implementación terminada
              ↓
    Claude /review = PASS
              ↓
    Playwright QA = PASS
              ↓
    Vic Visual = PASS
              ↓
    Vic Acceptance = APPROVED
              ↓
    Claude verifica evidencias y commit
              ↓
    Claude escribe 06-certification.yaml
              ↓
    READY_FOR_MERGE_AUTHORIZATION
              ↓
    Claude solicita autorización a Vic
              ↓
    Vic autoriza merge
              ↓
    Merge a main desde Windows PC

**Regla absoluta:** sin 06-certification.yaml completo, válido y verificado, Claude no puede solicitar autorización de merge a Vic.

El estado READY_FOR_MERGE_AUTHORIZATION no significa que la integración a main ya haya ocurrido.

### 7.8 Incorporación de proyectos existentes

#### Política de adopción gradual

Los proyectos existentes i-Tkt, TRDStation y PROXTEL PBX no se migrarán al nuevo flujo durante la primera semana.

La prioridad inicial es certificar la operación multiagente mediante un proyecto piloto descartable, aislado y sin dependencias productivas.

| Periodo | Alcance autorizado | Restricción |
|---|---|---|
| Semana 1 | Certificación del flujo completo con piloto descartable | Prohibido migrar proyectos existentes |
| Semana 2 | Evaluación de resultados, ajustes del Core y preparación de incorporación | Sin migraciones automáticas |
| Desde semana 3 | Incorporación gradual de proyectos existentes | Solo después de cerrar el trabajo en curso y crear PROJECT-SKILLS.md |

#### Condiciones obligatorias de incorporación

Cada proyecto deberá cumplir lo siguiente antes de adoptar el nuevo flujo:

1. Cerrar o estabilizar la tarea en curso, sin cambios de arquitectura durante su ejecución.
2. Confirmar el estado del repositorio y conservar su historial Git.
3. Crear y revisar su propio PROJECT-SKILLS.md.
4. Identificar restricciones, tecnologías y contratos existentes.
5. Comenzar la siguiente tarea nueva utilizando el ciclo certificado de cinco pasos.

**Prohibiciones:** no reescribir repositorios, no alterar arquitecturas funcionales por adoptar la agencia, no migrar tareas activas a mitad de ejecución y no compartir auditorías ni información privada entre clientes.

La incorporación se realizará proyecto por proyecto, sin afectar la continuidad de las operaciones existentes.

---

**Fin del documento.**
