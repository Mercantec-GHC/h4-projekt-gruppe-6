using API.Models;

namespace API.Persistence.Repositories
{
    public interface IUserRepository
    {
        Task<string> CreateUserAsync(User user);
        Task<bool> DeleteUserAsync(string id);
        Task<List<User>> QueryAllUsersAsync();
        Task<User> QueryUserByIdAsync(string id);
        Task<List<User>> QueryUsersByIdsAsync(List<string> ids);
        Task<User> QueryUserByEmailAsync(string email);
        Task<bool> UpdateUserAsync(User user);
        Task<User> QueryUserByRefreshTokenAsync(string refreshToken);
        void Save();
    }
}
