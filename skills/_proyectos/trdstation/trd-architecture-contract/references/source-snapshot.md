# Source Snapshot — _SKELETON-10-CONTRATOS.md

**Hash SHA256:** 112C80F93FF572DD42A54FEE5F9721316533F800AD4E883F62C0629109E7D06B
**Tamaño:** 8182 bytes
**Líneas:** 191
**Fecha del snapshot:** 2026-10-21T02:31:01Z
**Commit fuente:** 9031326 (trdstation-core)
**Ruta fuente:** trdstation-core/docs/architecture/_SKELETON-10-CONTRATOS.md

Este archivo es una copia congelada del esqueleto de contratos para trazabilidad.
La fuente normativa es el archivo en trdstation-core/docs/architecture/.
Si el esqueleto cambia en origen, este snapshot queda obsoleto hasta regenerarlo.

---
1. PRODUCT-CONTRACT.md
Propósito: Define la identidad, el alcance y los límites del producto TRDStation como plataforma de trading simulado B-Book White Label Dedicated.

Debe contener:
- Objetivo comercial y funcional del producto.
- Modelo Dedicated / Single-Tenant por instalación.
- Capacidades principales: trading, Manager, CRM y Client Office.
- Separación de responsabilidades Core / Broker / Deploy.
- Módulos obligatorios, opcionales y futuros.
Consumidores: Todos.

Fase: Etapa 1 — Arquitectura.

Reglas duras:
- Una instalación representa un cliente independiente y aislado.
- No convertir el producto en un SaaS multi-tenant compartido.
- El Control Plane no puede ser dependencia del runtime.
2. CORE-CONTRACT.md
Propósito: Define los límites y responsabilidades de trdstation-core como autoridad central del sistema.

Debe contener:
- Dominios backend y sus responsabilidades.
- Límites entre Core, Broker y servicios externos.
- API REST versionada /api/v1/.
- Persistencia PostgreSQL, Redis y componentes backend.
- Ownership de datos, operaciones y eventos.
Consumidores: Core, Broker y Deploy.

Fase: Etapa 1 — Arquitectura.

Reglas duras:
- Core es la única fuente de verdad del trading.
- Toda mutación de trading pasa por Trading Engine.
- No romper contratos publicados sin versionado y ADR.
3. BROKER-CONTRACT.md
Propósito: Define trdstation-broker como aplicación de presentación white label, sin autoridad sobre operaciones financieras.

Debe contener:
- Responsabilidades de Client Office, WebTrader y demás interfaces.
- Stack Laravel / Inertia / React / TypeScript.
- Integración con Core mediante REST y WebSocket.
- Arquitectura IChartAdapter y TRDLineToolsAdapter.
- Branding, temas, preferencias y feature flags.
Consumidores: Broker y Core.

Fase: Etapa 1 — Arquitectura.

Reglas duras:
- Broker nunca calcula canónicamente posiciones, balance, margen o P&L.
- No inventar endpoints ni contratos de eventos.
- No acoplar componentes UI directamente a plugins de gráficas.
4. DEPLOY-CONTRACT.md
Propósito: Define cómo instalar, operar, actualizar y recuperar instalaciones independientes de TRDStation.

Debe contener:
- Topología Dedicated por cliente.
- Provisionamiento de Core, Broker, PostgreSQL, Redis y servicios.
- Variables de entorno, dominios, certificados y secretos.
- Instalación, upgrade, rollback y health checks.
- Backups, restore y certificación pre-flight.
Consumidores: Deploy, Core y Broker.

Fase: Etapa 1 — Arquitectura; implementación en Etapa 11.

Reglas duras:
- Cada cliente mantiene infraestructura, datos y secretos aislados.
- Deploy nunca incorpora lógica de negocio.
- Ningún agente ejecuta cambios automáticos en producción.
5. MARKET-DATA-CONTRACT.md
Propósito: Define la frontera entre proveedores externos de datos de mercado y los consumidores internos de TRDStation.

Debe contener:
- Arquitectura Provider Adapter → Market Data Gateway.
- Contrato normalizado MARKET-DATA-v1.
- Separación de raw provider data y derived/trading pricing.
- Responsabilidades de quotes, candles e históricos.
- Manejo de errores, disponibilidad y certificación.
Consumidores: Core, Broker y Deploy.

Fase: Etapa 1 — Arquitectura; implementación en Etapa 3.

Reglas duras:
- FMP nunca se consume directamente desde el navegador.
- Credenciales del proveedor exclusivamente server-side.
- Ningún formato específico del proveedor se filtra al dominio de trading o UI.
6. TRADING-DOMAIN-CONTRACT.md
Propósito: Define las fronteras, invariantes y responsabilidades del dominio financiero y del Trading Engine.

Debe contener:
- Entidades Account, Order, Deal, Position y Ledger.
- Responsabilidades de ejecución, SL/TP y órdenes pendientes.
- Reglas de balance, equity, margin, P&L y risk.
- Precisión numérica y persistencia financiera.
- Auditabilidad, correlación e integridad del ledger.
Consumidores: Core y Broker.

