using EasyPC.Model.Requests.UserRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EasyPC.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        protected IUserService _service;
        public UserController(IUserService service)
        {
            _service = service;
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpGet("get")]
        public Model.PagedResult<Model.User>? Get([FromQuery]UserSearchObject? userSearch)
        {
            return _service.Get(userSearch);
        }

        [Authorize]
        [HttpGet("get/{id}")]
        public Model.User? GetUserById(int id)
        {
            return _service.GetUserById(id);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public ActionResult<Model.User> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Username and password are required" });
            }

            var user = _service.Login(request.Username, request.Password);
            
            if (user == null)
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }

            return Ok(user);
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public Model.User? Register([FromBody] RegisterRequest request)
        {
            return _service.Register(request.Username, request.Email, request.Password);
        }

        [Authorize]
        [HttpPost("update")]
        public Model.User? Update(int id,UserUpdateRequest request)
        {
            return _service.Update(id,request);
        }

        [Authorize(Roles = "SuperAdmin")]
        [HttpPost("update-role")]
        public Model.User? UpdateRole([FromBody] UpdateRoleRequest request)
        {
            return _service.UpdateRole(request);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpPut("delete/{id}")]
        public Model.User? Delete(int id)
        {
            return _service.Delete(id);
        }

        [Authorize(Roles = "Admin,SuperAdmin")]
        [HttpPut("restore/{id}")]
        public Model.User? Restore(int id)
        {
            return _service.Restore(id);
        }
    }
}
