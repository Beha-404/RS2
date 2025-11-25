using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
namespace EasyPC.Services
{
    public class ProductsService : IProductsService
    {
        private DatabaseContext _context;
        private IMapper _mapper;
        public ProductsService(DatabaseContext context, IMapper mapper)
        {
            _mapper = mapper;
            _context = context;
        }
        public async Task<Model.Products> GetAllProducts()
        {
            var products = new Database.Products
            {
                Processors = await _context.Processors.Where(x => x.StateMachine != "hidden").ToListAsync(),
                GraphicsCards = await _context.GraphicsCards.Where(x => x.StateMachine != "hidden").ToListAsync(),
                Rams = await _context.Rams.Where(x => x.StateMachine != "hidden").ToListAsync(),
                Cases = await _context.Cases.Where(x => x.StateMachine != "hidden").ToListAsync(),
                MotherBoards = await _context.Motherboards.Where(x => x.StateMachine != "hidden").ToListAsync(),
                PowerSupplies = await _context.PowerSupplies.Where(x => x.StateMachine != "hidden").ToListAsync(),
                Manufacturers = await _context.Manufacturers.ToListAsync(),
                Pcs = await _context.PCs.Where(x => x.StateMachine != "hidden").ToListAsync()
            };
            return _mapper.Map<Model.Products>(products);
        }
    }
}
