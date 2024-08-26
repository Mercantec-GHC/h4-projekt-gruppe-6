using API.Application.Users.Commands;
using API.Application.Users.Queries;
using API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly QueryAllUsers _queryAllUsers;
        private readonly QueryUserById _queryUserById;
        private readonly CreateUser _createUser;
        private readonly UpdateUser _updateUser;
        private readonly DeleteUser _deleteUser;
        private readonly LoginUser _loginUser;

        public UsersController(
            QueryAllUsers queryAllUsers,
            QueryUserById queryUserById,
            CreateUser createUser,
            UpdateUser updateUser,
            DeleteUser deleteUser,
            LoginUser loginUser)
        {
            _queryAllUsers = queryAllUsers;
            _queryUserById = queryUserById;
            _createUser = createUser;
            _updateUser = updateUser;
            _deleteUser = deleteUser;
            _loginUser = loginUser;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDTO login)
        {
            return await _loginUser.Handle(login);
        }

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<List<UserDTO>>> GetUsers()
        {
            return await _queryAllUsers.Handle();   
        }

        
        [HttpGet("{id}")]
        public async Task<ActionResult<UserDTO>> GetUser(string id)
        {
            return await _queryUserById.Handle(id);

        }

        [Authorize]
        [HttpPut]
        public async Task<IActionResult> PutUser(UpdateUserDTO UpdateUserDTO)
        {
            return await _updateUser.Handle(UpdateUserDTO);
        }

        [HttpPost]
        public async Task<ActionResult<Guid>> PostUser(SignUpDTO signUpDTO)
        {
            return await _createUser.Handle(signUpDTO);
        }

        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            return await _deleteUser.Handle(id);
        }
    }
}
