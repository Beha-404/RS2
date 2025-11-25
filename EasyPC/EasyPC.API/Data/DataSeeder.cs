using EasyPC.Services.Database;
using Microsoft.EntityFrameworkCore;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Formats.Jpeg;
using System.Security.Cryptography;
using System.Text;

namespace EasyPC.API.Data
{
    public class DataSeeder
    {
        private readonly DatabaseContext _context;
        private readonly Random _random = new Random();

        public DataSeeder(DatabaseContext context)
        {
            _context = context;
        }

        public async Task SeedAsync()
        {
            Console.WriteLine("DataSeeder: Checking if database needs seeding...");
            
            var pcTypeCount = await _context.PcTypes.CountAsync();
            Console.WriteLine($"DataSeeder: Found {pcTypeCount} PC types in database");
            
            if (pcTypeCount > 0)
            {
                Console.WriteLine("DataSeeder: Database already seeded. Skipping...");
                return;
            }

            Console.WriteLine("DataSeeder: Starting database seeding...");
            
            await SeedUsers();
            var manufacturers = await SeedManufacturers();
            await SeedPcTypes();
            await SeedProcessors(manufacturers["CPU"]);
            await SeedRams(manufacturers["RAM"]);
            await SeedGraphicsCards(manufacturers["GPU"]);
            await SeedMotherboards(manufacturers["MOTHERBOARD"]);
            await SeedCases(manufacturers["CASE"]);
            await SeedPowerSupplies(manufacturers["PSU"]);

            var processors = await _context.Processors.ToListAsync();
            var rams = await _context.Rams.ToListAsync();
            var gpus = await _context.GraphicsCards.ToListAsync();
            var motherboards = await _context.Motherboards.ToListAsync();
            var cases = await _context.Cases.ToListAsync();
            var psus = await _context.PowerSupplies.ToListAsync();

            await SeedPCs(processors, rams, gpus, motherboards, cases, psus);
            
            Console.WriteLine("DataSeeder: Database seeding completed successfully!");
        }

        private async Task SeedUsers()
        {
            var users = new List<User>();

            var (superAdminHash, superAdminSalt) = GenerateHash("superadmin123");
            users.Add(new User
            {
                Username = "superadmin",
                Password = "superadmin123",
                Hash = superAdminHash,
                Salt = superAdminSalt,
                FirstName = "Super",
                LastName = "Admin",
                Email = "superadmin@easypc.com",
                Role = UserRole.SuperAdmin,
                City = "Sarajevo",
                State = "FBiH",
                Country = "Bosnia and Herzegovina"
            });

            var (adminHash, adminSalt) = GenerateHash("admin123");
            users.Add(new User
            {
                Username = "admin",
                Password = "admin123",
                Hash = adminHash,
                Salt = adminSalt,
                FirstName = "Admin",
                LastName = "User",
                Email = "admin@easypc.com",
                Role = UserRole.Admin,
                City = "Sarajevo",
                State = "FBiH",
                Country = "Bosnia and Herzegovina"
            });

            var firstNames = new[] { "Marko", "Ana", "Petar", "Jovana", "Stefan", "Milica", "Nikola", "Jelena", "Aleksandar", "Katarina" };
            var lastNames = new[] { "Marković", "Petrović", "Nikolić", "Jovanović", "Đorđević", "Ilić", "Pavlović", "Stanković", "Radovanović", "Milosavljević" };
            var cities = new[] { "Beograd", "Novi Sad", "Niš", "Sarajevo", "Zagreb", "Podgorica", "Skopje", "Ljubljana" };

            for (int i = 0; i < 10; i++)
            {
                var (hash, salt) = GenerateHash("user123");
                users.Add(new User
                {
                    Username = $"user{i + 1}",
                    Password = "user123",
                    Hash = hash,
                    Salt = salt,
                    FirstName = firstNames[i],
                    LastName = lastNames[i],
                    Email = $"user{i + 1}@example.com",
                    Role = UserRole.User,
                    City = cities[_random.Next(cities.Length)],
                    State = "FBiH",
                    Country = "Bosnia and Herzegovina"
                });
            }
            _context.Users.AddRange(users);
            await _context.SaveChangesAsync();
        }

