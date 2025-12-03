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
        [Required(ErrorMessage = "Manufacturer name is required")]
        [MinLength(2, ErrorMessage = "Name must have at least 2 characters")]
        [MaxLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Component type is required")]
        [MinLength(2, ErrorMessage = "Component type must have at least 2 characters")]
        [MaxLength(50, ErrorMessage = "Component type cannot exceed 50 characters")]
        public required string ComponentType { get; set; }
    }
}
