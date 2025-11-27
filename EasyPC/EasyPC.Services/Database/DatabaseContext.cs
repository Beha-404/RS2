using EasyPC.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EasyPC.Services.Database
{
      public class DatabaseContext : DbContext
      {
            public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
            {
            }

            public DbSet<PC> PCs { get; set; }
            public DbSet<GraphicsCard> GraphicsCards { get; set; }
            public DbSet<Processor> Processors { get; set; }
            public DbSet<Ram> Rams { get; set; }
            public DbSet<PowerSupply> PowerSupplies { get; set; }
            public DbSet<Case> Cases { get; set; }
            public DbSet<Motherboard> Motherboards { get; set; }
            public DbSet<Manufacturer> Manufacturers { get; set; }
            public DbSet<PcType> PcTypes { get; set; }
            public DbSet<User> Users { get; set; }
            public DbSet<Order> Orders { get; set; }
            public DbSet<Rating> Ratings { get; set; }
            public DbSet<SupportMessage> SupportMessages { get; set; }

            protected override void OnModelCreating(ModelBuilder modelBuilder)
            {
                  base.OnModelCreating(modelBuilder);

                  modelBuilder.Entity<PC>(entity =>
                  {
                        entity.HasOne(p => p.GraphicsCard)
                        .WithMany()
                        .HasForeignKey(p => p.GraphicsCardId)
                        .OnDelete(DeleteBehavior.Restrict);

                        entity.HasOne(p => p.Processor)
                        .WithMany()
                        .HasForeignKey(p => p.ProcessorId)
                        .OnDelete(DeleteBehavior.Restrict);

                        entity.HasOne(p => p.Ram)
                        .WithMany()
                        .HasForeignKey(p => p.RamId)
                        .OnDelete(DeleteBehavior.Restrict);

                        entity.HasOne(p => p.PowerSupply)
                        .WithMany()
                        .HasForeignKey(p => p.PowerSupplyId)
                        .OnDelete(DeleteBehavior.Restrict);

                        entity.HasOne(p => p.Case)
                        .WithMany()
                        .HasForeignKey(p => p.CaseId)
                        .OnDelete(DeleteBehavior.Restrict);

                        entity.HasOne(p => p.MotherBoard)
                        .WithMany()
                        .HasForeignKey(p => p.MotherBoardId)
                        .OnDelete(DeleteBehavior.Restrict);
                  });

                  modelBuilder.Entity<Rating>(entity =>
                  {
                        entity.HasIndex(r => new { r.UserId, r.PcId })
                        .IsUnique();

                        entity.HasOne(r => r.PC)
                        .WithMany(u => u.Ratings)
                        .HasForeignKey(r => r.PcId)
                        .OnDelete(DeleteBehavior.Cascade);

                        entity.HasOne(r => r.User)
                        .WithMany()
                        .HasForeignKey(r => r.UserId)
                        .OnDelete(DeleteBehavior.Cascade);
                  });

                  modelBuilder.Entity<SupportMessage>(entity =>
                  {
                        entity.HasOne(sm => sm.User)
                        .WithMany()
                        .HasForeignKey(sm => sm.ConversationUserId)
                        .OnDelete(DeleteBehavior.Cascade);

                        entity.Property(sm => sm.Timestamp)
                        .HasDefaultValueSql("GETUTCDATE()");
                  });
            }
      }
}
