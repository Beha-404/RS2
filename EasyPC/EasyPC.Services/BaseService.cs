using EasyPC.Model;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using EasyPC.Services.StateMachine;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace EasyPC.Services
{
    public class BaseService<Tmodel, TSearch, TInsert, TUpdate, TEntity, TStateMachine> : IBaseService<Tmodel, TSearch, TInsert, TUpdate> where TSearch : BaseSearchObject
    where TEntity : class
    where TStateMachine : IBaseStateMachine<Tmodel, TInsert, TUpdate, TEntity>
    {
        protected DatabaseContext _context;
        protected IMapper _mapper;
        protected TStateMachine _stateMachine;
        protected readonly IHttpContextAccessor _httpContextAccessor;
        
        public BaseService(DatabaseContext context, IMapper mapper, TStateMachine stateMachine, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _mapper = mapper;
            _stateMachine = stateMachine;
            _httpContextAccessor = httpContextAccessor;
        }

        public class StateNames
        {
            public const string Draft = "draft";
            public const string Active = "active";
            public const string Hidden = "hidden";    
        }

        public virtual Model.PagedResult<Tmodel> GetAll(TSearch search)
        {
            var query = _context.Set<TEntity>().AsQueryable();
            if (search == null)
            {
                return new Model.PagedResult<Tmodel>
                {
                    Items = _mapper.Map<List<Tmodel>>(query.ToList()),
                    TotalCount = query.Count(),
                    Page = 1,
                    PageSize = query.Count()
                };
            }

            query = ApplyFilter(query, search);

            var totalCount = query.Count();

            if (search.Page.HasValue && search.PageSize.HasValue)
            {
                var skip = (search.Page.Value - 1) * search.PageSize.Value;
                var take = search.PageSize.Value;
                query = query.Skip(skip).Take(take);
            }
            return new Model.PagedResult<Tmodel>
            {
                Items = _mapper.Map<List<Tmodel>>(query.ToList()),
                TotalCount = totalCount,
                Page = search.Page ?? 1,
                PageSize = search.PageSize ?? query.Count()
            };
        }

        public virtual Tmodel? GetById(int id)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                return default;
            }
            return _mapper.Map<Tmodel>(entity);
        }

        public virtual Tmodel Update(int id, TUpdate updateRequest)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                throw new Exception("ID not found");
            }
            var stateValue = getStateValue(entity);
            var state = _stateMachine.NextState(stateValue);
            return state.Update(id, updateRequest)!;
        }

        public virtual Tmodel? Insert(TInsert insert)
        {
            if (insert == null)
            {
                throw new ArgumentException("Insert model is null");
            }
            var state = _stateMachine.NextState("initial");
            return state.Insert(insert);
        }

        public virtual Tmodel? Hide(int id)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                throw new Exception("ID not found");
            }
            var stateValue = getStateValue(entity);
            var state = _stateMachine.NextState(stateValue);
            return state.Hide(id);
        }

        public virtual Tmodel? Activate(int id)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                throw new Exception("ID not found");
            }
            var stateValue = getStateValue(entity);
            var state = _stateMachine.NextState(stateValue);
            return state.Activate(id);
        }

        public virtual Tmodel? Edit(int id)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                throw new Exception("ID not found");
            }
            var stateValue = getStateValue(entity);
            var state = _stateMachine.NextState(stateValue);
            return state.Edit(id);
        }

        protected virtual IQueryable<TEntity> AddFilter(IQueryable<TEntity> query, string? search)
        {
            return query;
        }

        protected string getStateValue(TEntity entity)
        {
            var smProperty = entity.GetType().GetProperty("StateMachine");
            var smValue = smProperty?.GetValue(entity) as string;
            if (string.IsNullOrWhiteSpace(smValue))
            {
                throw new Exception("Entity StateMachine property is missing or null");
            }
            return smValue;
        }

        protected bool IsAdmin()
        {
            var roleClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.Role)?.Value;
            
            if (string.IsNullOrWhiteSpace(roleClaim))
            {
                return false;
            }

            return roleClaim == Database.UserRole.Admin.ToString() || roleClaim == Database.UserRole.SuperAdmin.ToString();
        }

        public List<string> AllowedActions(int id)
        {
            var entity = _context.Set<TEntity>().Find(id);
            if (entity == null)
            {
                throw new Exception("ID not found");
            }
            var stateValue = getStateValue(entity);
            var state = _stateMachine.NextState(stateValue);
            return state.AllowedActions();
        }

        public virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch? searchObject)
        {
            return query;
        }
    }
}
