@echo off
setlocal
cd /d "%~dp0"

if not exist gmaps-output mkdir gmaps-output

if not exist queries.txt (
  echo Crea queries.txt con una busqueda por linea.
  notepad queries.txt
  exit /b
)

docker run --rm -v gmaps-playwright-cache:/opt -v "%cd%\queries.txt:/queries.txt:ro" -v "%cd%\gmaps-output:/out" gosom/google-maps-scraper -input /queries.txt -results /out/results.csv -depth 5 -lang es -exit-on-inactivity 3m

powershell -Command "Import-Csv gmaps-output\results.csv | Select-Object category,link,title,website,phone,review_count,review_rating,thumbnail | Export-Csv gmaps-output\filtrado.csv -NoTypeInformation -Encoding UTF8"

echo.
echo Listo: gmaps-output\filtrado.csv
pause
