namespace EasyPC.Model;

public class BuildWizardState
{
    public int? PcTypeId { get; set; }
    public int? ProcessorId { get; set; }
    public int? MotherboardId { get; set; }
    public int? RamId { get; set; }
    public int? GraphicsCardId { get; set; }
    public int? PowerSupplyId { get; set; }
    public int? CaseId { get; set; }
    public int CurrentStep { get; set; } = 1;
    public int TotalSteps { get; set; } = 7;
    public int? EstimatedPrice { get; set; }
    public CompatibilityCheckResult? CompatibilityCheck { get; set; }
}
