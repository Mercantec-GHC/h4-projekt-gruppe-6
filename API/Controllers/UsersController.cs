﻿using API.Application.Users.Commands;
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
using Helpers;
using Microsoft.AspNetCore.Identity;
using API.Persistence.Repositories;
using API.Persistence.Services;

namespace API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly QueryAllUsers _queryAllUsers;
        private readonly QueryUserById _queryUserById;
        private readonly QueryUsersByIds _queryUsersByIds;
        private readonly CreateUser _createUser;
        private readonly UpdateUser _updateUser;
        private readonly DeleteUser _deleteUser;
        private readonly LoginUser _loginUser;
        private readonly TokenHelper _tokenHelper;
        private readonly IUserRepository _repository;

        public UsersController(
            QueryAllUsers queryAllUsers,
            QueryUserById queryUserById,
            QueryUsersByIds queryUsersByIds,
            CreateUser createUser,
            UpdateUser updateUser,
            DeleteUser deleteUser,
            LoginUser loginUser,
            TokenHelper tokenHelper,
            IUserRepository repository
        )   
        {
            _queryAllUsers = queryAllUsers;
            _queryUserById = queryUserById;
            _queryUsersByIds = queryUsersByIds;
            _createUser = createUser;
            _updateUser = updateUser;
            _deleteUser = deleteUser;
            _loginUser = loginUser;
            _tokenHelper = tokenHelper;
            _repository = repository;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginDTO login)
        {
            return await _loginUser.Handle(login);
        }

        //[Authorize]
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

        [HttpGet("UsersByIds")]
        public async Task<ActionResult<List<UserDTO>>> GetUsersByIds(string userIds) 
        {
            List<string> ids = userIds.Split(",").ToList();
            return await _queryUsersByIds.Handle(ids);
        }

        [Authorize]
        [HttpPut]
        public async Task<IActionResult> PutUser([FromForm] UpdateUserDTO UpdateUserDTO)
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

        [HttpPost("/RefreshToken")]
        public async Task<IActionResult> RefreshToken(RefreshTokenDTO refreshTokenDTO)
        {
            User user = await _repository.QueryUserByRefreshTokenAsync(refreshTokenDTO.RefreshToken);
            return new OkObjectResult(_tokenHelper.GenerateJwtToken(user));
        }
    }
}