        private async Task SeedPcTypes()
        {
            var pcTypes = new List<PcType>
            {
                new PcType { Name = "Gaming" },
                new PcType { Name = "Streaming" },
                new PcType { Name = "Work" },
                new PcType { Name = "Editing" }
            };
            _context.PcTypes.AddRange(pcTypes);
            await _context.SaveChangesAsync();
        }

        private async Task<Dictionary<string, List<Manufacturer>>> SeedManufacturers()
        {
            var manufacturers = new Dictionary<string, List<Manufacturer>>();

            manufacturers["CPU"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "Intel", ComponentType = "CPU" },
                new Manufacturer { Name = "AMD", ComponentType = "CPU" },
                new Manufacturer { Name = "Apple", ComponentType = "CPU" }
            };

            manufacturers["RAM"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "Corsair", ComponentType = "RAM" },
                new Manufacturer { Name = "G.Skill", ComponentType = "RAM" },
                new Manufacturer { Name = "Kingston", ComponentType = "RAM" }
            };

            manufacturers["GPU"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "NVIDIA", ComponentType = "GPU" },
                new Manufacturer { Name = "AMD Radeon", ComponentType = "GPU" },
                new Manufacturer { Name = "Intel", ComponentType = "GPU" }
            };

            manufacturers["MOTHERBOARD"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "ASUS", ComponentType = "MOTHERBOARD" },
                new Manufacturer { Name = "MSI", ComponentType = "MOTHERBOARD" },
                new Manufacturer { Name = "GIGABYTE", ComponentType = "MOTHERBOARD" }
            };

            manufacturers["CASE"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "NZXT", ComponentType = "CASE" },
                new Manufacturer { Name = "Corsair Cases", ComponentType = "CASE" },
                new Manufacturer { Name = "Phanteks", ComponentType = "CASE" }
            };

            manufacturers["PSU"] = new List<Manufacturer>
            {
                new Manufacturer { Name = "Corsair PSU", ComponentType = "PSU" },
                new Manufacturer { Name = "EVGA", ComponentType = "PSU" },
                new Manufacturer { Name = "Seasonic", ComponentType = "PSU" }
            };

            foreach (var category in manufacturers.Values)
            {
                _context.Manufacturers.AddRange(category);
            }

            await _context.SaveChangesAsync();
            Console.WriteLine($"Seeded {manufacturers.Values.Sum(m => m.Count)} manufacturers");

            return manufacturers;
        }

        private async Task SeedProcessors(List<Manufacturer> manufacturers)
        {
            var processors = new List<Processor>();

            var intelModels = new[]
            {
                ("Core i9-13900K", "LGA1700", 16, 24, 650),
                ("Core i7-13700K", "LGA1700", 16, 24, 550),
                ("Core i5-13600K", "LGA1700", 14, 20, 400),
                ("Core i9-12900K", "LGA1700", 16, 24, 600),
                ("Core i7-12700K", "LGA1700", 12, 20, 480),
                ("Core i5-12600K", "LGA1700", 10, 16, 350)
            };

            foreach (var (name, socket, cores, threads, price) in intelModels)
            {
                processors.Add(new Processor
                {
                    Name = name,
                    Socket = socket,
                    CoreCount = cores,
                    ThreadCount = threads,
                    Price = price,
                    Type = "Desktop",
                    ManufacturerId = manufacturers[0].Id,
                    StateMachine = "active"
                });
            }

            var amdModels = new[]
            {
                ("Ryzen 9 7950X", "AM5", 16, 32, 700),
                ("Ryzen 9 7900X", "AM5", 12, 24, 550),
                ("Ryzen 7 7700X", "AM5", 8, 16, 400),
                ("Ryzen 5 7600X", "AM5", 6, 12, 300),
                ("Ryzen 9 5950X", "AM4", 16, 32, 650),
                ("Ryzen 7 5800X3D", "AM4", 8, 16, 450)
            };

            foreach (var (name, socket, cores, threads, price) in amdModels)
            {
                processors.Add(new Processor
                {
                    Name = name,
                    Socket = socket,
                    CoreCount = cores,
                    ThreadCount = threads,
                    Price = price,
                    Type = "Desktop",
                    ManufacturerId = manufacturers[1].Id,
                    StateMachine = "active"
                });
            }

            var appleModels = new[]
            {
                ("M2 Max", "Apple Silicon", 12, 12, 800),
                ("M2 Pro", "Apple Silicon", 10, 10, 600),
                ("M2", "Apple Silicon", 8, 8, 500)
            };

            foreach (var (name, socket, cores, threads, price) in appleModels)
            {
                processors.Add(new Processor
                {
                    Name = name,
                    Socket = socket,
                    CoreCount = cores,
                    ThreadCount = threads,
                    Price = price,
                    Type = "Desktop",
                    ManufacturerId = manufacturers[2].Id,
                    StateMachine = "active"
                });
            }
            _context.Processors.AddRange(processors);
            await _context.SaveChangesAsync();
        }

        private async Task SeedRams(List<Manufacturer> manufacturers)
        {
            var rams = new List<Ram>();

            var ramConfigs = new[]
            {
                ("DDR5", "6000MHz", 16, 200),
                ("DDR5", "5600MHz", 16, 180),
                ("DDR5", "5200MHz", 16, 160),
                ("DDR4", "3600MHz", 16, 120),
                ("DDR4", "3200MHz", 16, 100),
                ("DDR5", "6400MHz", 32, 400),
                ("DDR5", "6000MHz", 32, 350),
                ("DDR4", "3600MHz", 32, 220)
            };

            foreach (var manufacturer in manufacturers)
            {
                foreach (var (type, speed, capacity, basePrice) in ramConfigs)
                {
                    rams.Add(new Ram
                    {
                        Name = $"{manufacturer.Name} {type} {capacity}GB {speed}",
                        Type = type,
                        Speed = speed,
                        Price = basePrice + _random.Next(-20, 30),
                        ManufacturerId = manufacturer.Id,
                        StateMachine = "active"
                    });
                }
            }
            _context.Rams.AddRange(rams);
            await _context.SaveChangesAsync();
        }

        private async Task SeedGraphicsCards(List<Manufacturer> manufacturers)
        {
            var gpus = new List<GraphicsCard>();

            var nvidiaModels = new[]
            {
                ("RTX 4090", "24GB GDDR6X", 1800, "High-End"),
                ("RTX 4080", "16GB GDDR6X", 1200, "High-End"),
                ("RTX 4070 Ti", "12GB GDDR6X", 850, "High-End"),
                ("RTX 4070", "12GB GDDR6X", 650, "Mid-Range"),
                ("RTX 4060 Ti", "8GB GDDR6", 450, "Mid-Range"),
                ("RTX 4060", "8GB GDDR6", 350, "Budget"),
                ("RTX 3090", "24GB GDDR6X", 1500, "High-End"),
                ("RTX 3080", "10GB GDDR6X", 900, "High-End"),
                ("RTX 3070", "8GB GDDR6", 600, "Mid-Range"),
                ("RTX 3060 Ti", "8GB GDDR6", 450, "Mid-Range")
            };

            foreach (var (name, vram, price, type) in nvidiaModels)
            {
                gpus.Add(new GraphicsCard
                {
                    Name = name,
                    VRAM = vram,
                    Price = price,
                    Type = type,
                    ManufacturerId = manufacturers[0].Id,
                    StateMachine = "active"
                });
            }

            var amdModels = new[]
            {
                ("RX 7900 XTX", "24GB GDDR6", 1000, "High-End"),
                ("RX 7900 XT", "20GB GDDR6", 850, "High-End"),
                ("RX 7800 XT", "16GB GDDR6", 550, "Mid-Range"),
                ("RX 7700 XT", "12GB GDDR6", 450, "Mid-Range"),
                ("RX 7600", "8GB GDDR6", 300, "Budget"),
                ("RX 6900 XT", "16GB GDDR6", 750, "High-End"),
                ("RX 6800 XT", "16GB GDDR6", 650, "High-End"),
                ("RX 6700 XT", "12GB GDDR6", 400, "Mid-Range")
            };

            foreach (var (name, vram, price, type) in amdModels)
            {
                gpus.Add(new GraphicsCard
                {
                    Name = name,
                    VRAM = vram,
                    Price = price,
                    Type = type,
                    ManufacturerId = manufacturers[1].Id,
                    StateMachine = "active"
                });
            }

            var intelModels = new[]
            {
                ("Arc A770", "16GB GDDR6", 400, "Mid-Range"),
                ("Arc A750", "8GB GDDR6", 300, "Budget"),
                ("Arc A580", "8GB GDDR6", 250, "Budget")
            };

            foreach (var (name, vram, price, type) in intelModels)
            {
                gpus.Add(new GraphicsCard
                {
                    Name = name,
                    VRAM = vram,
                    Price = price,
                    Type = type,
                    ManufacturerId = manufacturers[2].Id,
                    StateMachine = "active"
                });
            }
            _context.GraphicsCards.AddRange(gpus);
            await _context.SaveChangesAsync();
        }

        private async Task SeedMotherboards(List<Manufacturer> manufacturers)
        {
            var motherboards = new List<Motherboard>();

            var configs = new[]
            {
                ("LGA1700", "Z790", true, "ATX", 350),
                ("LGA1700", "B760", false, "ATX", 200),
                ("AM5", "X670E", true, "ATX", 400),
                ("AM5", "B650", false, "ATX", 180),
                ("AM4", "X570", true, "ATX", 250),
                ("AM4", "B550", false, "ATX", 150)
            };

            foreach (var manufacturer in manufacturers)
            {
                foreach (var (socket, model, oc, formFactor, price) in configs)
                {
                    motherboards.Add(new Motherboard
                    {
                        Name = $"{manufacturer.Name} {model} {formFactor}",
                        Socket = socket,
                        Model = model,
                        SupportsOverclocking = oc,
                        Type = formFactor,
                        Price = price + _random.Next(-30, 50),
                        ManufacturerId = manufacturer.Id,
                        StateMachine = "active"
                    });
                }
            }
            _context.Motherboards.AddRange(motherboards);
            await _context.SaveChangesAsync();
        }

        private async Task SeedCases(List<Manufacturer> manufacturers)
        {
            var cases = new List<Case>();

            var caseModels = new[]
            {
                ("Mid Tower", "ATX", 120),
                ("Full Tower", "E-ATX", 200),
                ("Compact", "Micro-ATX", 80),
                ("Mini Tower", "Mini-ITX", 100)
            };

            int modelCounter = 1;
            foreach (var manufacturer in manufacturers)
            {
                foreach (var (type, formFactor, price) in caseModels)
                {
                    cases.Add(new Case
                    {
                        Name = $"{manufacturer.Name} {type} Pro {modelCounter}",
                        Type = type,
                        FormFactor = formFactor,
                        Price = price + _random.Next(-20, 40),
                        ManufacturerId = manufacturer.Id,
                        StateMachine = "active"
                    });
                    modelCounter++;
                }
            }
            _context.Cases.AddRange(cases);
            await _context.SaveChangesAsync();
        }

        private async Task SeedPowerSupplies(List<Manufacturer> manufacturers)
        {
            var psus = new List<PowerSupply>();

            var wattages = new[] { "550W", "650W", "750W", "850W", "1000W", "1200W" };
            var prices = new[] { 80, 100, 130, 160, 220, 300 };

            foreach (var manufacturer in manufacturers)
            {
                for (int i = 0; i < wattages.Length; i++)
                {
                    psus.Add(new PowerSupply
                    {
                        Name = $"{manufacturer.Name} {wattages[i]} 80+ Gold",
                        Power = wattages[i],
                        Price = prices[i] + _random.Next(-15, 25),
                        Type = "Modular",
                        ManufacturerId = manufacturer.Id,
                        StateMachine = "active"
                    });
                }
            }
            _context.PowerSupplies.AddRange(psus);
            await _context.SaveChangesAsync();
        }

        private async Task SeedPCs(List<Processor> processors, List<Ram> rams, List<GraphicsCard> gpus,
            List<Motherboard> motherboards, List<Case> cases, List<PowerSupply> psus)
        {
            var pcs = new List<PC>();
            var pcTypes = await _context.PcTypes.ToListAsync();

            var imageBase64List = LoadImagesFromAssets();
            Console.WriteLine($"DataSeeder: Loaded {imageBase64List.Count} images from assets folder");

            for (int i = 1; i <= 30; i++)
            {
                var processor = processors[_random.Next(processors.Count)];
                var ram = rams[_random.Next(rams.Count)];
                var gpu = gpus[_random.Next(gpus.Count)];

                var compatibleMotherboards = motherboards.Where(m => m.Socket == processor.Socket).ToList();

                if (compatibleMotherboards.Count == 0)
                {
                    i--;
                    continue;
                }

                var motherboard = compatibleMotherboards[_random.Next(compatibleMotherboards.Count)];

                var pcCase = cases[_random.Next(cases.Count)];
                var psu = psus[_random.Next(psus.Count)];

                var totalPrice = processor.Price + ram.Price + gpu.Price +
                                motherboard.Price + pcCase.Price + psu.Price;

                var pcType = pcTypes[_random.Next(pcTypes.Count)];

                string? pcImage = null;
                if (imageBase64List.Count > 0)
                {
                    pcImage = imageBase64List[(i - 1) % imageBase64List.Count];
                }

                pcs.Add(new PC
                {
                    Name = $"{pcType.Name} Build #{i}",
                    Type = "PC",
                    PcTypeId = pcType.Id,
                    Price = totalPrice,
                    Available = true,
                    ProcessorId = processor.Id,
                    RamId = ram.Id,
                    GraphicsCardId = gpu.Id,
                    MotherBoardId = motherboard.Id,
                    CaseId = pcCase.Id,
                    PsuId = psu.Id,
                    Picture = pcImage,
                    StateMachine = "active",
                    RatingCount = _random.Next(1, 5),
                    AverageRating = _random.Next(10, 50) / 10.0
                });
            }
            _context.PCs.AddRange(pcs);
            await _context.SaveChangesAsync();
        }

        private List<string> LoadImagesFromAssets()
        {
            var imageBase64List = new List<string>();
            var assetsPath = Path.Combine(Directory.GetCurrentDirectory(), "Assets", "Images");

            if (!Directory.Exists(assetsPath))
            {
                Console.WriteLine($"DataSeeder: Assets folder not found at {assetsPath}");
                return imageBase64List;
            }

            var imageFiles = Directory.GetFiles(assetsPath, "*.*")
                .Where(file => file.ToLower().EndsWith(".jpg") ||
                               file.ToLower().EndsWith(".jpeg") ||
                               file.ToLower().EndsWith(".png") ||
                               file.ToLower().EndsWith(".webp"))
                .ToList();

            foreach (var imageFile in imageFiles)
            {
                try
                {
                    var originalSize = new FileInfo(imageFile).Length;
                    var compressedBytes = CompressImage(imageFile);
                    var base64String = Convert.ToBase64String(compressedBytes);
                    var compressedSize = compressedBytes.Length;
                    var compressionRatio = (1 - (double)compressedSize / originalSize) * 100;

                    imageBase64List.Add(base64String);
                    Console.WriteLine($"DataSeeder: Loaded and compressed {Path.GetFileName(imageFile)} " +
                                    $"(Original: {originalSize / 1024}KB, Compressed: {compressedSize / 1024}KB, " +
                                    $"Saved: {compressionRatio:F1}%)");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"DataSeeder: Failed to load image {imageFile}: {ex.Message}");
                }
            }

            return imageBase64List;
        }

        private byte[] CompressImage(string imagePath)
        {
            const int maxWidth = 600;
            const int jpegQuality = 75;

            using var image = Image.Load(imagePath);
            if (image.Width > maxWidth)
            {
                var ratio = (double)maxWidth / image.Width;
                var newHeight = (int)(image.Height * ratio);

                image.Mutate(x => x.Resize(new ResizeOptions
                {
                    Size = new Size(maxWidth, newHeight),
                    Mode = ResizeMode.Max,
                    Sampler = KnownResamplers.Lanczos3
                }));
            }
            using var memoryStream = new MemoryStream();
            var encoder = new JpegEncoder
            {
                Quality = jpegQuality
            };
            image.Save(memoryStream, encoder);

            return memoryStream.ToArray();
        }

        private (byte[] hash, byte[] salt) GenerateHash(string password)
        {
            using var hmac = new HMACSHA512();
            var salt = hmac.Key;
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));
            return (hash, salt);
        }
    }
}
