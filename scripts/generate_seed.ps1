param(
  [string]$CsvPath = "$PSScriptRoot\..\data\family_tree.csv",
  [string]$OutPath = "$PSScriptRoot\..\supabase\seed_family.sql"
)

$rows = Import-Csv $CsvPath
$currentGp = ""
$currentUncle = ""
$currentChild = ""
$nodes = [ordered]@{}

$siblingOrder = @{}

function Clean([string]$s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return "" }
  return ($s.Trim() -replace "\s+", " ")
}

function Slug([string]$name) {
  $n = $name.ToLower() -replace "[^a-z0-9]+", "_"
  return $n.Trim("_")
}

function DeterministicUuid([string]$key) {
  $md5 = [System.Security.Cryptography.MD5]::Create()
  $hash = $md5.ComputeHash([Text.Encoding]::UTF8.GetBytes("reer_sh_yoonis:$key"))
  $hex = -join ($hash | ForEach-Object { $_.ToString("x2") })
  return "{0}-{1}-{2}-{3}-{4}" -f `
    $hex.Substring(0, 8), `
    $hex.Substring(8, 4), `
    $hex.Substring(12, 4), `
    $hex.Substring(16, 4), `
    $hex.Substring(20, 12)
}

function Ensure([string]$name, [string]$parentKey, [int]$gen) {
  $name = Clean $name
  if (-not $name) { return $null }
  $base = Slug $name
  $key = $base
  $i = 2
  while ($nodes.Contains($key)) {
    $existing = $nodes[$key]
    if ($existing.parent -eq $parentKey) { return $key }
    $key = "${base}_$i"
    $i++
  }
  $orderKey = if ($parentKey) { $parentKey } else { "__root__" }
  if (-not $siblingOrder.Contains($orderKey)) { $siblingOrder[$orderKey] = 0 }
  $birthOrder = $siblingOrder[$orderKey]
  $siblingOrder[$orderKey] = $birthOrder + 1
  $nodes[$key] = @{
    name = $name
    parent = $parentKey
    gen = $gen
    id = (DeterministicUuid $key)
    birth_order = $birthOrder
  }
  return $key
}

foreach ($row in $rows) {
  $gp = Clean $row.GRANDPARENT
  $uncle = Clean $row.UNCLE
  $child = Clean $row.CHILD
  $grandchild = Clean $row.GRANDCHILD

  if ($gp) {
    $currentGp = $gp
    $currentUncle = ""
    $currentChild = ""
  }
  if ($uncle) {
    $currentUncle = $uncle
    $currentChild = ""
  }
  if ($child) { $currentChild = $child }

  $gpKey = Ensure $currentGp $null 0
  $uncleKey = $null
  if ($currentUncle) {
    $uncleKey = Ensure $currentUncle $gpKey 1
  }

  if ($grandchild) {
    $childKey = Ensure $currentChild $uncleKey 2
    Ensure $grandchild $childKey 3 | Out-Null
  }
  elseif ($child -and $uncle) {
    Ensure $child $uncleKey 2 | Out-Null
  }
  elseif ($child -and -not $uncle -and $currentUncle) {
    if (-not $uncleKey) {
      foreach ($k in $nodes.Keys) {
        if ($nodes[$k].name -eq $currentUncle -and $nodes[$k].gen -eq 1) {
          $uncleKey = $k
          break
        }
      }
    }
    Ensure $child $uncleKey 2 | Out-Null
  }
}

function SqlEscape([string]$s) {
  return $s -replace "'", "''"
}

$lines = @()
$lines += "-- Reer Sh Yoonis family tree seed (from SHEEK YOONIS CSV)"
$lines += "-- Run after 001_initial_schema.sql"
$lines += "BEGIN;"
$lines += ""
$lines += "-- Insert all profiles"
foreach ($entry in $nodes.GetEnumerator()) {
  $key = $entry.Key
  $id = $entry.Value.id
  $name = SqlEscape $entry.Value.name
  $birthOrder = $entry.Value.birth_order
  $lines += "INSERT INTO reer_sh_yoonis.profiles (id, full_name, email, role, demographic, care_rating, birth_order)"
  $lines += "VALUES ('$id', '$name', NULL, 'family_member', 'adult', 2, $birthOrder)"
  $lines += "ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, birth_order = EXCLUDED.birth_order;"
}
$lines += ""
$lines += "-- Link father_id (lineage)"
foreach ($entry in $nodes.GetEnumerator()) {
  $key = $entry.Key
  $id = $entry.Value.id
  $parent = $entry.Value.parent
  if ($parent) {
    $parentId = $nodes[$parent].id
    $lines += "UPDATE reer_sh_yoonis.profiles SET father_id = '$parentId' WHERE id = '$id';"
  }
}
$lines += ""
$lines += "-- Patriarch gets stable flourishing rating"
$lines += "UPDATE reer_sh_yoonis.profiles SET care_rating = 1 WHERE full_name ILIKE 'SHEEKH YONIS';"
$lines += ""
$lines += "COMMIT;"
$lines += ""
$lines += "-- Total profiles seeded: $($nodes.Count)"

$lines | Set-Content -Path $OutPath -Encoding UTF8
Write-Host "Wrote $($nodes.Count) profiles to $OutPath"
