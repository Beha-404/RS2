using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Model.Requests.ManufacturerRequests
{
    public class ManufacturerInsertRequest
    {
        [Required(ErrorMessage = "Naziv proizvođača je obavezan")]
        [MinLength(2, ErrorMessage = "Naziv mora imati najmanje 2 karaktera")]
        [MaxLength(100, ErrorMessage = "Naziv ne može imati više od 100 karaktera")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Tip komponente je obavezan")]
        [MinLength(2, ErrorMessage = "Tip komponente mora imati najmanje 2 karaktera")]
        [MaxLength(50, ErrorMessage = "Tip komponente ne može imati više od 50 karaktera")]
        public required string ComponentType { get; set; }
    }
}
