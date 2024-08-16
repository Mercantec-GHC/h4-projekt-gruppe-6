using API.Models;

namespace API.Persistence.Repositories
{
    public interface IUserRepository
    {
        Task<string> CreateUserAsync(User user);
        Task<bool> DeleteUserAsync(string id);
        Task<List<User>> QueryAllUsersAsync();
        Task<User> QueryUserByIdAsync(string id);
        Task<User> QueryUserByEmailAsync(string email);
        Task<bool> UpdateUserAsync(User user);
        Task<bool> UpdateUserPasswordAsync(User user);
    }
}