using API.Models;
using API.Persistence.Repositories;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages;
using System.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Helpers;

namespace API.Application.Users.Commands
{
    public class LoginUser
    {
        private readonly IUserRepository _repository;
        private readonly IConfiguration _configuration;
        private readonly TokenHelper _tokenHelper;

        public LoginUser(IUserRepository repository, IConfiguration configuration, TokenHelper tokenHelper)
        {
            _repository = repository;
            _configuration = configuration;
            _tokenHelper = tokenHelper;
        }

        public async Task<IActionResult> Handle(LoginDTO loginDTO)
        {
            User user = await _repository.QueryUserByEmailAsync(loginDTO.Email);
            if (user == null || !BCrypt.Net.BCrypt.Verify(loginDTO.Password, user.HashedPassword))
            {
                return new UnauthorizedObjectResult(new { message = "Invalid email or password." });
            }
            var jwtToken = _tokenHelper.GenerateJwtToken(user);

            return new OkObjectResult(new { token = jwtToken, id = user.Id});

        }
    }
}
