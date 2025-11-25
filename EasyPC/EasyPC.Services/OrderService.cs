using EasyPC.Model;
using EasyPC.Model.Requests.OrderRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Model.Messages;
using EasyPC.Services.Database;
using EasyPC.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using EasyNetQ;

namespace EasyPC.Services
{
    public class OrderService : IOrderService
    {
        protected DatabaseContext _context;
        protected IMapper _mapper;
        protected IBus _bus;

        public OrderService(DatabaseContext context, IMapper mapper, IBus bus)
        {
            _context = context;
            _mapper = mapper;
            _bus = bus;
        }

        public bool Delete(int id)
        {
            var entity = _context.Orders.Find(id);
            if (entity == null)
                return false;
            _context.Orders.Remove(entity);
            _context.SaveChanges();
            return true;
        }

        public Model.PagedResult<Model.Order> Get(OrderSearchObjects searchObject)
        {
            var query = _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Processor)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Case)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.PowerSupply)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.GraphicsCard)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Ram)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.MotherBoard)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.PcType)
                .AsQueryable();

            if(searchObject == null)
            {
                return new Model.PagedResult<Model.Order>
                {
                    Items = _mapper.Map<List<Model.Order>>(query.ToList()),
                    TotalCount = query.Count(),
                    Page = 1,
                    PageSize = query.Count()
                };
            }

            if (searchObject.UserId.HasValue)
            {
                query = query.Where(o => o.UserId == searchObject.UserId.Value);
            }

            var totalCount = query.Count();

            if (searchObject.Page.HasValue && searchObject.PageSize.HasValue)
            {
                query = query
                    .Skip((searchObject.Page.Value - 1) * searchObject.PageSize.Value)
                    .Take(searchObject.PageSize.Value);
            }

            return new Model.PagedResult<Model.Order>
            {
                Items = _mapper.Map<List<Model.Order>>(query.ToList()),
                TotalCount = totalCount,
                Page = searchObject.Page ?? 1,
                PageSize = searchObject.PageSize ?? totalCount
            };
        }

        public Model.Order? GetById(int id)
        {
            var entity = _context.Orders
               .Include(o => o.OrderDetails) 
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.Processor)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.Case)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.PowerSupply)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.GraphicsCard)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.Ram)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.MotherBoard)
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.Pc)
                       .ThenInclude(pc => pc!.PcType)
               .FirstOrDefault(o => o.Id == id);

            return entity == null ? null : _mapper.Map<Model.Order>(entity);
        }

        public Model.Order? Insert(OrderInsertRequest insert)
        {
            if(insert == null)
                return null;

            var order = new Database.Order
            {
                OrderDate = DateTime.Now,
                PaymentMethod = insert.PaymentMethod,
                UserId = insert.UserId,
                TotalPrice = insert.OrderDetails.Sum(od => od.Quantity * od.UnitPrice)
            };

            foreach (var orderDetailsRequest in insert.OrderDetails)
            {
                var orderDetails = new Database.OrderDetails
                {
                    PcId = orderDetailsRequest.PcId,
                    Quantity = orderDetailsRequest.Quantity,
                    UnitPrice = orderDetailsRequest.UnitPrice
                };

                order.OrderDetails.Add(orderDetails);
            }
            _context.Orders.Add(order);
            _context.SaveChanges();

            var createdOrder = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Processor)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Case)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.PowerSupply)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.GraphicsCard)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.Ram)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.MotherBoard)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Pc)
                        .ThenInclude(pc => pc!.PcType)
                .FirstOrDefault(o => o.Id == order.Id);

            if (createdOrder != null && createdOrder.User != null)
            {
                var emailMessage = new OrderEmailMessage
                {
                    OrderId = createdOrder.Id,
                    UserEmail = createdOrder.User.Email ?? "",
                    UserName = createdOrder.User.Username ?? "",
                    OrderDate = createdOrder.OrderDate,
                    TotalPrice = createdOrder.TotalPrice,
                    PaymentMethod = createdOrder.PaymentMethod ?? "",
                    OrderItems = createdOrder.OrderDetails.Select(od => new OrderItemDetail
                    {
                        PcName = od.Pc?.Name ?? "Unknown PC",
                        Quantity = od.Quantity,
                        UnitPrice = od.UnitPrice
                    }).ToList()
                };

                _ = _bus.PubSub.PublishAsync(emailMessage);
            }

            return _mapper.Map<Model.Order>(createdOrder);
        }

        public Model.Order? Update(int id, OrderDetailsUpdateRequest updateRequest)
        {
            var entity = _context.Orders.Find(id);
            if (entity == null)
                return null;
            _mapper.Map(updateRequest, entity);
            _context.SaveChanges();
            return _mapper.Map<Model.Order>(entity);
        }
    }
}
