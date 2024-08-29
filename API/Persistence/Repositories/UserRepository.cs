using API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.BlazorIdentity.Pages;

namespace API.Persistence.Repositories
{
    public class UserRepository(AppDBContext context) : IUserRepository
    {
        private readonly AppDBContext _context = context;

        public async Task<List<User>> QueryAllUsersAsync()
        {
            return await _context.Users.ToListAsync();
        }

        public async Task<User> QueryUserByIdAsync(string id)
        {
            try
            {
                return await _context.Users.FirstOrDefaultAsync(user => user.Id == id);
            }
            catch (Exception)
            {
                return new User();
            }
        }

        public async Task<string> CreateUserAsync(User user)
        {
            try
            {
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }
            catch (Exception)
            {
                return "";
            }

            return user.Id;

        }

        public async Task<bool> UpdateUserAsync(User user)
        {
            try
            {
                _context.Entry(user).State = EntityState.Modified;
                await _context.SaveChangesAsync();
            }
            catch (Exception)
            {
                return false;
            }

            return true;
        }

        public async Task<bool> DeleteUserAsync(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return false;
            }
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<User> QueryUserByEmailAsync(string email)
        {
            return await _context.Users.SingleOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User> QueryUserByRefreshTokenAsync(string refreshToken)
        {
            return await _context.Users.SingleOrDefaultAsync(u => u.RefreshToken == refreshToken);
        }
    }
}
