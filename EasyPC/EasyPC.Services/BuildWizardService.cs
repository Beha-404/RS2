using EasyPC.Model;
using EasyPC.Services.Database;

namespace EasyPC.Services
{
    public class BuildWizardService
    {
        private readonly DatabaseContext _context;
        private readonly CompatibilityService _compatibilityService;

        public BuildWizardService(DatabaseContext context, CompatibilityService compatibilityService)
        {
            _context = context;
            _compatibilityService = compatibilityService;
        }

        public List<BuildWizardStep> GetWizardSteps()
        {
            return new List<BuildWizardStep>
            {
                new BuildWizardStep { StepNumber = 1, StepName = "PC Type", ComponentType = "PcType" },
                new BuildWizardStep { StepNumber = 2, StepName = "Processor", ComponentType = "Processor" },
                new BuildWizardStep { StepNumber = 3, StepName = "Motherboard", ComponentType = "Motherboard" },
                new BuildWizardStep { StepNumber = 4, StepName = "RAM Memory", ComponentType = "Ram" },
                new BuildWizardStep { StepNumber = 5, StepName = "Graphics Card", ComponentType = "GraphicsCard" },
                new BuildWizardStep { StepNumber = 6, StepName = "Power Supply", ComponentType = "PowerSupply" },
                new BuildWizardStep { StepNumber = 7, StepName = "Case", ComponentType = "Case" }
            };
        }

        public BuildWizardState UpdateWizardState(BuildWizardState state, int stepNumber, int? componentId)
        {
            switch (stepNumber)
            {
                case 1:
                    state.PcTypeId = componentId;
                    break;
                case 2:
                    state.ProcessorId = componentId;
                    break;
                case 3:
                    state.MotherboardId = componentId;
                    break;
                case 4:
                    state.RamId = componentId;
                    break;
                case 5:
                    state.GraphicsCardId = componentId;
                    break;
                case 6:
                    state.PowerSupplyId = componentId;
                    break;
                case 7:
                    state.CaseId = componentId;
                    break;
            }

            if (stepNumber < 7)
            {
                state.CurrentStep = stepNumber + 1;
            }
            else
            {
                state.CurrentStep = stepNumber;
            }
            
            state.EstimatedPrice = CalculateTotalPrice(state);

            if (state.ProcessorId.HasValue || state.MotherboardId.HasValue)
            {
                state.CompatibilityCheck = _compatibilityService.CheckCompatibility(
                    state.ProcessorId,
                    state.MotherboardId,
                    state.RamId,
                    state.GraphicsCardId,
                    state.PowerSupplyId,
                    state.CaseId
                );
            }

            return state;
        }

        public List<dynamic> GetFilteredComponents(BuildWizardState state, int stepNumber)
        {
            switch (stepNumber)
            {
                case 2:
                    var processors = _context.Processors.Where(p => p.StateMachine == "active").ToList();
                    if (state.MotherboardId.HasValue)
                    {
                        var motherboard = _context.Motherboards.Find(state.MotherboardId.Value);
                        if (motherboard != null)
                        {
                            processors = processors.Where(p => p.Socket == motherboard.Socket).ToList();
                        }
                    }
                    return processors.Cast<dynamic>().ToList();

                case 3:
                    var motherboards = _context.Motherboards.Where(m => m.StateMachine == "active").ToList();
                    if (state.ProcessorId.HasValue)
                    {
                        var processor = _context.Processors.Find(state.ProcessorId.Value);
                        if (processor != null)
                        {
                            motherboards = motherboards.Where(m => m.Socket == processor.Socket).ToList();
                        }
                    }
                    return motherboards.Cast<dynamic>().ToList();

                case 4:
                    return _context.Rams.Where(r => r.StateMachine == "active").Cast<dynamic>().ToList();

                case 5:
                    return _context.GraphicsCards.Where(g => g.StateMachine == "active").Cast<dynamic>().ToList();

                case 6:
                    var allPSUs = _context.PowerSupplies.Where(p => p.StateMachine == "active").ToList();
                    if (state.CompatibilityCheck != null)
                    {
                        var recommended = state.CompatibilityCheck.RecommendedPsuWattage;
                        return allPSUs
                            .OrderBy(psu => Math.Abs(ExtractWattage(psu.Power) - recommended))
                            .Cast<dynamic>()
                            .ToList();
                    }
                    return allPSUs.Cast<dynamic>().ToList();

                case 7:
                    return _context.Cases.Where(c => c.StateMachine == "active").Cast<dynamic>().ToList();

                default:
                    return new List<dynamic>();
            }
        }

        private int? CalculateTotalPrice(BuildWizardState state)
        {
            int total = 0;

            if (state.ProcessorId.HasValue)
            {
                var processor = _context.Processors.Find(state.ProcessorId.Value);
                if (processor != null) total += processor.Price;
            }

            if (state.MotherboardId.HasValue)
            {
                var motherboard = _context.Motherboards.Find(state.MotherboardId.Value);
                if (motherboard != null) total += motherboard.Price;
            }

            if (state.RamId.HasValue)
            {
                var ram = _context.Rams.Find(state.RamId.Value);
                if (ram != null) total += ram.Price;
            }

            if (state.GraphicsCardId.HasValue)
            {
                var gpu = _context.GraphicsCards.Find(state.GraphicsCardId.Value);
                if (gpu != null) total += gpu.Price;
            }

            if (state.PowerSupplyId.HasValue)
            {
                var psu = _context.PowerSupplies.Find(state.PowerSupplyId.Value);
                if (psu != null) total += psu.Price;
            }

            if (state.CaseId.HasValue)
            {
                var pcCase = _context.Cases.Find(state.CaseId.Value);
                if (pcCase != null) total += pcCase.Price;
            }

            return total > 0 ? total : null;
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
    }
}
