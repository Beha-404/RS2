using EasyPC.Model;
using EasyPC.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EasyPC.API.Controllers
{
    [AllowAnonymous]
    [Route("api/[controller]")]
    [ApiController]
    public class PcTypeController : ControllerBase
    {
        private readonly DatabaseContext _context;

        public PcTypeController(DatabaseContext context)
        {
            _context = context;
        }

        [HttpGet("get")]
        public async Task<ActionResult<List<Model.PcType>>> GetAll()
        {
            var pcTypes = await _context.PcTypes.ToListAsync();
            return Ok(pcTypes);
        }

        [HttpGet("get/{id}")]
        public async Task<ActionResult<Model.PcType>> GetById(int id)
        {
            var pcType = await _context.PcTypes.FindAsync(id);
            if (pcType == null)
            {
                return NotFound();
            }
            return Ok(pcType);
        }
    }
}
