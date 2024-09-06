using API.Models;
using API.Persistence.Repositories;
using API.Persistence.Services;
using Microsoft.AspNetCore.Mvc;
using System.Text.RegularExpressions;

namespace API.Application.Users.Commands
{
    public class UpdateUser
    {
        private readonly IUserRepository _repository;
        private readonly R2Service _r2Service;
        private readonly string _accessKey;
        private readonly string _secretKey;

        public UpdateUser(IUserRepository repository, AppConfiguration config)
        {
            _repository = repository;
            _accessKey = config.AccessKey;
            _secretKey = config.SecretKey;
            _r2Service = new R2Service(_accessKey, _secretKey);
        }

        public async Task<IActionResult> Handle(UpdateUserDTO updateUserDTO)
        {
            User currentUser = await _repository.QueryUserByIdAsync(updateUserDTO.Id);

            if (updateUserDTO.Username != null || updateUserDTO.Email != null)
            {
                List<User> existingUsers = await _repository.QueryAllUsersAsync();

                foreach (User existingUser in existingUsers)
                {
                    if (existingUser.Username == updateUserDTO.Username && existingUser.Username != currentUser.Username)
                    {
                        return new ConflictObjectResult(new { message = "Username is already in use." });
                    }

                    if (existingUser.Email == updateUserDTO.Email && existingUser.Email != currentUser.Email)
                    {
                        return new ConflictObjectResult(new { message = "Email is already in use." });
                    }
                }

                if (updateUserDTO.Username != null)
                    currentUser.Username = updateUserDTO.Username;
                if (updateUserDTO.Email != null)
                    currentUser.Email = updateUserDTO.Email;
            }

            if (updateUserDTO.Password != null)
            {
                if (IsPasswordSecure(updateUserDTO.Password))
                {
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(updateUserDTO.Password);
                    currentUser.HashedPassword = hashedPassword;
                }
                else
                {
                    return new ConflictObjectResult(new { message = "Password is not secure." });
                }
            }


            string imageUrl = null;
            if (updateUserDTO.ProfilePicture != null && updateUserDTO.ProfilePicture.Length > 0)
            {
                try
                {
                    using (var fileStream = updateUserDTO.ProfilePicture.OpenReadStream())
                    {
                        imageUrl = await _r2Service.UploadToR2(fileStream, "PP" + updateUserDTO.Id + ".png");
                        currentUser.ProfilePicture = imageUrl;
                    }
                }
                catch (Exception ex)
                {
                    return new StatusCodeResult(StatusCodes.Status500InternalServerError);
                }
            }

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
