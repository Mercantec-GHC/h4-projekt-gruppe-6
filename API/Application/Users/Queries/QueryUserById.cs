using API.Models;
using API.Persistence.Repositories;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;

namespace API.Application.Users.Queries
{
    public class QueryUserById
    {
        private readonly IUserRepository _repository;

        public QueryUserById(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<UserDTO> Handle(string id)
        {
            User user = await _repository.QueryUserByIdAsync(id);

            UserDTO userDTO = new UserDTO
            {
                Id = user.Id,
                Email = user.Email,
                Username = user.Username
            };

            return userDTO;
        }

    }
}
