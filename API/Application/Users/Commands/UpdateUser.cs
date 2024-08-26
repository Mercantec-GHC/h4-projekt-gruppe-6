using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace API.Application.Users.Commands
{
    public class UpdateUser
    {
        private readonly IUserRepository _repository;

        public UpdateUser(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<IActionResult> Handle(UpdateUserDTO UpdateUserDTO)
        {
            List<User> existingUsers = await _repository.QueryAllUsersAsync();
            User currentUser = await _repository.QueryUserByIdAsync(UpdateUserDTO.Id);

            foreach (User existingUser in existingUsers)
            {
                if (existingUser.Username == UpdateUserDTO.Username && existingUser.Username != currentUser.Username)
                {
                    return new ConflictObjectResult(new { message = "Username is already in use." });
                }

                if (existingUser.Email == UpdateUserDTO.Email && existingUser.Email != currentUser.Email)
                {
                    return new ConflictObjectResult(new { message = "Email is already in use." });
                }
            }

            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(UpdateUserDTO.Password);


            currentUser.Username = UpdateUserDTO.Username;
            currentUser.Email = UpdateUserDTO.Email;
            currentUser.HashedPassword = hashedPassword;

            bool success = await _repository.UpdateUserAsync(currentUser);
            if (success)
                return new OkResult();
            else
            return new StatusCodeResult(StatusCodes.Status500InternalServerError);

        }
        private bool IsPasswordSecure(string password)
        {
            var hasUpperCase = new Regex(@"[A-Z]+");
            var hasLowerCase = new Regex(@"[a-z]+");
            var hasDigits = new Regex(@"[0-9]+");
            var hasSpecialChar = new Regex(@"[\W_]+");
            var hasMinimum8Chars = new Regex(@".{8,}");

            return hasUpperCase.IsMatch(password)
                   && hasLowerCase.IsMatch(password)
                   && hasDigits.IsMatch(password)
                   && hasSpecialChar.IsMatch(password)
                   && hasMinimum8Chars.IsMatch(password);
        }
    }
}
