Set-StrictMode -Version Latest

$path = Read-Host "Enter full path to folder with media and JSON files"

if (-not (Test-Path -LiteralPath $path)) {
    Write-Host "Path does not exist."
    exit
}

Set-Location -LiteralPath $path

$mediaFiles = Get-ChildItem -File |
  Where-Object { $_.Extension -match '^\.(jpg|jpeg|png|heic|heif|tif|tiff|webp|mov|mp4)$' }

Write-Host ("Found {0} media files." -f $mediaFiles.Count)

$processed = 0

foreach ($f in $mediaFiles) {

    $jsonItem =
        Get-ChildItem -File -Filter ($f.Name + "*.json") |
        Where-Object { $_.Name -match '(?i)supp' } |
        Select-Object -First 1

    if (-not $jsonItem) {
        $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
        $jsonItem =
            Get-ChildItem -File -Filter ($base + "*.json") |
            Where-Object { $_.Name -match '(?i)supp' } |
            Select-Object -First 1
    }

    if (-not $jsonItem) { continue }

    $j = Get-Content -LiteralPath $jsonItem.FullName -Raw -Encoding UTF8 | ConvertFrom-Json

    function To-ExifDate([string]$unixTs) {
        if ([string]::IsNullOrWhiteSpace($unixTs)) { return $null }
        [DateTimeOffset]::FromUnixTimeSeconds([int64]$unixTs).ToString("yyyy:MM:dd HH:mm:ss")
    }

    function To-IsoDate([string]$unixTs) {
        if ([string]::IsNullOrWhiteSpace($unixTs)) { return $null }
        [DateTimeOffset]::FromUnixTimeSeconds([int64]$unixTs).ToString("yyyy-MM-ddTHH:mm:ssK")
    }

    $takenExif   = To-ExifDate $j.photoTakenTime.timestamp
    $createdExif = To-ExifDate $j.creationTime.timestamp
    $createdIso  = To-IsoDate  $j.creationTime.timestamp

    $args = @(
        "-overwrite_original",
        "-P",
        "-m",
        "-charset","utf8",
        "-charset","filename=utf8"
    )

    if ($takenExif) {
        $args += @("-DateTimeOriginal=$takenExif","-CreateDate=$takenExif")
        if ($f.Extension -match '^\.(mov|mp4)$') { $args += "-TrackCreateDate=$takenExif" }
    }

    if ($createdIso) { $args += "-XMP:CreateDate=$createdIso" }

    if ($createdExif) { $args += "-FileCreateDate=$createdExif" }
    if ($takenExif)   { $args += "-FileModifyDate=$takenExif" }
    elseif ($createdExif) { $args += "-FileModifyDate=$createdExif" }

    if ($j.description) {
        $args += @("-ImageDescription=$($j.description)","-XMP-dc:Description=$($j.description)")
    }

    if ($j.title) {
        $args += "-XMP-dc:Title=$($j.title)"
    }

    if ($j.url) {
        $args += @("-XMP:Identifier=$($j.url)","-XMP:Source=$($j.url)")
    }

    if ($j.geoData -and (($j.geoData.latitude -ne 0) -or ($j.geoData.longitude -ne 0))) {
        $args += @("-GPSLatitude=$($j.geoData.latitude)","-GPSLongitude=$($j.geoData.longitude)")
        if ($j.geoData.altitude) { $args += "-GPSAltitude=$($j.geoData.altitude)" }
    }

    & exiftool "-api" "WindowsWideFile=1" @args -- "$($f.Name)"

    $processed++
}

Write-Host ("Integrated metadata into {0} files." -f $processed)

$delete = Read-Host "Delete ALL .json files from this folder? (yes/no)"

if ($delete -match '^(yes|y)$') {
    $jsonFiles = Get-ChildItem -File -Filter *.json
    $count = $jsonFiles.Count
    $jsonFiles | Remove-Item -Force
    Write-Host ("Deleted {0} JSON files." -f $count)
}
else {
    Write-Host "JSON files were NOT deleted."
}
