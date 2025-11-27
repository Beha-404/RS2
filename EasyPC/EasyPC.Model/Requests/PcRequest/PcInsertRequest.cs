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
        [Required(ErrorMessage = "Naziv računara je obavezan")]
        [MinLength(2, ErrorMessage = "Naziv mora imati najmanje 2 karaktera")]
        [MaxLength(100, ErrorMessage = "Naziv ne može imati više od 100 karaktera")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Tip računara je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati tip računara")]
        public required int PcTypeId { get; set; }

        [Required(ErrorMessage = "Procesor je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati procesor")]
        public required int ProcessorId { get; set; }

        [Required(ErrorMessage = "RAM je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati RAM")]
        public required int RamId { get; set; }

        [Required(ErrorMessage = "Kućište je obavezno")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati kućište")]
        public required int CaseId { get; set; }

        [Required(ErrorMessage = "Matična ploča je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati matičnu ploču")]
        public required int MotherBoardId { get; set; }

        [Required(ErrorMessage = "Napajanje je obavezno")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati napajanje")]
        public required int PowerSupplyId { get; set; }

        [Required(ErrorMessage = "Grafička kartica je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati grafičku karticu")]
        public required int GraphicsCardId { get; set; }
    }
}
