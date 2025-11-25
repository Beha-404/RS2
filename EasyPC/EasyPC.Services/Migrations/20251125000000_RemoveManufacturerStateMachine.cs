using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EasyPC.Services.Migrations
{
    /// <inheritdoc />
    public partial class RemoveManufacturerStateMachine : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                IF EXISTS (SELECT 1 FROM sys.columns 
                           WHERE Name = N'StateMachine' 
                           AND Object_ID = Object_ID(N'Manufacturers'))
                BEGIN
                    ALTER TABLE Manufacturers DROP COLUMN StateMachine;
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "StateMachine",
                table: "Manufacturers",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
