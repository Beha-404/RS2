using EasyPC.Model;
using EasyPC.Model.Requests.ManufacturerRequests;
using EasyPC.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Services.Interfaces
{
    public interface IManufacturerService
    {
        public Model.PagedResult<Model.Manufacturer> GetAll(ManufacturerSearchObjects search);
        public Model.Manufacturer? GetById(int id);
        public Model.Manufacturer? Insert(ManufacturerInsertRequest insertRequest);
        public Model.Manufacturer? Update(int id, ManufacturerUpdateRequest updateRequest);
    }
}
