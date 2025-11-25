using EasyPC.Model;
using EasyPC.Model.Requests.RatingRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class RatingController : ControllerBase
    {
        private readonly IRatingService _service;

        public RatingController(IRatingService service)
        {
            _service = service;
        }

        [AllowAnonymous]
        [HttpGet("get/all")]
        public ActionResult<List<Model.Rating>> Get([FromQuery] RatingSearchObject search)
        {
            var result = _service.GetAll(search);
            return Ok(result);
        }

        [AllowAnonymous]
        [HttpGet("get/{id}")]
        public ActionResult<Model.Rating?> GetById(int id)
        {
            var result = _service.GetById(id);
            return Ok(result);
        }

        [HttpPost("insert")]
        public ActionResult<Model.Rating?> Insert([FromBody] RatingInsertRequest insert)
        {
            var result = _service.Insert(insert);
            return CreatedAtAction(nameof(Get), new { id = result?.Id }, result);
        }

        [HttpPut("update/{id}")]
        public ActionResult<Model.Rating> Update(int id, [FromBody] RatingUpdateRequest updateRequest)
        {
            var result = _service.Update(id, updateRequest);
            return Ok(result);
        }

        [HttpDelete("delete/{id}")]
        public ActionResult<Model.Rating?> Delete(int id)
        {
            var result = _service.Delete(id);
            return Ok(result);
        }
    }
}
