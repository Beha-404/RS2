using EasyPC.Model;
using EasyPC.Model.Requests.PcRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using EasyPC.Services.StateMachine.PcStateMachine;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace EasyPC.Services
{
    public class PcService : BaseService<Model.PC, PcSearchObject, PcInsertRequest, PcUpdateRequest, Database.PC,BasePcStateMachine>, IPcService
    {
        private readonly IMemoryCache _cache;

        public PcService(DatabaseContext context, IMapper mapper, BasePcStateMachine stateMachine, IHttpContextAccessor httpContextAccessor, IMemoryCache cache)
            : base(context, mapper, stateMachine, httpContextAccessor)
        {
            _cache = cache;
        }

        public override Model.PagedResult<Model.PC> GetAll(PcSearchObject search)
        {
            var query = _context.Set<Database.PC>()
                .Include(x => x.Processor)
                .Include(x => x.GraphicsCard)
                .Include(x => x.Case)
                .Include(x => x.PowerSupply)
                .Include(x => x.MotherBoard)
                .Include(x => x.Ram)
                .Include(x => x.PcType)
                .Include(x => x.Ratings)
                .AsQueryable();

            if (!IsAdmin())
            {
                query = query.Where(x => x.StateMachine == StateNames.Active);
            }

            if (search == null)
            {
                return new PagedResult<Model.PC>
                {
                    Items = _mapper.Map<List<Model.PC>>(query.ToList()),
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
            return new PagedResult<Model.PC>
            {
                Items = _mapper.Map<List<Model.PC>>(query.ToList()),
                TotalCount = totalCount ,
                Page = search.Page ?? 1,
                PageSize = search.PageSize ?? query.Count()
            };
        }

        public override Model.PC? GetById(int id)
        {
            var entity = _context.Set<Database.PC>()
                .Include(x => x.Processor)
                .Include(x => x.GraphicsCard)
                .Include(x => x.Case)
                .Include(x => x.PowerSupply)
                .Include(x => x.MotherBoard)
                .Include(x => x.Ram)
                .Include(x => x.PcType)
                .Include(x => x.Ratings)
                .FirstOrDefault( x => x.Id == id);
            if (entity == null)
            {
                return default;
            }
            return _mapper.Map<Model.PC>(entity);
        }

        public override IQueryable<Database.PC> ApplyFilter(IQueryable<Database.PC> query, PcSearchObject? search)
        {
            if (!IsAdmin())
            {
                query = query.Where(x => x.StateMachine == StateNames.Active);
            }

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                query = query.Where(x => x.Name != null && x.Name.Contains(search.Name));
            }

            if (search?.PcTypeId > 0)
            {
                query = query.Where(x => x.PcTypeId == search.PcTypeId);
            }

            if (search?.Price.HasValue == true)
            {
                query = query.Where(x => x.Price.HasValue && x.Price.Value == search.Price.Value);
            }

            if (search?.MinPrice.HasValue == true)
            {
                query = query.Where(x => x.Price.HasValue && x.Price.Value >= search.MinPrice.Value);
            }
            if (search?.MaxPrice.HasValue == true)
            {
                query = query.Where(x => x.Price.HasValue && x.Price.Value <= search.MaxPrice.Value);
            }

            if (search?.Rating.HasValue == true)
            {
                query = query.Where(x =>
                    (x.AverageRating.HasValue && (int)Math.Round(x.AverageRating.Value) >= search.Rating.Value)
                    || (x.Ratings != null && x.Ratings.Any() && (int)Math.Round(x.Ratings.Average(r => r.RatingValue)) >= search.Rating.Value)
                );
            }

            if (search?.Available.HasValue == true)
            {
                query = query.Where(x => x.Available == search.Available.Value);
            }

            if (search?.ProcessorManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.Processor != null && x.Processor.ManufacturerId == search.ProcessorManufacturerId.Value);
            }
            if (search?.GraphicsCardManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.GraphicsCard != null && x.GraphicsCard.ManufacturerId == search.GraphicsCardManufacturerId.Value);
            }
            if (search?.RamManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.Ram != null && x.Ram.ManufacturerId == search.RamManufacturerId.Value);
            }
            if (search?.MotherBoardManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.MotherBoard != null && x.MotherBoard.ManufacturerId == search.MotherBoardManufacturerId.Value);
            }
            if (search?.PowerSupplyManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.PowerSupply != null && x.PowerSupply.ManufacturerId == search.PowerSupplyManufacturerId.Value);
            }
            if (search?.CaseManufacturerId.HasValue == true)
            {
                query = query.Where(x => x.Case != null && x.Case.ManufacturerId == search.CaseManufacturerId.Value);
            }

            return query;
        }

        public override Model.PC? Insert(PcInsertRequest request)
        {
            ValidateComponentIds(
                request.ProcessorId,
                request.GraphicsCardId,
                request.RamId,
                request.MotherBoardId,
                request.PowerSupplyId,
                request.CaseId
            );

            return base.Insert(request);
        }

        public override Model.PC? Update(int id, PcUpdateRequest request)
        {
            ValidateComponentIds(
                request.ProcessorId,
                request.GraphicsCardId,
                request.RamId,
                request.MotherBoardId,
                request.PowerSupplyId,
                request.CaseId
            );

            return base.Update(id, request);
        }

        public List<Model.PC> Recommend(int ID)
        {
            var cacheKey = $"pc_recommendations_{ID}";

            if (_cache.TryGetValue(cacheKey, out List<Model.PC>? cachedRecommendations) && cachedRecommendations != null)
            {
                return cachedRecommendations;
            }

            var targetPc = _context.PCs
                .AsNoTracking()
                .Include(x => x.Processor)
                .Include(x => x.GraphicsCard)
                .Include(x => x.Ram)
                .Include(x => x.MotherBoard)
                .Include(x => x.PowerSupply)
                .Include(x => x.Case)
                .Include(x => x.PcType)
                .FirstOrDefault(x => x.Id == ID);

            if (targetPc == null)
            {
                return new List<Model.PC>();
            }

            var allPcs = _context.PCs
                .AsNoTracking()
                .Include(x => x.Processor)
                .Include(x => x.GraphicsCard)
                .Include(x => x.Ram)
                .Include(x => x.MotherBoard)
                .Include(x => x.PowerSupply)
                .Include(x => x.Case)
                .Include(x => x.PcType)
                .Include(x => x.Ratings)
                .Where(x => x.Id != ID && x.StateMachine == StateNames.Active)
                .Take(50)
                .ToList();

            var scoredPcs = new List<(Database.PC pc, double score)>();

            foreach (var pc in allPcs)
            {
                double similarityScore = CalculateSimilarityScore(targetPc, pc);
                scoredPcs.Add((pc, similarityScore));
            }

            var topRecommendations = scoredPcs
                .OrderByDescending(x => x.score)
                .Take(3)
                .Select(x => x.pc)
                .ToList();

            var recommendations = _mapper.Map<List<Model.PC>>(topRecommendations);

            var cacheOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
            };
            _cache.Set(cacheKey, recommendations, cacheOptions);

            return recommendations;
        }

        private double CalculateSimilarityScore(Database.PC target, Database.PC candidate)
        {
            double score = 0;

            if (target.PcTypeId == candidate.PcTypeId)
            {
                score += 30;
            }

            if (target.Price.HasValue && candidate.Price.HasValue)
            {
                decimal priceDifference = Math.Abs(target.Price.Value - candidate.Price.Value);
                decimal priceRange = target.Price.Value * 0.3m;

                if (priceDifference == 0)
                {
                    score += 25;
                }
                else if (priceDifference <= priceRange)
                {
                    double priceScore = 25 * (1 - ((double)priceDifference / (double)priceRange));
                    score += priceScore;
                }
            }

            if (target.Processor != null && candidate.Processor != null)
            {
                if (target.Processor.ManufacturerId == candidate.Processor.ManufacturerId)
                {
                    score += 15;
                }
            }

            if (target.GraphicsCard != null && candidate.GraphicsCard != null)
            {
                if (target.GraphicsCard.ManufacturerId == candidate.GraphicsCard.ManufacturerId)
                {
                    score += 15;
                }
            }

            if (target.Ram != null && candidate.Ram != null)
            {
                if (target.Ram.ManufacturerId == candidate.Ram.ManufacturerId)
                {
                    score += 5;
                }
            }

            if (target.MotherBoard != null && candidate.MotherBoard != null)
            {
                if (target.MotherBoard.ManufacturerId == candidate.MotherBoard.ManufacturerId)
                {
                    score += 5;
                }
            }

            if (candidate.AverageRating.HasValue && candidate.AverageRating.Value >= 4.0)
            {
                score += 5;
            }

            return score;
        }

        private void ValidateComponentIds(
            int processorId,
            int graphicsCardId,
            int ramId,
            int motherBoardId,
            int powerSupplyId,
            int caseId)
        {
            var errors = new List<string>();

            if (!_context.Processors.Any(p => p.Id == processorId))
            {
                errors.Add($"Processor with ID {processorId} does not exist");
            }

            if (!_context.GraphicsCards.Any(g => g.Id == graphicsCardId))
            {
                errors.Add($"Graphics Card with ID {graphicsCardId} does not exist");
            }

            if (!_context.Rams.Any(r => r.Id == ramId))
            {
                errors.Add($"RAM with ID {ramId} does not exist");
            }

            if (!_context.Motherboards.Any(m => m.Id == motherBoardId))
            {
                errors.Add($"Motherboard with ID {motherBoardId} does not exist");
            }

            if (!_context.PowerSupplies.Any(p => p.Id == powerSupplyId))
            {
                errors.Add($"Power Supply with ID {powerSupplyId} does not exist");
            }

            if (!_context.Cases.Any(c => c.Id == caseId))
            {
                errors.Add($"Case with ID {caseId} does not exist");
            }

            if (errors.Any())
            {
                throw new InvalidOperationException(
                    "Invalid component ID(s):\n" + string.Join("\n", errors)
                );
            }
        }

    }
}
