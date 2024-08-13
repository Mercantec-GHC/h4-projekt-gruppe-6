using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace API.Application.Users.Commands
{
    public class DeleteUser
    {
        private readonly IUserRepository _repository;

        public DeleteUser(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<IActionResult> Handle(string id)
        {
            User currentUser = await _repository.QueryUserByIdAsync(id);
            if (currentUser == null)
                return new ConflictObjectResult(new { message = "User dosent exist." });

            bool success = await _repository.DeleteUserAsync(id);
            if (success)
                return new OkResult();
            else
                return new StatusCodeResult(StatusCodes.Status500InternalServerError);
        }
    }
}
