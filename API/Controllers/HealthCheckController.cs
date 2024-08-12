using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HealthCheckController(AppDBContext context) : ControllerBase
    {
        [HttpGet(Name = "HealthCheck")]
        public StatusCodeResult Get()
        {
            if (!context.Database.CanConnect())
            {
                return new StatusCodeResult(500);
            }

            return Ok();
        }
    }
}
