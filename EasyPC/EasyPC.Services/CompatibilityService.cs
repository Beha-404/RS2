using EasyPC.Model;
using EasyPC.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace EasyPC.Services
{
    public class CompatibilityService
    {
        private readonly DatabaseContext _context;

        public CompatibilityService(DatabaseContext context)
        {
            _context = context;
        }

        public CompatibilityCheckResult CheckCompatibility(
            int? processorId,
            int? motherboardId,
            int? ramId,
            int? graphicsCardId,
            int? powerSupplyId,
            int? caseId)
        {
            var result = new CompatibilityCheckResult
            {
                IsCompatible = true,
                Issues = new List<CompatibilityIssue>(),
                CompatibilityScore = 100
            };

            var processor = processorId.HasValue ? _context.Processors.Find(processorId.Value) : null;
            var motherboard = motherboardId.HasValue ? _context.Motherboards.Find(motherboardId.Value) : null;
            var ram = ramId.HasValue ? _context.Rams.Find(ramId.Value) : null;
            var graphicsCard = graphicsCardId.HasValue ? _context.GraphicsCards.Find(graphicsCardId.Value) : null;
            var powerSupply = powerSupplyId.HasValue ? _context.PowerSupplies.Find(powerSupplyId.Value) : null;
            var caseComponent = caseId.HasValue ? _context.Cases.Find(caseId.Value) : null;

            if (processor != null && motherboard != null)
            {
                if (processor.Socket != motherboard.Socket)
                {
                    result.Issues.Add(new CompatibilityIssue
                    {
                        Component = "Processor & Motherboard",
                        Issue = $"Socket is not compatible! Processor uses {processor.Socket}, motherboard supports {motherboard.Socket}",
                        Severity = "Error",
                        Suggestion = $"Select a processor with {motherboard.Socket} socket or motherboard with {processor.Socket} socket"
                    });
                    result.IsCompatible = false;
                    result.CompatibilityScore -= 30;
                }
            }

            if (motherboard != null && caseComponent != null)
            {
                var motherboardFormFactor = ExtractFormFactor(motherboard.Model ?? motherboard.Name ?? "");
                var caseFormFactor = caseComponent.FormFactor;

                if (!string.IsNullOrEmpty(motherboardFormFactor) && !string.IsNullOrEmpty(caseFormFactor) && !IsFormFactorCompatible(motherboardFormFactor, caseFormFactor))
                {
                    result.Issues.Add(new CompatibilityIssue
                    {
                        Component = "Motherboard & Case",
                        Issue = $"Form factor is not compatible! Motherboard is {motherboardFormFactor}, case supports {caseFormFactor}",
                        Severity = "Error",
                        Suggestion = "Select a case that supports your motherboard's form factor"
                    });
                    result.IsCompatible = false;
                    result.CompatibilityScore -= 25;
                }
            }

            result.EstimatedWattage = CalculateWattage(processor, graphicsCard, ram, motherboard);
            result.RecommendedPsuWattage = (int)(result.EstimatedWattage * 1.3);

            if (powerSupply != null)
            {
                var psuWattage = ExtractWattage(powerSupply.Power);
                if (psuWattage > 0 && psuWattage < result.EstimatedWattage)
                {
                    result.Issues.Add(new CompatibilityIssue
                    {
                        Component = "Power Supply",
                        Issue = $"Power supply is too weak! Estimated consumption: {result.EstimatedWattage}W, your PSU: {psuWattage}W",
                        Severity = "Error",
                        Suggestion = $"We recommend a power supply of at least {result.RecommendedPsuWattage}W"
                    });
                    result.IsCompatible = false;
                    result.CompatibilityScore -= 20;
                }
                else if (psuWattage > 0 && psuWattage < result.RecommendedPsuWattage)
                {
                    result.Issues.Add(new CompatibilityIssue
                    {
                        Component = "Power Supply",
                        Issue = $"Power supply is on the lower limit. Recommended: {result.RecommendedPsuWattage}W, yours: {psuWattage}W",
                        Severity = "Warning",
                        Suggestion = "Consider a more powerful PSU for better stability and efficiency"
                    });
                    result.CompatibilityScore -= 10;
                }
            }

            if (processor != null && graphicsCard != null)
            {
                var bottleneck = DetectBottleneck(processor, graphicsCard);
                if (!string.IsNullOrEmpty(bottleneck))
                {
                    result.PerformanceBottleneck = bottleneck;
                    result.Issues.Add(new CompatibilityIssue
                    {
                        Component = "Performance Balance",
                        Issue = bottleneck,
                        Severity = "Info",
                        Suggestion = "Consider a more balanced configuration for optimal performance"
                    });
                    result.CompatibilityScore -= 5;
                }
            }

            result.CompatibilityScore = Math.Max(0, result.CompatibilityScore);

            return result;
        }

        private string ExtractFormFactor(string modelName)
        {
            modelName = modelName.ToUpper();
            if (modelName.Contains("ATX") && !modelName.Contains("MINI") && !modelName.Contains("MICRO"))
                return "ATX";
            if (modelName.Contains("MICRO-ATX") || modelName.Contains("MATX") || modelName.Contains("MICRO ATX"))
                return "Micro-ATX";
            if (modelName.Contains("MINI-ITX") || modelName.Contains("ITX"))
                return "Mini-ITX";
            if (modelName.Contains("E-ATX") || modelName.Contains("EATX"))
                return "E-ATX";
            
            return "ATX";
        }

        private bool IsFormFactorCompatible(string motherboardFF, string caseFF)
        {
            motherboardFF = motherboardFF.ToUpper();
            caseFF = caseFF.ToUpper();

            if (caseFF.Contains("E-ATX") || caseFF.Contains("EATX"))
                return true;

            if (caseFF.Contains("ATX") && !caseFF.Contains("MICRO") && !caseFF.Contains("MINI"))
                return motherboardFF.Contains("ATX") || motherboardFF.Contains("MICRO") || motherboardFF.Contains("MINI");

            if (caseFF.Contains("MICRO"))
                return motherboardFF.Contains("MICRO") || motherboardFF.Contains("MINI");

            if (caseFF.Contains("MINI"))
                return motherboardFF.Contains("MINI");

            return true;
        }

        private int CalculateWattage(
            Database.Processor? processor,
            Database.GraphicsCard? graphicsCard,
            Database.Ram? ram,
            Database.Motherboard? motherboard)
        {
            int totalWattage = 50;

            if (processor != null)
            {
                totalWattage += processor.CoreCount * 15;
            }

            if (graphicsCard != null)
            {
                var vramGB = ExtractVRAM(graphicsCard.VRAM);
                if (vramGB >= 12)
                    totalWattage += 350;
                else if (vramGB >= 8)
                    totalWattage += 250;
                else if (vramGB >= 6)
                    totalWattage += 180;
                else if (vramGB >= 4)
                    totalWattage += 120;
                else
                    totalWattage += 75;
            }

            if (ram != null)
            {
                totalWattage += 6;
            }

            if (motherboard != null)
            {
                totalWattage += 80;
            }

            return totalWattage;
        }

        private int ExtractVRAM(string vramString)
        {
            if (string.IsNullOrEmpty(vramString))
                return 0;

            var match = System.Text.RegularExpressions.Regex.Match(vramString, @"(\d+)\s*GB");
            if (match.Success && int.TryParse(match.Groups[1].Value, out int vram))
            {
                return vram;
            }

            return 0;
        }

        private int ExtractWattage(string powerString)
        {
            if (string.IsNullOrEmpty(powerString))
                return 0;

            var match = System.Text.RegularExpressions.Regex.Match(powerString, @"(\d+)\s*W");
            if (match.Success && int.TryParse(match.Groups[1].Value, out int wattage))
            {
                return wattage;
            }

            return 0;
        }

        private string? DetectBottleneck(Database.Processor processor, Database.GraphicsCard graphicsCard)
        {
            if (processor.Price > 0 && graphicsCard.Price > 0)
            {
                double ratio = (double)graphicsCard.Price / processor.Price;

                if (ratio > 3)
                    return "Processor may be a bottleneck for this graphics card. GPU is too powerful for this CPU.";
                
                if (ratio < 0.33)
                    return "Graphics card may be a bottleneck. Processor is too powerful for this GPU.";
            }

            var vramGB = ExtractVRAM(graphicsCard.VRAM);
            if (processor.CoreCount < 4 && vramGB >= 8)
                return "Processor with few cores may limit the performance of a powerful graphics card.";

            return null;
        }
    }
}
