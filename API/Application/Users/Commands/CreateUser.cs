using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace API.Application.Users.Commands
{
    public class CreateUser
    {
        private readonly IUserRepository _repository;

        public CreateUser(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<ActionResult<Guid>> Handle(SignUpDTO signUpDTO)
        {
            if (!new Regex(@".+@.+\..+").IsMatch(signUpDTO.Email))
            {
                return new ConflictObjectResult(new{message = "Invalid email address."});
            }

            List<User> existingUsers = await _repository.QueryAllUsersAsync();

            foreach (User existingUser in existingUsers)
            {
                if (existingUser.Username == signUpDTO.Username)
                {
                    return new ConflictObjectResult(new { message = "Username is already in use." });
                }

                if (existingUser.Email == signUpDTO.Email)
                {
                    return new ConflictObjectResult(new { message = "Email is already in use." });
                }
            }

            if (!IsPasswordSecure(signUpDTO.Password))
            {
                return new ConflictObjectResult(new { message = "Password is not secure." });
            }

            User user = MapSignUpDTOToUser(signUpDTO);
            string id = await _repository.CreateUserAsync(user);

            if (id != "")
            {
                return new OkObjectResult(id);
            }
            else
            {
                return new StatusCodeResult(StatusCodes.Status500InternalServerError); // or another status code that fits your case
            }
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

        private User MapSignUpDTOToUser(SignUpDTO signUpDTO)
        {
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(signUpDTO.Password);
            string salt = hashedPassword.Substring(0, 29);

            return new User
            {
                Id = Guid.NewGuid().ToString("N"),
                Email = signUpDTO.Email,
                Username = signUpDTO.Username,
                CreatedAt = DateTime.UtcNow.AddHours(2),
                UpdatedAt = DateTime.UtcNow.AddHours(2),
                HashedPassword = hashedPassword,
            };
        }
    }
}
