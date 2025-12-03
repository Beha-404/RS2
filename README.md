# EasyPC - Intelligent PC Building Platform
**Razvoj softvera II - Seminarski rad**

EasyPC je napredna višeplatformska aplikacija za izgradnju i kupovinu računara sa inteligentnim sistemom za provjeru kompatibilnosti i korak-po-korak wizard-om za konfiguraciju računara.

**Login podaci:**
- Desktop app: `admin` / `admin123` ili `superadmin` / `superadmin123`
- Mobile app: `user1` / `user123`

Mobilna aplikacija je pokrenuta preko emulatora: Pixel_9a, ili preko svog uređaja.

---

## 🎯 Ključne Karakteristike

### 🔧 **Compatibility Checker**
- Automatska provjera kompatibilnosti komponenti
- Socket matching (CPU ↔ Motherboard)
- Form factor validacija (Motherboard ↔ Case)
- Provjera snage napajanja
- Bottleneck detection (CPU/GPU balans)
- Scoring sistem (0-100 bodova)
- Vizuelne preporuke i upozorenja

### 🧙 **Build Wizard**
- 7-koračni vodič za izgradnju računara
  1. Tip računara (Gaming, Office, Workstation)
  2. Procesor (filtriran po tipu PC-a)
  3. Matična ploča (kompatibilni socket-i)
  4. RAM (optimalne brzine)
  5. Grafička karta (balansirana sa CPU-om)
  6. Napajanje (preporučena snaga)
  7. Kućište (kompatibilni form factor)
- Real-time kompatibilnost check
- Dinamička kalkulacija cijene
- Pametno filtriranje komponenti
- Save & Order funkcionalnost

---

## EasyPC - Build Your Dream PC

EasyPC je višeplatformska aplikacija za izgradnju i kupovinu računara sa desktop aplikacijom (WPF), mobilnom aplikacijom (Flutter/MAUI), web aplikacijom (Angular) i recommendation sistemom.

## 🚀 Funkcionalnosti

### 💻 Desktop Aplikacija (Flutter)
- Admin panel za upravljanje proizvodima
- **Compatibility Checker** UI
- **Build Wizard** interface
- Upravljanje korisnicima i narudžbama
- Real-time support chat (SignalR)
- PDF izvještaji

### 📱 Mobilna Aplikacija (Flutter)
- Pregledanje PC konfiguracija
- **Compatibility Checker** (mobile-optimized)
- **Build Wizard** (vertical stepper)
- Korpa i naručivanje
- Korisnički profil

### 🤖 Recommendation System (Coming soon)
- Machine learning preporuke računara
- Analiza korisničkih preferencija
- Personalizovane sugestije

## 🛠️ Tehnologije

| Layer | Tehnologija |
|-------|-------------|
| **Backend** | .NET 9, ASP.NET Core Web API |
| **Database** | SQL Server 2022, Entity Framework Core |
| **Authentication** | JWT Tokens, Basic Auth |
| **Real-time** | SignalR (Support Chat) |
| **Message Queue** | RabbitMQ |
| **Desktop & Mobile** | Flutter 3.x, Dart |
| **Containerization** | Docker, Docker Compose |

## 📦 Instalacija i Pokretanje

### 1. Docker (Preporučeno)
```bash
cd EasyPC
docker-compose up -d --build
```
**Servisi:**
- API: `http://localhost:5285`
- SQL Server: `localhost:1433`
- RabbitMQ: `localhost:15672` (guest/guest)

### 2. Desktop Aplikacija
```bash
cd UI/easy_pc_admin
flutter pub get
flutter run -d windows
```

**Login:** `admin` / `admin123` ili `superadmin` / `superadmin123`

### 3. Mobilna Aplikacija
```bash
cd UI/easy_pc_mobile
flutter pub get
flutter run
```

**Login:** `user1` / `user123`

---

## 🎮 Kako Koristiti

### Compatibility Checker
1. Kliknite na "Compatibility" u navigaciji
2. Odaberite komponente iz dropdown menija
3. Kliknite "Check Compatibility"
4. Pregled rezultata:
   - ✅ **Zeleno:** Sve kompatibilno
   - ⚠️ **Narandžasto:** Upozorenja
   - ❌ **Crveno:** Nekompatibilno

### Build Wizard
1. Kliknite na "Build Wizard" u navigaciji
2. Pratite 7 koraka
3. Odaberite komponentu iz liste
4. Pregledajte real-time cijenu
5. Na kraju: "Save Build"

## 🗄️ Seed Podaci

Aplikacija automatski kreira seed podatke pri prvom pokretanju:

| Tip | Username | Password |
|-----|----------|----------|
| Desktop Admin | `admin` | `admin123` |
| Super Admin | `superadmin` | `superadmin123` |
| Mobile User | `user1` | `user123` |

**Seed komponente:**
- 10+ Procesora (Intel i5/i7/i9, AMD Ryzen 5/7/9)
- 10+ Matičnih ploča (ASUS, MSI, Gigabyte)
- 8+ RAM modula (Corsair, Kingston, G.Skill)
- 10+ Grafičkih kartica (NVIDIA RTX, AMD Radeon)
- 6+ Napajanja (Corsair, EVGA - 550W-850W)
- 6+ Kućišta (NZXT, Corsair - ATX, MicroATX, Mini-ITX)

---

## 📄 Licenca

MIT License

---

## 👨‍💻 Autor

**Behadin Kovačević**  
Internacionalni Univerzitet Burch  
Razvoj softvera II - 2024/2025

---

⭐ **Razlika od klasičnog e-prodaja projekta:**
- ✅ Automatska provjera kompatibilnosti
- ✅ Intelligent Build Wizard sa 7 koraka
- ✅ Real-time filtering baziran na prethodnim izborima
- ✅ Bottleneck detection
- ✅ Scoring sistem kompatibilnosti
- ✅ Preporuke za napajanje i balans komponenti