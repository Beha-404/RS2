using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Model.Requests.RamRequests
{
    public class RamInsertRequest
    {
        [Required(ErrorMessage = "RAM name is required")]
        [MinLength(2, ErrorMessage = "Name must have at least 2 characters")]
        [MaxLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Price is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
        public required int Price { get; set; }

        [Required(ErrorMessage = "RAM speed is required")]
        [MinLength(2, ErrorMessage = "Speed must have at least 2 characters")]
        [MaxLength(50, ErrorMessage = "Speed cannot exceed 50 characters")]
        public required string Speed { get; set; }

        [Required(ErrorMessage = "Manufacturer is required")]
        [Range(1, int.MaxValue, ErrorMessage = "You must select a manufacturer")]
        public required int ManufacturerId { get; set; }
    }
}
