using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Model.Requests.PcRequests
{
    public class PcInsertRequest
    {
        [Required(ErrorMessage = "PC name is required")]
        [MinLength(2, ErrorMessage = "Name must have at least 2 characters")]
        [MaxLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "PC type is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a PC type")]
        public required int PcTypeId { get; set; }

        [Required(ErrorMessage = "Processor is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a processor")]
        public required int ProcessorId { get; set; }

        [Required(ErrorMessage = "RAM is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select RAM")]
        public required int RamId { get; set; }

        [Required(ErrorMessage = "Case is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a case")]
        public required int CaseId { get; set; }

        [Required(ErrorMessage = "Motherboard is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a motherboard")]
        public required int MotherBoardId { get; set; }

        [Required(ErrorMessage = "Power supply is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a power supply")]
        public required int PowerSupplyId { get; set; }

        [Required(ErrorMessage = "Graphics card is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a graphics card")]
        public required int GraphicsCardId { get; set; }
    }
}
