# Guía de despliegue detallada

Esta guía cubre la instalación de **Kokoro Web (TTS)** en un VPS Ubuntu/Debian,
el firewall y buenas prácticas de seguridad.

---

## 1. Preparar el VPS

Conéctate por SSH:

```bash
ssh usuario@IP_DE_TU_VPS
```

Actualiza el sistema (recomendado):

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

---

## 2. Obtener los archivos

### Opción A — con git

```bash
git clone https://github.com/deadpool00/alejandro.git kokoro
cd kokoro
```

### Instalación sin git

Si no quieres usar git (o el repo es privado), crea una carpeta y los dos
archivos mínimos a mano:

```bash
mkdir -p ~/kokoro && cd ~/kokoro

cat > docker-compose.yml <<'YAML'
services:
  kokoro-web:
    image: ghcr.io/eduardolat/kokoro-web:latest
    container_name: kokoro-web
    ports:
      - "3000:3000"
    environment:
      - KW_SECRET_API_KEY=${KW_SECRET_API_KEY}
      - KW_PUBLIC_NO_TRACK=true
    volumes:
      - ./kokoro-cache:/kokoro/cache
    restart: unless-stopped
YAML

# Genera una clave de API y guárdala en .env
echo "KW_SECRET_API_KEY=$(openssl rand -hex 32)" > .env
```

Luego salta al paso **4**.

---

## 3. Instalar con el script

```bash
bash scripts/install.sh          # modo simple por IP (puerto 3000)
# o
bash scripts/install.sh https    # modo con dominio + HTTPS
```

El script:

1. Instala Docker si no está presente (`https://get.docker.com`).
2. Verifica el plugin `docker compose`.
3. Crea `.env` desde `.env.example` y **genera una `KW_SECRET_API_KEY` aleatoria**.
4. Descarga la imagen y arranca el contenedor.

---

## 4. Arrancar manualmente (si no usas el script)

```bash
docker compose up -d            # modo simple
docker compose logs -f          # ver que arranca bien (Ctrl+C para salir)
```

La **primera** vez puede tardar un poco mientras descarga el modelo.

Accede en `http://IP_DE_TU_VPS:3000`.

---

## 5. Firewall (importante)

### Con UFW (Ubuntu)

```bash
sudo ufw allow OpenSSH
sudo ufw allow 3000/tcp        # solo en modo simple
# En modo HTTPS, en su lugar:
# sudo ufw allow 80/tcp && sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

> Además del firewall del sistema, muchos proveedores (Hetzner, Oracle, AWS,
> Contabo…) tienen su **propio cortafuegos / security group** en el panel.
> Abre ahí el mismo puerto o no podrás acceder.

---

## 6. Seguridad recomendada

- **Pon siempre una `KW_SECRET_API_KEY`** (el script ya la genera). Protege la API.
- **No expongas el puerto 3000 a internet sin necesidad.** Si vas a usarlo en
  serio, usa el [modo HTTPS con dominio](HTTPS-DOMINIO.md) y, si quieres,
  añade usuario/contraseña en Caddy (`basic_auth`) para proteger también la web.
- Mantén el sistema actualizado y usa claves SSH (no contraseñas).
- Actualiza la imagen de vez en cuando: `bash scripts/update.sh`.

---

## 7. Mantenimiento

```bash
bash scripts/logs.sh           # registros en vivo
bash scripts/update.sh         # actualizar a la última versión
bash scripts/uninstall.sh      # detener y borrar contenedores (conserva caché y .env)
docker compose ps              # estado de los contenedores
```

---

## 8. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| No carga `http://IP:3000` | Revisa el firewall del VPS **y** del proveedor (paso 5). |
| `docker: command not found` | Vuelve a ejecutar `bash scripts/install.sh` o instala Docker manualmente. |
| `permission denied` con docker | Usa `sudo`, o añade tu usuario al grupo: `sudo usermod -aG docker $USER` y reconecta. |
| Tarda mucho la primera vez | Está descargando el modelo; mira `bash scripts/logs.sh`. |
| Audio lento al generar | Normal en CPU con textos largos; prueba un modelo más ligero (ver [USO-API.md](USO-API.md)). |
