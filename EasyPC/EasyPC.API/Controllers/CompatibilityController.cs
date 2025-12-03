using EasyPC.Model;
using EasyPC.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CompatibilityController : ControllerBase
    {
        private readonly CompatibilityService _compatibilityService;

        public CompatibilityController(CompatibilityService compatibilityService)
        {
            _compatibilityService = compatibilityService;
        }

        [AllowAnonymous]
        [HttpPost("check")]
        public ActionResult<CompatibilityCheckResult> CheckCompatibility([FromBody] CompatibilityCheckRequest request)
        {
            var result = _compatibilityService.CheckCompatibility(
                request.ProcessorId,
                request.MotherboardId,
                request.RamId,
                request.GraphicsCardId,
                request.PowerSupplyId,
                request.CaseId
            );

            return Ok(result);
        }
    }

    public class CompatibilityCheckRequest
    {
        public int? ProcessorId { get; set; }
        public int? MotherboardId { get; set; }
        public int? RamId { get; set; }
        public int? GraphicsCardId { get; set; }
        public int? PowerSupplyId { get; set; }
        public int? CaseId { get; set; }
    }
}
