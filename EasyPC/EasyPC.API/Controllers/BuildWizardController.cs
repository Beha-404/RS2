using EasyPC.Model;
using EasyPC.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BuildWizardController : ControllerBase
    {
        private readonly BuildWizardService _buildWizardService;

        public BuildWizardController(BuildWizardService buildWizardService)
        {
            _buildWizardService = buildWizardService;
        }

        [AllowAnonymous]
        [HttpGet("steps")]
        public ActionResult<List<BuildWizardStep>> GetSteps()
        {
            var steps = _buildWizardService.GetWizardSteps();
            return Ok(steps);
        }

        [AllowAnonymous]
        [HttpPost("update-step")]
        public ActionResult<BuildWizardState> UpdateStep([FromBody] UpdateStepRequest request)
        {
            var updatedState = _buildWizardService.UpdateWizardState(
                request.State, 
                request.StepNumber, 
                request.ComponentId
            );
            return Ok(updatedState);
        }

        [AllowAnonymous]
        [HttpPost("filtered-components")]
        public ActionResult<List<dynamic>> GetFilteredComponents([FromBody] FilteredComponentsRequest request)
        {
            var components = _buildWizardService.GetFilteredComponents(request.State, request.StepNumber);
            return Ok(components);
        }
    }

    public class UpdateStepRequest
    {
        public BuildWizardState State { get; set; } = new();
        public int StepNumber { get; set; }
        public int? ComponentId { get; set; }
    }

    public class FilteredComponentsRequest
    {
        public BuildWizardState State { get; set; } = new();
        public int StepNumber { get; set; }
    }

    public class UpdateStateRequest
    {
        public BuildWizardState CurrentState { get; set; } = new();
        public int StepNumber { get; set; }
        public int? ComponentId { get; set; }
    }
}
