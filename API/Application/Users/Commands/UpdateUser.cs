using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace API.Application.Users.Commands
{
    public class UpdateUser
    {
        private readonly IUserRepository _repository;

        public UpdateUser(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<IActionResult> Handle(UserDTO userDTO)
        {
            List<User> existingUsers = await _repository.QueryAllUsersAsync();
            User currentUser = await _repository.QueryUserByIdAsync(userDTO.Id);

            foreach (User existingUser in existingUsers)
            {
                if (existingUser.Username == userDTO.Username && existingUser.Username != currentUser.Username)
                {
                    return new ConflictObjectResult(new { message = "Username is already in use." });
                }

                if (existingUser.Email == userDTO.Email && existingUser.Email != currentUser.Email)
                {
                    return new ConflictObjectResult(new { message = "Email is already in use." });
                }
            }
            currentUser.Username = userDTO.Username;
            currentUser.Email = userDTO.Email;

            bool success = await _repository.UpdateUserAsync(currentUser);
            if (success)
                return new OkResult();
            else
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);

        }
    }
}
