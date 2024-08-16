using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
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

        public async Task<ActionResult<UserDTO>> Handle(string id)
        {
            User user = await _repository.QueryUserByIdAsync(id);

            if (user == null)
            {
                return new ConflictObjectResult(new { message = "No user on given Id" });
            }

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
