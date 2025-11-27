using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Diagnostics;
using System.Runtime.Intrinsics.Arm;

namespace EasyPC.Services.Database;

public class PC
{
    public int Id { get; set; }
    public string? Name { get; set; }
    public string Type { get; set; } = "PC";
    public int PcTypeId { get; set; }
    [ForeignKey(nameof(PcTypeId))]
    public PcType? PcType { get; set; }
    public int? Price { get; set; }
    public double? AverageRating { get; set; }
    public int? RatingCount { get; set; }
    public virtual ICollection<Rating>? Ratings { get; set; }
    public virtual ICollection<OrderDetails>? OrderDetails { get; set; }
    public bool Available { get; set; } = true;
    public string? Picture { get; set; }
    public string? StateMachine { get; set; }
    public int ProcessorId { get; set; }
    [ForeignKey(nameof(ProcessorId))]
    public  Processor? Processor { get; set; }
    public int RamId { get; set; }
    [ForeignKey(nameof(RamId))]
    public  Ram? Ram { get; set; }
    public int CaseId { get; set; }
    [ForeignKey(nameof(CaseId))]
    public  Case? Case { get; set; }
    public int MotherBoardId { get; set; }
    [ForeignKey(nameof(MotherBoardId))]
    public virtual Motherboard? MotherBoard { get; set; }
    public int PowerSupplyId { get; set; }
    [ForeignKey(nameof(PowerSupplyId))]
    public  PowerSupply? PowerSupply { get; set; }
    public int GraphicsCardId { get; set; }
    [ForeignKey(nameof(GraphicsCardId))]
    public  GraphicsCard? GraphicsCard { get; set; }
    [NotMapped]
    public int CalculatedPrice
    {
        get
        {
            return
                (Processor?.Price ?? 0) +
                (GraphicsCard?.Price ?? 0) +
                (Ram?.Price ?? 0) +
                (PowerSupply?.Price ?? 0) +
                (Case?.Price ?? 0) +
                (MotherBoard?.Price ?? 0);
        }
    }
}
