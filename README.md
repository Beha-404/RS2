# EasyPC - Intelligent PC Building Platform
**Software Development II - Seminar Project**

EasyPC is an advanced multi-platform application for building and purchasing computers with an intelligent compatibility checking system and a step-by-step wizard for PC configuration.

**Login Credentials:**
- Desktop app: `admin` / `admin123` or `superadmin` / `superadmin123`
- Mobile app: `user1` / `user123`

The mobile application is launched via emulator: Pixel_9a, or via your own device.

## EasyPC - Build Your Dream PC

EasyPC is a multi-platform application for building and purchasing computers with a desktop app (Flutter), mobile app (Flutter), web app (Angular), and recommendation system.

## 🚀 Features

### 💻 Desktop Application (Flutter)
- Admin panel for product management
- **Compatibility Checker** UI
- **Build Wizard** interface
- User and order management
- Real-time support chat (SignalR)
- PDF reports

### 📱 Mobile Application (Flutter)
- Browse PC configurations
- **Compatibility Checker** (mobile-optimized)
- **Build Wizard** (vertical stepper)
- Shopping cart and ordering
- User profile

### 🔧 **Compatibility Checker**
- Automatic component compatibility verification
- Socket matching (CPU ↔ Motherboard)
- Form factor validation (Motherboard ↔ Case)
- Power supply verification
- Bottleneck detection (CPU/GPU balance)
- Scoring system (0-100 points)
- Visual recommendations and warnings

### 🧙 **Build Wizard**
- 7-step guide for building a PC
  1. PC Type (Gaming, Office, Workstation)
  2. Processor (filtered by PC type)
  3. Motherboard (compatible sockets)
  4. RAM (optimal speeds)
  5. Graphics Card (balanced with CPU)
  6. Power Supply (recommended wattage)
  7. Case (compatible form factors)
- Real-time compatibility check
- Dynamic price calculation
- Smart component filtering
- Save & Order functionality


## 🛠️ Technologies

| Layer | Technology |
|-------|------------|
| **Backend** | .NET 9, ASP.NET Core Web API |
| **Database** | SQL Server 2022, Entity Framework Core |
| **Authentication** | JWT Tokens, Basic Auth |
| **Real-time** | SignalR (Support Chat) |
| **Message Queue** | RabbitMQ |
| **Desktop & Mobile** | Flutter 3.x, Dart |
| **Containerization** | Docker, Docker Compose |

## 📦 Installation and Setup

### 1. Docker (Recommended)
```bash
cd EasyPC
docker-compose up -d --build
```
**Services:**
- API: `http://localhost:5285`
- SQL Server: `localhost:1433`
- RabbitMQ: `localhost:15672` (guest/guest)

### 2. Desktop Application
```bash
cd UI/easy_pc_admin
flutter pub get
flutter run -d windows
```

**Login:** `admin` / `admin123` or `superadmin` / `superadmin123`

### 3. Mobile Application
```bash
cd UI/easy_pc_mobile
flutter pub get
flutter run
```

**Login:** `user1` / `user123`

---

## 🎮 How to Use

### Compatibility Checker
1. Click on "Compatibility" in navigation
2. Select components from dropdown menus
3. Click "Check Compatibility"
4. Review results:
   - ✅ **Green:** All compatible
   - ⚠️ **Orange:** Warnings
   - ❌ **Red:** Incompatible

### Build Wizard
1. Click on "Build Wizard" in navigation
2. Follow the 7 steps
3. Select a component from the list
4. Review real-time price
5. At the end: "Save Build"

## 🗄️ Seed Data

The application automatically creates seed data on first run:

| Type | Username | Password |
|------|----------|----------|
| Desktop Admin | `admin` | `admin123` |
| Super Admin | `superadmin` | `superadmin123` |
| Mobile User | `user1` | `user123` |

**Seed components:**
- 10+ Processors (Intel i5/i7/i9, AMD Ryzen 5/7/9)
- 10+ Motherboards (ASUS, MSI, Gigabyte)
- 8+ RAM modules (Corsair, Kingston, G.Skill)
- 10+ Graphics Cards (NVIDIA RTX, AMD Radeon)
- 6+ Power Supplies (Corsair, EVGA - 550W-850W)
- 6+ Cases (NZXT, Corsair - ATX, MicroATX, Mini-ITX)

---

## 📄 License

MIT License

⭐ **Difference from classic e-commerce projects:**
- ✅ Automatic compatibility verification
- ✅ Intelligent Build Wizard with 7 steps
- ✅ Real-time filtering based on previous choices
- ✅ Bottleneck detection
- ✅ Compatibility scoring system
- ✅ Power supply and component balance recommendations