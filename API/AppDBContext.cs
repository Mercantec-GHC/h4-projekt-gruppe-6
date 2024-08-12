using API.Models;
using Microsoft.EntityFrameworkCore;

namespace API;

public class AppDBContext(DbContextOptions<AppDBContext> options) : DbContext(options)
{
    public DbSet<User> Users { get; set; }
}
