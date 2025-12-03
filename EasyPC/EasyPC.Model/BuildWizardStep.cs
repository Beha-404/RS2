namespace EasyPC.Model;

public class BuildWizardStep
{
    public int StepNumber { get; set; }
    public string StepName { get; set; } = string.Empty;
    public string ComponentType { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }
    public int? SelectedComponentId { get; set; }
}
