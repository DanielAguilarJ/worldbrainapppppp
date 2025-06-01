# Configuración de Appwrite para WorldBrain

## 📋 Instrucciones de Configuración

### 1. Añadir Dependencia de Appwrite en Xcode

1. **Abrir el proyecto en Xcode**:
   ```bash
   open /workspaces/worldbrainapppppp/worldbrainapp/worldbrainapp.xcodeproj
   ```

2. **Añadir Package Dependency**:
   - En Xcode, ve a `File` > `Add Package Dependencies...`
   - Ingresa la URL: `https://github.com/appwrite/sdk-for-apple.git`
   - Selecciona versión `10.1.0` o `Up to Next Major Version`
   - Añade el paquete al target `worldbrainapp`

### 2. Configurar Info.plist para OAuth

Añadir el siguiente bloque al archivo `Info.plist` del proyecto:

```xml
<key>CFBundleURLTypes</key>
<array>
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>io.appwrite</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>appwrite-callback-683b7d7000153e36f0d8</string>
    </array>
</dict>
</array>
```

### 3. Configurar Base de Datos en Appwrite Console

1. **Crear Proyecto**:
   - Ve a [Appwrite Console](https://cloud.appwrite.io)
   - Crea un proyecto con ID: `683b7d7000153e36f0d8`

2. **Crear Base de Datos**:
   - Nombre: `worldbrain_db`
   - ID: `worldbrain_db`

3. **Crear Colección de Usuarios**:
   - Nombre: `users`
   - ID: `users`
   - Atributos:
     ```
     - email (string, required, size: 255)
     - name (string, optional, size: 100)
     - premium (boolean, required, default: false)
     - xp (integer, required, default: 0)
     - completedLessons (array, required, default: [])
     - createdAt (double, required)
     ```

4. **Configurar Permisos**:
   - Read: `user:*`
   - Create: `user:*`
   - Update: `user:*`
   - Delete: `user:*`

### 4. Añadir Plataforma iOS

1. **En Appwrite Console**:
   - Ve a Settings > Platforms
   - Añade nueva plataforma iOS
   - Bundle ID: `com.tucompania.worldbrainapp` (según tu proyecto)
   - App Name: `WorldBrain`

### 5. Archivos Creados

Los siguientes archivos han sido creados para la integración:

#### Componentes Backend:
- `BackendProtocol.swift` - Protocolo unificado para backends
- `FirebaseBackend.swift` - Adaptador para Firebase
- `AppwriteBackend.swift` - Adaptador para Appwrite  
- `UnifiedAuthManager.swift` - Gestor unificado de autenticación
- `AppwriteManager.swift` - Singleton específico de Appwrite

#### Vistas:
- `BackendConfigView.swift` - Configuración y alternancia de backends
- `AppwriteTestView.swift` - Vista de prueba para Appwrite

#### Configuración:
- `AppwriteConfig.plist` - Archivo de configuración

### 6. Uso del Sistema Unificado

```swift
// En tu ViewModel o Vista
@StateObject private var authManager = UnifiedAuthManager()

// Cambiar backend
authManager.switchBackend(to: .appwrite)

// Registro
await authManager.signUp(email: "test@test.com", password: "password123", name: "Usuario Test")

// Login
await authManager.signIn(email: "test@test.com", password: "password123")

// Completar lección
await authManager.completeLesson(lessonID: "lesson_1", earnedXP: 50)
```

### 7. Testing

1. **Abrir la app en simulator**
2. **Navegar a la pestaña "Backend"**
3. **Probar conexión con Appwrite**
4. **Registrar nuevo usuario**
5. **Verificar datos en Appwrite Console**

### 8. Notas Importantes

- **Backup de datos**: Antes de cambiar de backend, asegúrate de hacer backup
- **Migración**: Los datos entre Firebase y Appwrite no se sincronizan automáticamente
- **Testing**: Usa usuarios de prueba para verificar ambos backends
- **Configuración**: Revisa que los IDs de proyecto coincidan en ambos lados

## 🔧 Troubleshooting

### Error de conexión
- Verifica que el PROJECT_ID sea correcto
- Revisa la configuración de red en Appwrite Console

### Error de permisos
- Verifica los permisos de la colección en Appwrite Console
- Asegúrate de que los atributos estén configurados correctamente

### Error de dependencias
- Verifica que el SDK de Appwrite esté correctamente instalado
- Revisa que la versión sea compatible (10.1.0+)
