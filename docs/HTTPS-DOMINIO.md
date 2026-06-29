# Dominio + HTTPS automático (Caddy)

Este modo pone **Kokoro Web** detrás de [Caddy](https://caddyserver.com/), que
gestiona el certificado **HTTPS de Let's Encrypt automáticamente**. El contenedor
de Kokoro queda en la red interna y **solo Caddy** se expone a internet (puertos 80/443).

---

## 1. Requisitos previos

1. Un **dominio o subdominio** (p. ej. `tts.midominio.com`).
2. Un registro **A** en tu DNS apuntando a la **IP pública del VPS**.
   - Verifícalo:  `dig +short tts.midominio.com`  → debe devolver la IP del VPS.
3. Puertos **80** y **443** abiertos en el firewall del VPS y del proveedor.

---

## 2. Configurar `.env`

```bash
cp .env.example .env
nano .env
```

Define al menos:

```bash
KW_SECRET_API_KEY=...        # se genera sola con el script; o pon una con: openssl rand -hex 32
KW_DOMAIN=tts.midominio.com  # tu dominio real
KW_ACME_EMAIL=tu@correo.com  # para avisos de Let's Encrypt
```

---

## 3. Arrancar

```bash
bash scripts/install.sh https
# o, manualmente:
docker compose -f docker-compose.https.yml up -d
```

Caddy pedirá el certificado automáticamente. En 10–30 segundos tendrás:

```
https://tts.midominio.com
```

Mira el progreso con:

```bash
bash scripts/logs.sh https
```

---

## 4. (Opcional) Proteger la web con usuario y contraseña

Por defecto la **interfaz web** es pública (cualquiera con la URL puede usarla).
Para pedir usuario/contraseña, edita `caddy/Caddyfile`:

```bash
# 1) Genera el hash de tu contraseña
docker run --rm caddy:2-alpine caddy hash-password --plaintext 'TU_PASSWORD'
```

```caddy
# 2) En caddy/Caddyfile, dentro del bloque del dominio, descomenta:
basic_auth {
    usuario HASH_QUE_TE_DEVOLVIO
}
```

Aplica el cambio:

```bash
docker compose -f docker-compose.https.yml restart caddy
```

---

## 5. Problemas frecuentes

| Síntoma | Solución |
|---|---|
| No se emite el certificado | Confirma que el dominio resuelve a la IP del VPS (`dig +short ...`) y que el puerto 80 está abierto. |
| `too many certificates` | Has reintentado mucho; Let's Encrypt limita por hora. Espera y revisa el DNS antes de reintentar. |
| Sale "Caddy" pero no Kokoro | Mira `bash scripts/logs.sh https`; el contenedor `kokoro-web` debe estar `running`. |
| Quiero cambiar de dominio | Edita `KW_DOMAIN` en `.env` y `docker compose -f docker-compose.https.yml up -d`. |
