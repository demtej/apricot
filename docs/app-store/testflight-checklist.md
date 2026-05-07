# TestFlight – Guía de subida paso a paso

> Este documento cubre los pasos manuales que no se pueden automatizar:
> crear la app en App Store Connect, generar el Archive, subir el build
> y configurar TestFlight.

---

## Prerrequisitos

- Cuenta activa en el **Apple Developer Program** (paid, $99/año).
- Xcode 15.x instalado con tu Apple ID firmado en **Xcode → Settings → Accounts**.
- Java 17+ instalado (`java -version`).
- `xcodegen` instalado (`brew install xcodegen`).
- Archivo `Config/Apricot.local.xcconfig` creado a partir del ejemplo:

  ```
  cp Config/Apricot.example.xcconfig Config/Apricot.local.xcconfig
  # Editar con tus valores reales:
  APRICOT_POSTHOG_API_KEY = phc_...
  APRICOT_POSTHOG_HOST = https:\/\/us.i.posthog.com
  DEVELOPMENT_TEAM = XXXXXXXXXX   ← tu Team ID de Apple Developer
  ```

  Tu Team ID aparece en [developer.apple.com/account](https://developer.apple.com/account) bajo *Membership Details*.

---

## 1. Construir el proyecto

```bash
make bootstrap
```

Esto compila el KMP shared module en modo debug **y release**, y genera `Apricot.xcodeproj`.

> Si solo actualiciste código Swift (sin cambios en el módulo KMP), basta con `make xcode`.
> Si modificaste el módulo KMP, vuelve a ejecutar `make kmp-release && make xcode` antes de archivar.

---

## 2. Crear la app en App Store Connect

1. Ir a [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
2. **My Apps → "+" → New App**.
3. Completar el formulario:
   - **Platforms:** iOS
   - **Name:** Apricot
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** `com.demiantejo.apricot`  
     *(Si no aparece en el dropdown, primero regístralo en el paso siguiente)*
   - **SKU:** `apricot-ios-1` *(cualquier identificador único)*
4. Hacer clic en **Create**.

---

## 3. Registrar el Bundle Identifier (si aún no existe)

1. Ir a [developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers).
2. **"+" → App IDs → App**.
3. Completar:
   - **Description:** Apricot
   - **Bundle ID:** Explicit → `com.demiantejo.apricot`
   - **Capabilities:** ninguna especial requerida (Push Notifications, Sign in with Apple: dejar desactivadas).
4. **Continue → Register**.

---

## 4. Configurar signing en Xcode

1. Abrir `Apricot.xcodeproj` en Xcode.
2. Seleccionar el target **Apricot** → pestaña **Signing & Capabilities**.
3. Confirmar:
   - **Automatically manage signing:** ✓ activado
   - **Team:** tu equipo de Apple Developer
   - **Bundle Identifier:** `com.demiantejo.apricot`
4. Xcode debe generar o descargar el provisioning profile automáticamente (ícono de candado verde).

> Si el signing ya se resolvió a través de `Config/Apricot.local.xcconfig` (con `DEVELOPMENT_TEAM`),
> este paso solo sirve para verificar que no haya errores.

---

## 5. Generar el Archive

1. En Xcode, asegurarse de que el destination del scheme **Apricot** sea **Any iOS Device (arm64)** — no un simulador.
2. Menú **Product → Archive** (⌘ + Shift + B no aplica; usar el menú).
3. Esperar a que finalice el proceso (puede tardar varios minutos la primera vez).
4. Al terminar, Xcode abre automáticamente el **Organizer**.

Alternativa por línea de comandos:

```bash
xcodebuild archive \
  -project Apricot.xcodeproj \
  -scheme Apricot \
  -configuration Release \
  -archivePath build/Apricot.xcarchive \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=XXXXXXXXXX
```

---

## 6. Subir el build a App Store Connect (Organizer)

1. En el **Organizer**, seleccionar el archive recién creado.
2. Hacer clic en **Distribute App**.
3. Seleccionar **App Store Connect → Upload**.
4. Opciones recomendadas:
   - **Include bitcode:** desactivado (Apple ya no lo requiere)
   - **Upload your app's symbols:** ✓ activado (para crash reports)
   - **Manage Version and Build Number:** dejar los valores de `project.yml` (`1.0.0` / `1`)
5. Hacer clic en **Upload**.
6. Esperar confirmación: *"Your app has been uploaded"*.

El build tardará 5–15 minutos en aparecer en App Store Connect tras el procesamiento de Apple.

---

## 7. Completar la información de TestFlight

1. En App Store Connect → tu app → **TestFlight**.
2. Una vez que el build aparezca, hacer clic en él.
3. Completar la sección **Test Information**:
   - **Beta App Description:**
     ```
     Apricot is a Bitcoin address explorer. Look up any public Bitcoin address
     to view its balance, transaction history, and individual transaction details.
     No wallet connection required — Apricot reads only public blockchain data.
     ```
   - **Beta App Review Information – Notes for Reviewer:**
     ```
     This app queries public Bitcoin blockchain data via the mempool.space API.
     No account or login is required. Use any valid mainnet Bitcoin address to test.
     Example: bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh
     ```
   - **Feedback Email:** demian.tejo@gmail.com
   - **Privacy Policy URL:** URL pública de tu privacy policy (ver `docs/privacy-policy.md`)

---

## 8. Agregar testers internos

Los **internal testers** son miembros de tu equipo de Apple Developer (hasta 100 personas).
No requieren aprobación de Apple Review.

1. App Store Connect → tu app → **TestFlight → Internal Testing**.
2. Hacer clic en **"+" → Add Internal Testers**.
3. Seleccionar los usuarios con rol *Admin*, *App Manager*, *Developer*, o *Marketing*.
4. Hacer clic en **Add**.
5. Los testers recibirán un email de invitación de Apple.

Para agregar **external testers** (hasta 10.000 personas fuera del equipo):

1. TestFlight → **External Testing → Add Group**.
2. Nombre: `Beta v1.0`
3. Agregar el build al grupo.
4. Apple realizará un **Beta App Review** (generalmente < 24 horas para la primera subida).
5. Una vez aprobado, los testers reciben la invitación.

---

## 9. Verificaciones post-subida

- [ ] El build aparece en TestFlight sin errores de procesamiento
- [ ] La notificación de TestFlight llega al email de testers
- [ ] Instalar la app desde TestFlight en un dispositivo físico
- [ ] Verificar que el cold start funciona
- [ ] Buscar una dirección Bitcoin conocida (`bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh`)
- [ ] Navegar al detalle de una transacción
- [ ] Verificar que los estados de error se muestran correctamente (dirección inválida, modo avión)
- [ ] Confirmar que el footer de disclaimer es visible en la pantalla principal
- [ ] Verificar que no aparecen wording de "inversión", "consejo financiero" o "precio"

---

## Números de versión para builds futuros

Cada build subido a App Store Connect necesita un `CURRENT_PROJECT_VERSION` único.
Incrementar en `project.yml` antes de cada Archive:

| Build | MARKETING_VERSION | CURRENT_PROJECT_VERSION |
|-------|-------------------|------------------------|
| 1     | 1.0.0             | 1                      |
| 2     | 1.0.0             | 2                      |
| ...   | ...               | ...                    |
| N+1   | 1.1.0             | N+1                    |

`MARKETING_VERSION` solo cambia cuando se publica una nueva versión pública.
`CURRENT_PROJECT_VERSION` se incrementa en cada Archive, incluso dentro de la misma versión.

Después de editar `project.yml`, regenerar el proyecto:

```bash
make xcode
```

---

## Referencia rápida de comandos

```bash
# Actualizar módulo KMP para release (antes de archivar)
make kmp-release

# Regenerar proyecto Xcode
make xcode

# Setup inicial completo
make bootstrap
```
