using EasyPC.Model.Requests.UserRequests;
using EasyPC.Model.SearchObjects;

namespace EasyPC.Services.Interfaces
{
    public interface IUserService
    {
        public Model.User? Login(string username, string password);
        public Model.User? Register(string username, string email, string password);
        public Model.User? Delete(int id);
        public Model.User? Restore(int id);
        public Model.User? Update(int id, UserUpdateRequest updateRequest);
        public Model.User? UpdateRole(UpdateRoleRequest updateRoleRequest);
        public Model.PagedResult<Model.User>? Get(UserSearchObject? userSearchObject);
        public Model.User? GetUserById(int id);
    }
}
