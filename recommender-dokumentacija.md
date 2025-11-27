## Opis Sistema Preporuke

Sistem preporuke u EasyPC aplikaciji implementira **Content-Based Filtering** algoritam koji preporučuje slične računare na osnovu karakteristika trenutno odabranog računara. Sistem koristi **weighted scoring** metodu za izračunavanje sličnosti između računara.

## Algoritam

### 1. Content-Based Filtering

Sistem analizira karakteristike odabranog računara i pronalazi slične računare na osnovu:
- **Tipa računara** (Gaming, Office, Workstation, Budget)
- **Cenovnog ranga** (±30% od cene odabranog računara)
- **Proizvođača komponenti** (Procesor, Grafička kartica, RAM, Matična ploča)
- **Prosečne ocene** korisnika

### 2. Weighted Scoring System

Svaka karakteristika ima dodeljenu težinu (weight) koja determiniše njen uticaj na ukupan similarity score:

| Karakteristika | Težina (Bodovi) | Opis |
|----------------|-----------------|------|
| **Tip računara** | 30 | Isti tip (Gaming, Office, etc.) |
| **Cena** | 25 | Unutar ±30% cenovnog ranga |
| **Procesor (brand)** | 15 | Isti proizvođač (Intel, AMD) |
| **Grafička kartica (brand)** | 15 | Isti proizvođač (NVIDIA, AMD) |
| **RAM (brand)** | 5 | Isti proizvođač |
| **Matična ploča (brand)** | 5 | Isti proizvođač |
| **Prosečna ocena** | 5 | Ocena ≥ 4.0 zvezdice |

**Maksimalan mogući score:** 100 bodova

### 3. Proces Generisanja Preporuka

```
1. Učitavanje target računara (sa svim komponentama)
2. Učitavanje svih aktivnih računara (osim target-a)
3. Za svaki kandidat računar:
   - Izračunaj similarity score
   - Dodaj u listu scored računara
4. Sortiraj po score-u (descending)
5. Uzmi top 3 računara
6. Cache rezultate na 10 minuta
7. Vrati preporuke
```

### 4. Caching

Sistem koristi **In-Memory Cache** za optimizaciju performansi:
- **Cache Key:** `pc_recommendations_{pcId}`
- **TTL (Time To Live):** 10 minuta
- **Benefit:** Brži response time, smanjeno opterećenje baze

## Primeri Izračunavanja

### Primer 1: Gaming PC

**Target PC:** Gaming računar, $1500, Intel + NVIDIA

**Kandidat 1:** Gaming računar, $1450, Intel + NVIDIA
- Tip PC-a: 30 ✓
- Cena ($50 razlika): 24.4
- Procesor (Intel): 15 ✓
- GPU (NVIDIA): 15 ✓
- Ocena 4.5: 5 ✓
- **Total: 89.4**

**Kandidat 2:** Office računar, $1500, AMD + Integrated
- Tip PC-a: 0 ✗
- Cena (ista): 25 ✓
- Procesor (AMD): 0 ✗
- GPU (različit): 0 ✗
- **Total: 25**

Kandidat 1 bi bio top preporuka zbog visokog similarity score-a.

## Frontend Implementacija

### Prikaz Preporuka

Preporuke se prikazuju u **PC Details Dialog-u** kao horizontalna lista kartice:

1. Korisnik klikne na računar
2. Otvara se detaljan prikaz
3. Učitavaju se "Similar PCs"
4. Prikazuje se do 3 preporuke
5. Korisnik može kliknuti na preporuku i videti njene detalje

### UI Komponente

- **Horizontal ScrollView** - lista preporuka
- **PC Card** - prikaz svakog preporučenog računara
  - Slika računara
  - Naziv
  - Tip (Gaming, Office, etc.)
  - Cena
  - Prosečna ocena

## Prednosti Sistema

1. **Personalizovano** - preporuke zasnovane na trenutnom izboru
2. **Brzo** - caching smanjuje response time
3. **Relevantno** - weighted scoring preferira bitnije karakteristike
4. **Skalabilno** - može se lako dodati nove karakteristike

