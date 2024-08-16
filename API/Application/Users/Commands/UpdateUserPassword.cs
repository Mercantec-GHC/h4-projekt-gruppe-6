using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace API.Application.Users.Commands
{
    public class UpdateUserPassword
    {
        private readonly IUserRepository _repository;

        public UpdateUserPassword(IUserRepository repository)
        {
            _repository = repository;
        }

        public async Task<IActionResult> Handle(ChangePasswordDTO changePasswordDTO)
        {
            if (!IsPasswordSecure(changePasswordDTO.NewPassword))
            {
                return new ConflictObjectResult(new { message = "New Password is not secure." });
            }

            User currentUser = await _repository.QueryUserByIdAsync(changePasswordDTO.Id);
            if (currentUser == null || !BCrypt.Net.BCrypt.Verify(changePasswordDTO.OldPassword, currentUser.HashedPassword))
            {
                return new UnauthorizedObjectResult(new { message = "Old Password is incorrect" });
            }
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(changePasswordDTO.NewPassword);

            currentUser.HashedPassword = hashedPassword;

            bool success = await _repository.UpdateUserPasswordAsync(currentUser);
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
