using EasyPC.Model.Requests.CaseRequests;
using EasyPC.Model.SearchObjects;
using EasyPC.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace EasyPC.API.Controllers
{
    [Authorize]
    public class CaseController : BaseController<Model.Case, CaseSearchObject,CaseInsertRequest,CaseUpdateRequest>
    {
        public CaseController(ICaseService service) : base(service)
        {
        }
    }
}
