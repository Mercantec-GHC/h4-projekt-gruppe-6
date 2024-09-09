using System.ComponentModel.DataAnnotations;

namespace API.Models;

public class User : BaseModel
{
    public string? Email { get; set; }
    public string? Username { get; set; }
    public string HashedPassword { get; set; }
    public string RefreshToken { get; set; }
    public string ProfilePicture { get; set; }
    public DateTime RefreshTokenExpiresAt { get; set; }
}

public class UserDTO
{
    public string Id { get; set; }
    public string Email { get; set; }
    public string Username { get; set; }
    public string ProfilePicture { get; set; }

}

public class LoginDTO
{
    public string Email { get; set; }
    public string Password { get; set; }
}

public class SignUpDTO
{
    public string Email { get; set; }
    public string Username { get; set; }
    public string Password { get; set; }
}

public class UpdateUserDTO
{
    public string Id { get; set; }
    public string? Email { get; set; }
    public string? Username { get; set; }
    public string? Password { get; set; }
    public IFormFile? ProfilePicture { get; set; }

}

public class RefreshTokenDTO
{
    public string RefreshToken { get; set; }
}

