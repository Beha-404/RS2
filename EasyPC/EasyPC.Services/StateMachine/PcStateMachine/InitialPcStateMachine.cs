using EasyPC.Model.Requests.PcRequests;
using EasyPC.Services.Database;
using MapsterMapper;

namespace EasyPC.Services.StateMachine.PcStateMachine
{
    public class InitialPcStateMachine : InitialStateMachine<Model.PC, PcInsertRequest, PcUpdateRequest, Database.PC>
    {
        public InitialPcStateMachine(DatabaseContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override Model.PC? Insert(PcInsertRequest insert)
        {
            var entity = _mapper.Map<Database.PC>(insert!);

            var processor =  _context.Processors.Find(entity.ProcessorId);
            var graphicsCard =  _context.GraphicsCards.Find(entity.GraphicsCardId);
            var ram =  _context.Rams.Find(entity.RamId);
            var caseItem =  _context.Cases.Find(entity.CaseId);
            var motherBoard =  _context.Motherboards.Find(entity.MotherBoardId);
            var psu =  _context.PowerSupplies.Find(entity.PowerSupplyId);

            entity.Price =
                processor!.Price +
                graphicsCard!.Price +
                ram!.Price +
                caseItem!.Price +
                motherBoard!.Price +
                psu!.Price;

            _context.Set<Database.PC>().Add(entity);
            entity.GetType().GetProperty("StateMachine")?.SetValue(entity, StateNames.Draft);
            _context.SaveChanges();
            return _mapper.Map<Model.PC>(entity);
        }
    }
}
