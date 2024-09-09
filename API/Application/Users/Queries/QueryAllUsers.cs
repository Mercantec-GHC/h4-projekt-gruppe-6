using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace API.Application.Users.Queries
{
    public class QueryAllUsers
    {
        private readonly IUserRepository _repository;

        public QueryAllUsers(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<ActionResult<List<UserDTO>>> Handle()
        {
            List<User> users = await _repository.QueryAllUsersAsync();

            if (!users.Any())
            {
                return new ConflictObjectResult(new { message = "No users found." });
            }
            List<UserDTO> userDTOs = users.Select(user => new UserDTO
            {
                Id = user.Id,
                Email = user.Email,
                Username = user.Username,
                ProfilePicture = user.ProfilePicture,
            }).ToList();
            return userDTOs;
        }
    }
}
