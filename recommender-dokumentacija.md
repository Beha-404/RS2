# EasyPC - Tehnička Dokumentacija
**Verzija 2.0 - Proširena verzija sa Compatibility Checker & Build Wizard**

---

## 1. Compatibility Checker

### 1.1 Opis

Compatibility Checker je inteligentni sistem za automatsku provjeru kompatibilnosti hardverskih komponenti. Sistem analizira odabrane komponente i identificira potencijalne probleme prije nego korisnik obavi kupovinu.

### 1.2 Provjere Kompatibilnosti

| Provjera | Opis | Severity |
|----------|------|----------|
| **Socket Compatibility** | Procesor i matična ploča moraju imati isti socket (LGA1700, AM5, etc.) | Error |
| **Form Factor** | Matična ploča mora stati u kućište (ATX, MicroATX, Mini-ITX) | Error |
| **Power Supply Wattage** | Napajanje mora imati dovoljno snage za sve komponente | Error/Warning |
| **Bottleneck Detection** | GPU/CPU balans (price ratio) | Info |

### 1.3 Scoring Algorithm

Sistem koristi **weighted scoring** za izračunavanje overall kompatibilnosti (0-100):

```csharp
int score = 100;

// Socket mismatch: -40 bodova
if (processor.Socket != motherboard.Socket)
    score -= 40;

// Form factor incompatibility: -30 bodova
if (!IsFormFactorCompatible(motherboard, case))
    score -= 30;

// PSU too weak: -20 bodova
if (powerSupply.Power < estimatedWattage)
    score -= 20;

// PSU close to limit: -5 bodova
if (powerSupply.Power < recommendedWattage)
    score -= 5;

// Bottleneck detected: -5 bodova
if (HasBottleneck(processor, graphicsCard))
    score -= 5;
```

### 1.4 Wattage Calculation

Estimirana potrošnja se računa prema formuli:

```
CPU Wattage = CoreCount * 15W
GPU Wattage = VRAM-based (5GB=150W, 8GB=200W, 12GB+=300W)
Motherboard = 80W (fixed)
RAM = 6W (fixed)

Total = CPU + GPU + Motherboard + RAM
Recommended PSU = Total * 1.3 (safety margin)
```

### 1.5 API Endpoint

**POST** `/api/Compatibility/check`

**Request:**
```json
{
  "processorId": 1,
  "motherboardId": 2,
  "ramId": 3,
  "graphicsCardId": 4,
  "powerSupplyId": 5,
  "caseId": 6
}
```

**Response:**
```json
{
  "isCompatible": true,
  "compatibilityScore": 95,
  "estimatedWattage": 450,
  "recommendedPsuWattage": 600,
  "performanceBottleneck": "GPU may bottleneck CPU",
  "issues": [
    {
      "component": "Power Supply",
      "issue": "PSU wattage is close to estimated consumption",
      "severity": "Warning",
      "suggestion": "Consider 650W PSU for safety margin"
    }
  ]
}
```

---

## 2. Build Wizard

### 2.1 Opis

Build Wizard je korak-po-korak vodič koji pomaže korisnicima da izgrade kompatibilan računar. Wizard dinamički filtrira dostupne komponente na osnovu prethodnih izbora.

### 2.2 Wizard Steps

| Step | Component | Filtering Logic |
|------|-----------|-----------------|
| 1 | **PC Type** | Bez filtriranja |
| 2 | **Processor** | Filtriran po PC Type-u |
| 3 | **Motherboard** | Socket mora matchovati Processor |
| 4 | **RAM** | Bez specifičnog filtriranja |
| 5 | **Graphics Card** | Bez specifičnog filtriranja |
| 6 | **Power Supply** | Prikazana preporučena snaga |
| 7 | **Case** | Form Factor mora matchovati Motherboard |

### 2.3 Real-Time Features

**Svaki korak pruža:**
- Lista filtriranih komponenti
- Estimirana ukupna cijena (running total)
- Compatibility check sa prethodnim izborima
- Vizuelni progres (Step 2/7)

### 2.4 API Endpoints

**GET** `/api/BuildWizard/steps`
```json
[
  { "stepNumber": 1, "stepName": "PC Type", "componentType": "PcType" },
  { "stepNumber": 2, "stepName": "Processor", "componentType": "Processor" },
  ...
]
```

**POST** `/api/BuildWizard/update-step`
```json
{
  "state": { ... },
  "stepNumber": 2,
  "componentId": 5
}
```

**POST** `/api/BuildWizard/filtered-components`
```json
{
  "state": { "processorId": 5 },
  "stepNumber": 3
}
```

