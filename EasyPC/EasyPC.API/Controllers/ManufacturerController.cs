using EasyPC.Model;
using EasyPC.Model.Requests.ManufacturerRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ManufacturerController : ControllerBase
    {
        private readonly IManufacturerService _service;

        public ManufacturerController(IManufacturerService service)
        {
            _service = service;
        }

        [AllowAnonymous]
        [HttpGet("get")]
        public PagedResult<Manufacturer> GetAll([FromQuery] ManufacturerSearchObjects search)
        {
            return _service.GetAll(search);
        }

        [AllowAnonymous]
        [HttpGet("get/{id}")]
        public Manufacturer? GetById(int id)
        {
            return _service.GetById(id);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpPost("insert")]
        public Manufacturer? Insert([FromBody] ManufacturerInsertRequest insertRequest)
        {
            return _service.Insert(insertRequest);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpPut("update/{id}")]
        public Manufacturer? Update(int id, [FromBody] ManufacturerUpdateRequest updateRequest)
        {
            return _service.Update(id, updateRequest);
        }
    }
}
