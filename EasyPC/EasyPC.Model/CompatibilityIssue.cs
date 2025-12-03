namespace EasyPC.Model;

public class CompatibilityIssue
{
    public string Component { get; set; } = string.Empty;
    public string Issue { get; set; } = string.Empty;
    public string Severity { get; set; } = "Warning"; // "Warning", "Error", "Info"
    public string? Suggestion { get; set; }
}
