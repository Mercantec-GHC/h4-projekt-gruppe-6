using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages.Manage;
using Newtonsoft.Json.Linq;

namespace API.Application.Users.Queries
{
    public class QueryUsersByIds
    {
        private readonly IUserRepository _repository;

        public QueryUsersByIds(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<ActionResult<List<UserDTO>>> Handle(List<string> ids)
        {
            List<User> users = await _repository.QueryUsersByIdsAsync(ids);

            if (users == null)
            {
                return new ConflictObjectResult(new { message = "No user on given Id" });
            }

            return new OkObjectResult(users.Select(user => new { id = user.Id, email = user.Email, username = user.Username, profilePicture = user.ProfilePicture, createdAt = user.CreatedAt }));

        }

    }
}
