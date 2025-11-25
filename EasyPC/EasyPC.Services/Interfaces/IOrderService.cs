using EasyPC.Model;
using EasyPC.Model.Requests.OrderRequests;
using EasyPC.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Services.Interfaces
{
    public interface IOrderService
    {
        public Model.PagedResult<Model.Order> Get(OrderSearchObjects searchObject);
        public Model.Order? Insert(OrderInsertRequest insert);
        public Model.Order? Update(int id, OrderDetailsUpdateRequest updateRequest);
        public bool Delete(int id);
        public Model.Order? GetById(int id);
    }
}
