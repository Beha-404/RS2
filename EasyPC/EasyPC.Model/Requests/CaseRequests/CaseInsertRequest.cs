using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Model.Requests.CaseRequests
{
    public class CaseInsertRequest
    {
        [Required(ErrorMessage = "Naziv kućišta je obavezan")]
        [MinLength(2, ErrorMessage = "Naziv mora imati najmanje 2 karaktera")]
        [MaxLength(100, ErrorMessage = "Naziv ne može imati više od 100 karaktera")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Cijena je obavezna")]
        [Range(1, int.MaxValue, ErrorMessage = "Cijena mora biti veća od 0")]
        public required int Price { get; set; }

        [Required(ErrorMessage = "Form Factor je obavezan")]
        [MinLength(2, ErrorMessage = "Form Factor mora imati najmanje 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Form Factor ne može imati više od 50 karaktera")]
        public required string FormFactor { get; set; }

        [Required(ErrorMessage = "Proizvođač je obavezan")]
        [Range(1, int.MaxValue, ErrorMessage = "Morate izabrati proizvođača")]
        public required int ManufacturerId { get; set; }
    }
}
