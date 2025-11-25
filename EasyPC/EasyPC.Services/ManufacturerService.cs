using EasyPC.Model;
using EasyPC.Model.Requests.ManufacturerRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace EasyPC.Services
{
    public class ManufacturerService : IManufacturerService
    {
        private readonly DatabaseContext _context;
        private IMapper _mapper;
        
        public ManufacturerService(DatabaseContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public Model.PagedResult<Model.Manufacturer> GetAll(ManufacturerSearchObjects search)
        {
            var query = _context.Manufacturers.AsQueryable();
            
            if (search != null)
            {
                query = ApplyFilters(query, search);
            }

            var totalCount = query.Count();

            if (search?.Page.HasValue == true && search.PageSize.HasValue)
            {
                var skip = (search.Page.Value - 1) * search.PageSize.Value;
                var take = search.PageSize.Value;
                query = query.Skip(skip).Take(take);
            }

            return new Model.PagedResult<Model.Manufacturer>
            {
                Items = _mapper.Map<List<Model.Manufacturer>>(query.ToList()),
                TotalCount = totalCount,
                Page = search?.Page ?? 1,
                PageSize = search?.PageSize ?? totalCount
            };
        }

        public IQueryable<Database.Manufacturer> ApplyFilters(IQueryable<Database.Manufacturer> query, ManufacturerSearchObjects searchObjects) {

            if (!string.IsNullOrEmpty(searchObjects.ComponentType)) {
                query = query.Where(x => x.ComponentType == searchObjects.ComponentType);
            }

            if (!string.IsNullOrEmpty(searchObjects.Name)) {
                query = query.Where(x => x.Name.Contains(searchObjects.Name));
            }

            return query;
        }

        public Model.Manufacturer? GetById(int id)
        {
            var entity = _context.Manufacturers.FirstOrDefault(x => x.Id == id);
            if (entity == null)
            {
                return null;
            }
            return _mapper.Map<Model.Manufacturer>(entity);
        }

        public Model.Manufacturer? Insert(ManufacturerInsertRequest insertRequest)
        {
            if(insertRequest == null)
            {
                return null;
            }

            var entity = _mapper.Map<Database.Manufacturer>(insertRequest);
            _context.Manufacturers.Add(entity);
            _context.SaveChanges();
            return _mapper.Map<Model.Manufacturer>(entity);
        }

        public Model.Manufacturer? Update(int id, ManufacturerUpdateRequest updateRequest)
        {
            if(updateRequest == null)
            {
                return null;
            }

            var entity = _context.Manufacturers.FirstOrDefault(x => x.Id == id);
            if(entity == null)
            {
                return null;
            }

            _mapper.Map(updateRequest, entity);
            _context.SaveChanges();
            return _mapper.Map<Model.Manufacturer>(entity);
        }
    }
}
