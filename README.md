# gmaps-scraper

# gmaps-scraper

Guía rápida y script para extraer negocios de Google Maps en **Windows** usando
[gosom/google-maps-scraper](https://github.com/gosom/google-maps-scraper) con Docker,
y generar un CSV filtrado con solo las columnas que me interesan.

## Requisitos

- Windows 10/11
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) con WSL 2 (abierto y con el motor corriendo)

## Instalación (una sola vez por PC)

1. Instala Docker Desktop, ábrelo y espera a que diga **Engine running**.
2. Descarga la imagen:

```cmd
docker pull gosom/google-maps-scraper
```

3. Clona este repo:

```cmd
git clone <URL-DEL-REPO>
cd gmaps-scraper
```

## Uso rápido

1. Edita `queries.txt` con una búsqueda por línea:

```
dentistas en Manzanillo, Colima
```

2. Haz doble clic en `scrape.bat` (o ejecútalo desde cmd).
3. Al terminar, el resultado queda en `gmaps-output\filtrado.csv`.

## Uso manual (sin el .bat)

Todos los comandos son para **cmd** (Símbolo del sistema), no PowerShell.

Desde la carpeta del proyecto:

```cmd
mkdir gmaps-output
```

Correr el scraper:

```cmd
docker run --rm -v gmaps-playwright-cache:/opt -v "%cd%\queries.txt:/queries.txt:ro" -v "%cd%\gmaps-output:/out" gosom/google-maps-scraper -input /queries.txt -results /out/results.csv -depth 5 -lang es -exit-on-inactivity 3m
```

Filtrar las columnas:

```cmd
powershell -Command "Import-Csv gmaps-output\results.csv | Select-Object category,link,title,website,phone,review_count,review_rating,thumbnail | Export-Csv gmaps-output\filtrado.csv -NoTypeInformation -Encoding UTF8"
```

## Opciones del scraper usadas

| Flag | Qué hace |
|---|---|
| `--rm` | Borra el contenedor al terminar |
| `-input` | Archivo con las búsquedas, una por línea |
| `-results` | Archivo CSV de salida |
| `-depth 5` | Qué tan profundo hace scroll (más alto = más resultados) |
| `-lang es` | Datos en español |
| `-exit-on-inactivity 3m` | Termina solo tras 3 minutos sin actividad |

Otras opciones útiles:

| Necesidad | Flag |
|---|---|
| Extraer emails de los sitios web (más lento) | `-email` |
| Salida en JSON | `-json -results /out/results.json` |
| Más velocidad (usa más CPU y RAM) | `-c 4` |
| Reanudar una corrida interrumpida | `-resume -results /out/results.csv` |

## Columnas del CSV filtrado

`category`, `link`, `title`, `website`, `phone`, `review_count`, `review_rating`, `thumbnail`

Para quedarte solo con los negocios que tienen teléfono, agrega
`| Where-Object { $_.phone }` antes de `Select-Object` en el comando de filtrado.

## Dashboard web (opcional)

```cmd
mkdir gmapsdata
docker run --rm -v "%cd%\gmapsdata:/gmapsdata" -p 8080:8080 gosom/google-maps-scraper -data-folder /gmapsdata
```

Abrir http://localhost:8080. Los resultados tardan al menos 3 minutos en aparecer.
Para detenerlo: `Ctrl+C`.

## Problemas comunes

- **`... is not a valid Windows path`**: estás usando `${PWD}` o `$HOME`, que solo existen en PowerShell. En cmd usa `%cd%` y `%USERPROFILE%`.
- **Error de conexión con el daemon de Docker**: Docker Desktop no está abierto.
- **`localhost:8080` no carga**: el contenedor se arrancó sin `-p 8080:8080` o sin el modo web. Revisa con `docker ps` que en PORTS aparezca `0.0.0.0:8080->8080`.
- **Acentos raros en Excel**: importa el CSV desde *Datos → Obtener datos → Desde texto/CSV* y elige UTF-8.
- Cada corrida sobrescribe `results.csv`. Cambia el nombre en `-results` para conservar corridas anteriores.

## Aviso

Usa el scraper con responsabilidad y respetando las leyes y los términos de servicio aplicables.
Los datos extraídos (`gmaps-output/`) no se suben al repo.

## Créditos

Todo el trabajo de scraping lo hace [gosom/google-maps-scraper](https://github.com/gosom/google-maps-scraper) (licencia MIT).