Fase: Etapa 1 — Arquitectura; implementación en Etapa 5.

Reglas duras:
- Dinero y cálculos financieros canónicos utilizan DECIMAL/NUMERIC.
- Ledger append-only; correcciones mediante registros compensatorios.
- Manager y Broker no alteran directamente el estado canónico del trading.
7. REALTIME-CONTRACT.md
Propósito: Define cómo se publican, transportan y consumen eventos realtime entre Core y Broker.

Debe contener:
- Arquitectura Redis / Reverb / Laravel Echo.
- Catálogo de eventos versionados.
- Estructura de payloads y esquemas de eventos.
- Canales privados y reglas de autorización.
- Manejo de reconexión, errores y sincronización de estado.
Consumidores: Core, Broker y Deploy.

Fase: Etapa 1 — Arquitectura; infraestructura en Etapa 2 e integración progresiva.

Reglas duras:
- Los eventos comunican estado; no sustituyen la autoridad del Core.
- Los canales privados requieren autorización.
- Cambios incompatibles en eventos requieren versionado y pruebas de compatibilidad.
8. WHITE-LABEL-CONTRACT.md
Propósito: Define la personalización de cada instalación sin fragmentar el producto canónico.

Debe contener:
- Modelo de configuración por instalación.
- Branding: nombre, dominio, logos, colores y temas.
- Idioma, moneda y símbolos disponibles.
- Feature flags y módulos habilitables.
- Separación de configuración, assets y código canónico.
Consumidores: Core, Broker y Deploy.

Fase: Etapa 1 — Arquitectura; implementación en Etapa 10.

Reglas duras:
- Una sola base de código para todos los clientes.
- Personalización mediante configuración, assets y feature flags.
- Prohibidos forks por cliente salvo excepción aprobada mediante ADR.
9. TELEPHONY-CONTRACT.md
Propósito: Define la telefonía como integración opcional, desacoplada del CRM y del dominio de trading.

Debe contener:
- TelephonyProviderInterface.
- NullTelephonyProvider y ProxtelTelephonyProvider.
- Configuración TELEPHONY_ENABLED y TELEPHONY_PROVIDER.
- Frontera entre CRM, adapter y proveedor.
- Extensibilidad hacia otros proveedores de telefonía.
Consumidores: Core, Broker y Deploy.

Fase: Etapa 1 — Arquitectura; implementación en Etapa 9.

Reglas duras:
- CRM funciona completamente sin telefonía.
- PROXTEL nunca es dependencia obligatoria del producto.
- Cambiar proveedor no requiere modificar CRM ni Trading Engine.
10. SECURITY-CONTRACT.md
Propósito: Define los controles de seguridad transversales para código, infraestructura, acceso, datos y operación.

Debe contener:
- Identidad, autenticación, RBAC y 2FA.
- Protección de secretos y aislamiento de ambientes.
- CSP, secure headers y rate limiting.
- Seguridad de APIs, eventos y canales privados.
- Auditoría, backups, restore y restricciones operativas.
Consumidores: Todos.

Fase: Etapa 1 — Arquitectura; aplicación transversal desde Etapa 2.

Reglas duras:
- Nunca incluir secretos en Git, prompts o logs.
- 2FA obligatorio para Manager/Admin.
- Ningún agente puede modificar producción automáticamente.

Tabla resumen
Contrato	Fase de definición	Consumidores
PRODUCT	Etapa 1	Todos
CORE	Etapa 1	Core, Broker, Deploy
BROKER	Etapa 1	Broker, Core
DEPLOY	Etapa 1	Deploy, Core, Broker
MARKET-DATA	Etapa 1	Core, Broker, Deploy
TRADING-DOMAIN	Etapa 1	Core, Broker
REALTIME	Etapa 1	Core, Broker, Deploy
WHITE-LABEL	Etapa 1	Core, Broker, Deploy
TELEPHONY	Etapa 1	Core, Broker, Deploy
SECURITY	Etapa 1	Todos
Regla transversal para la skill
La skill trd-architecture-contract debe permitir que Claude Code y Codex:
1. Identifiquen los contratos aplicables según repositorio, dominio y alcance del Task Contract.
2. Distingan contratos pendientes, definidos y aprobados, sin interpretar este esqueleto como un contrato definitivo.
3. Declaren dependencias y contradicciones arquitectónicas antes de planificar una implementación.
4. Bloqueen la planificación de código funcional cuando falte un contrato obligatorio aprobado.
5. No modifiquen contratos canónicos automáticamente: cualquier cambio arquitectónico requiere revisión y gate humano.
Distinción fundamental: Etapa 0 crea la skill que identifica y consulta contratos. Etapa 1 produce y aprueba su contenido normativo. Las etapas posteriores implementan respetando esos contratos.