Returns: Lista Motherboard-a sa socket-om kompatibilnim sa procesorom #5

---

## 3. Sistem Preporuke (Existing)

### 3.1 Content-Based Filtering

Sistem analizira karakteristike odabranog računara i pronalazi slične računare na osnovu:
- **Tipa računara** (Gaming, Office, Workstation, Budget)
- **Cenovnog ranga** (±30% od cene odabranog računara)
- **Proizvođača komponenti** (Procesor, Grafička kartica, RAM, Matična ploča)
- **Prosečne ocene** korisnika

### 3.2 Weighted Scoring System

| Karakteristika | Težina (Bodovi) |
|----------------|-----------------|
| Tip računara | 30 |
| Cena | 25 |
| Procesor (brand) | 15 |
| Grafička kartica (brand) | 15 |
| RAM (brand) | 5 |
| Matična ploča (brand) | 5 |
| Prosečna ocena | 5 |

**Maksimalan score:** 100 bodova

---

## 4. Validation & Security

### 4.1 Backend Validation

Sve InsertRequest modele imaju Data Annotations:

```csharp
[Required(ErrorMessage = "Name is required")]
[MinLength(2, ErrorMessage = "Name must have at least 2 characters")]
public string Name { get; set; }

[Required(ErrorMessage = "Price is required")]
[Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
public int Price { get; set; }
```

### 4.2 Authentication

- **Desktop Admin:** Basic Authentication (admin:admin123)
- **Mobile Users:** No auth required (public access)

---

## 5. Flutter UI (Desktop & Mobile)

### 5.1 Shared Models

```dart
class CompatibilityCheckResult {
  final bool isCompatible;
  final List<CompatibilityIssue> issues;
  final int compatibilityScore;
  final int estimatedWattage;
  final int recommendedPsuWattage;
  final String? performanceBottleneck;
}

class BuildWizardState {
  int currentStep;
  int? pcTypeId;
  int? processorId;
  ...
  CompatibilityCheckResult? compatibilityCheck;
}
```

### 5.2 Desktop Layout
- **Table-based UI** (matching Orders page style)
- **Color-coded severity** (Red=Error, Orange=Warning, Blue=Info)
- **Clickable navigation** - click on problematic component to return to that step
- **Professional theme** - Dark background (0xFF2F2626), Yellow accent (0xFFFFCC00)
- **Save to Database** - Build saved as custom PC via `/api/pc/insert-custom`

### 5.3 Mobile Layout
- **PageView with swipe gestures** - intuitive step-by-step navigation
- **Card-based selection** - large touchable cards with radio buttons
- **Progress indicator** - "Step N of 7" in AppBar
- **Bottom navigation** - Previous/Next buttons for step control
- **Summary page** - final review with component icons
- **Add to Cart** - returns BuildWizardState to caller (doesn't save to DB)
- **Mobile theme** - Dark background (0xFF1F1F1F), Yellow accent (0xFFDDC03D)
- **Integration** - "BUILD PC" button on HomePage (green button)

---

## 6. Performance Optimizations

### 6.1 Caching

- **Recommendations:** 10 min cache
- **Component lists:** No cache (frequent updates)

### 6.2 Database Queries

- **Eager Loading:** `.Include()` za sve relacione podatke
- **Projection:** `Select()` za vraćanje samo potrebnih polja
- **Indexing:** Indexi na Socket, FormFactor, Price kolone

---

## 7. Deployment

### 7.1 Docker Compose

```yaml
services:
  api:
    build: ./EasyPC.API
    ports:
      - "5285:8080"
  
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    ports:
      - "1433:1433"
  
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "15672:15672"
```

### 7.2 Flutter Build

**Desktop (Windows):**
```bash
flutter build windows --release
```

**Mobile (Android):**
```bash
flutter build apk --release
```

---

## 8. Future Enhancements

1. **ML-Based Recommendations** - TensorFlow model za predviđanje korisničkih preferencija
2. **Price Alerts** - Notifikacije kada komponente padnu na određenu cijenu
3. **Benchmark Integration** - Real-world performance scores umjesto price ratio
4. **3D PC Preview** - Vizualizacija kako će računar izgledati

---

## 9. Zaključak

EasyPC platforma se razlikuje od klasičnog e-commerce projekta kroz:

✅ **Intelligent Compatibility Checking** - automatska validacija hardvera  
✅ **Guided Build Process** - wizard sa 7 koraka i smart filtering  
✅ **Real-Time Feedback** - instant price & compatibility updates  
✅ **Multi-Platform** - Desktop i Mobile sa istim backend-om  
✅ **Scalable Architecture** - Docker, mikroservisi, message queue

