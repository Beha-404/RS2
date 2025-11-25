using EasyPC.Model.Requests.OrderRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class OrderController : ControllerBase
    {
        private readonly IOrderService _service;

        public OrderController(IOrderService service)
        {
            _service = service;
        }

        [HttpGet("get")]
        public ActionResult<List<Model.Order>> Get([FromQuery] OrderSearchObjects search)
        {
            var result = _service.Get(search);
            return Ok(result);
        }
        [HttpGet("get/{id}")]
        public ActionResult<Model.Order?> GetById(int id)
        {
            var result = _service.GetById(id);
            return Ok(result);
        }

        [HttpPost("insert")]
        public ActionResult<Model.Order?> Insert([FromBody] OrderInsertRequest insert)
        {
            var result = _service.Insert(insert);
            return Ok(result);
        }

        [HttpPut("update/{id}")]
        public ActionResult<Model.Order?> Update(int id, [FromBody] OrderDetailsUpdateRequest updateRequest)
        {
            var result = _service.Update(id, updateRequest);
            return Ok(result);
        }

        [HttpDelete("delete/{id}")]
        public ActionResult<Model.Order?> Delete(int id)
        {
            var result = _service.Delete(id);
            return Ok(result);
        }
    }
}
