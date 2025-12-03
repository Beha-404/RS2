namespace EasyPC.Model;

public class CompatibilityCheckResult
{
    public bool IsCompatible { get; set; }
    public List<CompatibilityIssue> Issues { get; set; } = new();
    public int CompatibilityScore { get; set; } // 0-100
    public int EstimatedWattage { get; set; }
    public int RecommendedPsuWattage { get; set; }
    public string? PerformanceBottleneck { get; set; }
}
