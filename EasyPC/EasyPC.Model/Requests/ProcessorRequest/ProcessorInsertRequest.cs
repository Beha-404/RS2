using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Model.Requests.ProcessorRequests
{
    public class ProcessorInsertRequest
    {
        [Required(ErrorMessage = "Naziv procesora je obavezan")]
        [MinLength(2, ErrorMessage = "Naziv mora imati najmanje 2 karaktera")]
        [MaxLength(100, ErrorMessage = "Naziv ne može imati više od 100 karaktera")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Socket je obavezan")]
        [MinLength(2, ErrorMessage = "Socket mora imati najmanje 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Socket ne može imati više od 50 karaktera")]
        public required string Socket { get; set; }

        [Required(ErrorMessage = "Cijena je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Cijena mora biti veća od 0")]
        public required int Price { get; set; }

        [Required(ErrorMessage = "Broj jezgara je obavezan")]
        [Range(1, 128, ErrorMessage = "Broj jezgara mora biti između 1 i 128")]
        public required int CoreCount { get; set; }

        [Required(ErrorMessage = "Broj threadova je obavezan")]
        [Range(1, 256, ErrorMessage = "Broj threadova mora biti između 1 i 256")]
        public required int ThreadCount { get; set; }

        [Required(ErrorMessage = "Proizvođač je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati proizvođača")]
        public required int ManufacturerId { get; set; }
    }
}
